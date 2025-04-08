from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import pandas as pd
import re

#----------------------------------------------------------------------------#
# Parse command line arguments
#----------------------------------------------------------------------------#
parser = ArgumentParser(description="MERGE samtools .stats into a single table", add_help=True, formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument('-i','--input', dest='infiles', nargs = "+", help='in filenames', required = True)
parser.add_argument('-o','--outfile', dest='outfile', type=str, help='out filename', default='merged_read_stats.tsv')
options = vars(parser.parse_args())

## Main code
sample_names = [re.sub(".stats", "", infile) for infile in options['infiles']]
load_df = [pd.read_csv(infile, sep = "\t", header=None, usecols=[0, 2], index_col = 0) for infile in options['infiles']]

merged_df = pd.concat(load_df, axis=1)
merged_df.columns = sample_names
merged_df = merged_df[~merged_df.isin(['*']).any(axis=1)]

merged_df.to_csv(options['outfile'], 
                 sep = "\t",
                 index = True,
                 header = True
                )
