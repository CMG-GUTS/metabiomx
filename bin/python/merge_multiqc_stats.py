from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import pandas as pd

#----------------------------------------------------------------------------#
# Parse command line arguments
#----------------------------------------------------------------------------#
parser = ArgumentParser(description="Merge read counts from multiqc files into a single table", add_help=True, formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument('--i-raw', dest='raw_reads', type=str, help='in filenames', required = True)
parser.add_argument('--i-trim', dest='trim_reads', type=str, help='in filenames')
parser.add_argument('--i-decon', dest='decon_reads', type=str, help='in filenames')
parser.add_argument('-o','--outfile', dest='outfile', type=str, help='out filename', default='merged_read_stats.tsv')
options = vars(parser.parse_args())

print(options)

## Main code
raw_df = pd.read_csv(options['raw_reads'],
                     sep = "\t",
                     usecols = ["Sample", "Total Sequences"])
raw_df.columns = ["Sample", "Input Reads"]

if options['trim_reads']:
    trim_df = pd.read_csv(options['trim_reads'],
                          sep = "\t",
                          usecols = ["Sample", "Total Sequences"])

    trim_df["Trimmed Reads %"] = round(trim_df["Total Sequences"] / raw_df["Input Reads"] * 100, 2)
    trim_df.columns = ["Sample", "Trimmed Reads", "Trimmed Reads %"]
    raw_df = raw_df.merge(trim_df, on='Sample')

if options['decon_reads']:
    decon_df = pd.read_csv(options['decon_reads'],
                           sep = "\t",
                           usecols = ["Sample", "Total Sequences"])

    decon_df["Clean Reads %"] = round(decon_df["Total Sequences"] / raw_df["Input Reads"] * 100, 2)
    decon_df.columns = ["Sample", "Clean Reads", "Clean Reads %"]
    raw_df = raw_df.merge(decon_df, on='Sample')

# outfile
raw_df.to_csv(
    options['outfile'],
    sep = "\t",
    )