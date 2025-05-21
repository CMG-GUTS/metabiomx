import time, os
import polars as pl
import numpy as np
from scipy import sparse
from typing import List
from biom.table import Table
from biom.util import biom_open

def create_biom(counts: sparse.csr_matrix, features: pl.DataFrame, sample_ids: List[str], 
                taxonomy_ranks: List[str], outdir: str, filename: str) -> None:
    """
    TODO: document me!

    """
    taxonomy_metadata = [
        {'taxonomy': [row[col] for col in taxonomy_ranks]}
        for row in features.to_dicts()
    ]

    biom_table = Table(
        data = counts,
        observation_ids = [f"OTU_{i}" for i in range(len(taxonomy_metadata))],
        sample_ids = sample_ids,
        observation_metadata = taxonomy_metadata,
        create_date = time.ctime(time.time()),
        generated_by = 'MetaPIPE RTC Bioinformatics'
    )

    with biom_open(os.path.join(outdir ,f'{filename}.biom'), 'w') as outfile:
        biom_table.to_hdf5(
            h5grp = outfile, 
            generated_by = 'MetaPIPE RTC Bioinformatics',
            compress = True
        )

def align_tax_to_counts(tax: pl.DataFrame, feature_ids: np.ndarray) -> pl.DataFrame:
    """
    tax should have a column called 'feature_id'

    TODO: document me!

    """
    # Add row and order index
    final_tax_pl = tax.with_row_count("row_idx")
    ids_df = pl.DataFrame({
        "feature_id": feature_ids,
        "order_idx": range(0, len(feature_ids))
    })

    # Sum duplicated feature_ids of tax 
    final_tax_pl = final_tax_pl.with_columns(
        pl.col("feature_id").cum_count().over("feature_id").alias("dup_idx")
    )

    # Sum duplicated feature_ids of counts
    ids_df = ids_df.with_columns(
        pl.col("feature_id").cum_count().over("feature_id").alias("dup_idx")
    )

    # Inner join between duplication indices, restore original order
    final_subset_tax_pl = ids_df.join(final_tax_pl, on=["feature_id", "dup_idx"], how="inner")
    return(final_subset_tax_pl.sort("order_idx").drop(["order_idx", "dup_idx", "row_idx"]))