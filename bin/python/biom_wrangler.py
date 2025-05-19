import re, time, os
import numpy as np
import polars as pl
from scipy import sparse
from biom.table import Table
from biom.util import biom_open
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

#----------------------------------------------------------------------------#
# Parse command line arguments
#----------------------------------------------------------------------------#
parser = ArgumentParser(description='Merge, Clean and Create BIOM files as HDF5 format', 
                        add_help=True, 
                        formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument('--i-tsv', 
                    dest='tsv_file',
                    type=str, 
                    help='Filename(s) in tsv format to clean and output in BIOM file format with HDF5 compression.')
parser.add_argument('-o','--outdir', 
                    dest='outdir', 
                    type=str, 
                    help='Directory to write the output files',
                    default = '.')
options = vars(parser.parse_args())

#----------------------------------------------------------------------------#
# INPUT: WRANGLE & CLEAN FILES
#----------------------------------------------------------------------------#

# load data as polars table
raw_dt = pl.read_csv(
    source = options['tsv_file'], 
    separator = "\t", 
    skip_rows = 1, # Standard in metaphlan3 output
    has_header = True
    )

# Rename metaphlan generated column names
clean_dt = raw_dt.rename({raw_dt.columns[0]: "features"})
clean_dt.columns = [re.sub('_metaphlan_bugs_list', '', item) for item in clean_dt.columns]

# Splitting features
taxonomic_ranks = ['kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
features = clean_dt.select(pl.col('features'))
features = features.with_columns(
    pl.col('features').str.split_exact('|', len(taxonomic_ranks)).struct.rename_fields(taxonomic_ranks)
    ).unnest('features').fill_null('') # replacing null/None by '' is required for utf-8 encoding

# construct sparse matrix
samples = clean_dt.select(pl.exclude('features')).columns
sp_counts = sparse.csr_matrix(clean_dt.drop('features').to_numpy())

#----------------------------------------------------------------------------#
# OUTPUT: BIOM HDF5 FORMAT
#----------------------------------------------------------------------------#

taxonomy_metadata = [
    {'taxonomy': [row[col] for col in taxonomic_ranks]}
    for row in features.to_dicts()
]

biom_table = Table(
    data = sp_counts,
    observation_ids = [f"OTU_{i}" for i in range(len(taxonomy_metadata))],
    sample_ids = samples,
    observation_metadata = taxonomy_metadata,
    create_date = time.ctime(time.time()),
    generated_by = 'MetaPIPE RTC Bioinformatics'
)

with biom_open(os.path.join(options['outdir'] ,'metaphlan_with_taxonomy.biom'), 'w') as outfile:
    biom_table.to_hdf5(
        h5grp = outfile, 
        generated_by = 'MetaPIPE RTC Bioinformatics',
        compress = True
    )