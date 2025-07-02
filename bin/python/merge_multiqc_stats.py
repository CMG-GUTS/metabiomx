from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import polars as pl

#----------------------------------------------------------------------------#
# Parse command line arguments
#----------------------------------------------------------------------------#
parser = ArgumentParser(description="Merge read counts from multiqc files into a single table", add_help=True, formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument('--i-raw', dest='raw_reads', type=str, help='in filenames', required = True)
parser.add_argument('--i-trim', dest='trim_reads', type=str, help='in filenames')
parser.add_argument('--i-decon', dest='decon_reads', type=str, help='in filenames')
parser.add_argument('-o','--outfile', dest='outfile', type=str, help='out filename', default='merged_read_stats.tsv')
options = vars(parser.parse_args())

## Main code
# Read raw reads
raw_df = pl.read_csv(
    options['raw_reads'],
    separator="\t",
    columns=["Sample", "Total Sequences"]
).rename({"Total Sequences": "Input Reads"})

# Optionally add trimmed reads
if options['trim_reads']:
    trim_df = pl.read_csv(
        options['trim_reads'],
        separator="\t",
        columns=["Sample", "Total Sequences"]
    )
    # Join to get Input Reads for percentage calculation
    trim_df = trim_df.join(raw_df, on="Sample")
    trim_df = trim_df.with_columns(
        (pl.col("Total Sequences") / pl.col("Input Reads") * 100).round(2).alias("Trimmed Reads %")
    ).rename({"Total Sequences": "Trimmed Reads"})
    trim_df = trim_df.select(["Sample", "Trimmed Reads", "Trimmed Reads %"])
    raw_df = raw_df.join(trim_df, on="Sample", how="left")

# Optionally add decontaminated reads
if options['decon_reads']:
    decon_df = pl.read_csv(
        options['decon_reads'],
        separator="\t",
        columns=["Sample", "Total Sequences"]
    )
    # Join to get Input Reads for percentage calculation
    decon_df = decon_df.join(raw_df, on="Sample")
    decon_df = decon_df.with_columns(
        (pl.col("Total Sequences") / pl.col("Input Reads") * 100).round(2).alias("Clean Reads %")
    ).rename({"Total Sequences": "Clean Reads"})
    decon_df = decon_df.select(["Sample", "Clean Reads", "Clean Reads %"])
    raw_df = raw_df.join(decon_df, on="Sample", how="left")

# outfile
raw_df.write_csv(
    options['outfile'],
    separator = "\t",
    )