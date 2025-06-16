import re, os
import numpy as np
import polars as pl
from typing import List
from scipy import sparse, io
from utils.utils import create_biom, align_tax_to_counts
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

#----------------------------------------------------------------------------#
# Parse command line arguments
#----------------------------------------------------------------------------#
parser = ArgumentParser(description='Merge read counts from multiqc files into a single table', 
                        add_help=True, 
                        formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument('--file-tax', 
                    dest='tax_files',
                    nargs = '+',  
                    type=str, 
                    help='Filename(s) to taxonomy tables from CAT', 
                    required = True)
parser.add_argument('--file-counts', 
                    dest='count_files',
                    nargs = '+', 
                    type=str, 
                    help='Filename(s) to sam idxstats tables', 
                    required = True)
parser.add_argument('-o','--outdir', 
                    dest='outdir', 
                    type=str, 
                    help='Directory to write the output files',
                    default = '.')
options = vars(parser.parse_args())

#----------------------------------------------------------------------------#
# FUNCTIONS
#----------------------------------------------------------------------------#

def CAT_to_table(filename: str, feature_ranks: List[str]) -> pl.DataFrame:
    """
    Parses a CAT taxonomy table and outputs a polars dataframe

    Parameters
    ----------
    filename : str
        A CAT taxonomy file.
    
    feature_ranks : list
        A list of taxonomy ranks to extract.

    Returns
    -------
    polars.DataFrame

    """
    # Should be replaced to bytes
    with open(filename, 'rb') as infile:
        chunk = infile.readlines()
        data = [line.decode('utf-8').strip('\n').split('\t') for line in chunk]

    # Initialize table format
    features = { feature: np.empty(shape=len(data), dtype='U100') for feature in feature_ranks }

    # Configuration
    taxonomic_ranks = ['kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']

    # Loop through contigs
    for i, contig in enumerate(data):

        # Get probability score of lowest taxonomic rank
        last_elem = contig[-1]
        match = re.search('\\((.*?)\\)', last_elem)

        if match and any(rank in match.group(1) for rank in taxonomic_ranks):
            features['probability'][i] = last_elem.rsplit(':', 1)[1].strip()

            # Fetch annotation from each taxonomic rank
            for elem in contig:
                if elem.__contains__('NODE'):
                    features['feature_id'][i] = elem
                elif elem.__contains__('kingdom'):
                    features['kingdom'][i] = elem.split('(')[0].strip()
                elif elem.__contains__('phylum'):
                    features['phylum'][i] = elem.split('(')[0].strip()
                elif elem.__contains__('class'):
                    features['class'][i] = elem.split('(')[0].strip()
                elif elem.__contains__('order'):
                    features['order'][i] = elem.split('(')[0].strip()
                elif elem.__contains__('family'):
                    features['family'][i] = elem.split('(')[0].strip()
                elif elem.__contains__('genus'):
                    features['genus'][i] = elem.split('(')[0].strip()
                elif elem.__contains__('species'):
                    features['species'][i] = elem.split('(')[0].strip()

    return(pl.DataFrame(features).filter(pl.col('feature_id') != ''))

#----------------------------------------------------------------------------#
# CONSTRUCT COUNTS & TAX FILES
#----------------------------------------------------------------------------#

taxonomy_attributes = ['feature_id', 'probability', 'kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']

# Fetch taxonomy table
tax_tables = [CAT_to_table(tax, taxonomy_attributes) for tax in options['tax_files']]
tax_pl = (
    pl.concat(tax_tables, how='vertical')
    .unique(
        subset='feature_id', 
        keep='first', 
        maintain_order=True
    )
    .with_columns(
        pl.col('probability').cast(pl.Float64)
    )
)

# Fetch counts table and perform cleaning
sample_names = [re.sub('.stats', '', os.path.basename(infile)) for infile in options['count_files']]
count_tables = [
    pl.read_csv(infile, separator='\t', has_header=False, columns=[0, 2])
    .rename({
        'column_1': 'feature_id',
        'column_3': sample_names[i]
        })
    .filter(pl.col('feature_id') != '*')
    for i, infile in enumerate(options['count_files'])
]
counts_pl = pl.concat(count_tables, how='diagonal')

# Align counts and tax
aligned_counts_pl, aligned_tax_pl = pl.align_frames([counts_pl.fill_null(0), tax_pl], on='feature_id')
aligned_tax_pl = aligned_tax_pl.fill_null('')

# construct sparse matrix
samples = aligned_counts_pl.select(pl.exclude('feature_id')).columns
feature_ids = aligned_counts_pl.get_column('feature_id').to_numpy()
feature_ids = feature_ids.astype(str)
sp_counts = sparse.csr_matrix(aligned_counts_pl.drop('feature_id').to_numpy())

### Clean counts and tax in parallel
## Removing feature_ids that are not identified on kingdom rank
subset_tax_pl = aligned_tax_pl.filter(pl.col('kingdom') != '')
subset_feature_ids_mask = (
    aligned_tax_pl.select((pl.col('kingdom') != ''))
    .to_series()
    .to_numpy()
)
subset_sp_counts = sp_counts[subset_feature_ids_mask]
subset_features_ids = feature_ids[subset_feature_ids_mask]

## Removing feature_ids that are empty in the counts
row_sums = np.array(subset_sp_counts.sum(axis=1)).flatten()
nonzero_indices = row_sums != 0
final_feature_ids = subset_features_ids[nonzero_indices]
final_sp_counts = subset_sp_counts[nonzero_indices]

# Aligning feature_ids from tax to counts 
final_tax_pl = align_tax_to_counts(
    tax = subset_tax_pl,
    feature_ids = final_feature_ids
)

#----------------------------------------------------------------------------#
# OUTPUT: BIOM HDF5 FORMAT
#----------------------------------------------------------------------------#

create_biom(
    counts = final_sp_counts,
    features = final_tax_pl,
    sample_ids = samples,
    taxonomy_ranks = taxonomy_attributes,
    outdir = options['outdir'],
    filename = 'CAT_with_taxonomy'
)