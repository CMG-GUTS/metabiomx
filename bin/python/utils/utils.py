import time, os
import polars as pl
from scipy import sparse
from typing import List
from biom.table import Table
from biom.util import biom_open

def create_biom(counts: sparse.csr_matrix, features: pl.DataFrame, sample_ids: List[str], 
                taxonomy_ranks: List[str], outdir: str, filename: str) -> None:

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