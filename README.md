[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.10.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![nf-test](https://img.shields.io/badge/tested_with-nf--test-337ab7.svg)](https://code.askimed.com/nf-test)

## Introduction **metaBIOMx**

The metagenomics microbiomics pipeline is a best-practice suite for the decontamination and annotation of sequencing data obtained via short-read shotgun sequencing. The pipeline contains [NF-core modules](https://github.com/nf-core/modules) and other local modules that are in the similar format. It can be runned via both docker and singularity containers.

<p align="center">
    <img src="docs/images/metabiomx_workflow.png" alt="workflow" width="90%">
</p>

## Pipeline summary
The pipeline is able to perform different taxonomic annotation on either (single/paired) reads or contigs. The different subworkflows can be defined via `--bypass_<method>` flags, a full overview is shown by running `--help`. By default the pipeline will check if the right databases are present in the right formats, when the path is provided. If this is not the case, compatible databases will be automatically downloaded.

For both subworkflows the pipeline will perform read trimming via [Trimmomatic](https://github.com/timflutre/trimmomatic) and/or [AdapterRemoval](https://github.com/MikkelSchubert/adapterremoval), followed by human removal via [Kneaddata](https://huttenhower.sph.harvard.edu/kneaddata/). Before and after each step the quality control will be assessed via [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and a [multiqc](https://github.com/MultiQC/MultiQC) report is created as output. Then taxonomy annotation is done as follows:

* Read annotation
- paired reads are interleaved using [BBTools](https://archive.jgi.doe.gov/data-and-tools/software-tools/bbtools/).
- [MetaPhlAn3](https://huttenhower.sph.harvard.edu/metaphlan/) and [HUMAnN3](https://huttenhower.sph.harvard.edu/humann/) are used for taxonomy and functional profiling.
- taxonomy profiles are merged into a single BIOM file using [biom-format](https://github.com/biocore/biom-format).

* Contig annotation
- read assembly is performed via [SPAdes](http://cab.spbu.ru/software/spades/).
- Quality assesment of contigs is done via [Busco](https://busco.ezlab.org/).
- taxonomy profiles are created using [CAT](https://github.com/dutilh/CAT).
- Read abundance estimation is performed on the contigs using [Bowtie2]() and [BCFtools](http://samtools.github.io/bcftools/bcftools.html).
- Contigs are selected if a read can be aligned against a contig and a BIOM file is generated using [biom-format](https://github.com/biocore/biom-format).

## Installation
> [!NOTE]
> Make sure you have installed the latest [nextflow](https://www.nextflow.io/docs/latest/install.html#install-nextflow) version! 

Clone the repository in a directory of your choice:
```bash
git clone https://github.com/CMG-GUTS/metabiomx.git
```

The pipeline is containerised, meaning it can be runned via docker or singularity images. No further actions need to be performed when using the docker profile, except a docker registery needs to be set on your local system, see [docker](https://docs.docker.com/engine/install/). In case singularity is used, please specify the `singularity.cacheDir` in the `nextflow.config` so that singularity images are saved there and re-used again.

## Usage
Since the latest version, metaBIOMx works with both a samplesheet (CSV) format or a path to the input files. Preferably, samplesheets should be provided.
```bash
nextflow run main.nf --input tests/data/samplesheet.csv -work-dir work -profile singularity
nextflow run main.nf --input 'tests/data/*.fastq.gz' -work-dir work -profile singularity
```

## Automatic database setup
The pipeline requires a set of databases which are used by the different tools within this workflow. The user is required to specify the location in where the databases will be downloaded. It is also possible to download the databases manually. The `configure` subworkflow will evaluate the database format and presence of the compatible files automatically.
```bash
nextflow run main.nf \
    --bowtie_db path/to/db/bowtie2 \
    --metaphlan_db path/to/db/metaphlan \
    --humann_db path/to/db/humann \
    --cat_pack_db path/to/db/catpack \
    --busco_db path/to/db/busco_downloads \
    -work-dir <work/dir> \
    -profile <singularity,docker>
```

<details>
<summary>Manual database setup</summary>

### HUMAnN3 and MetaPhlan3 DB
Make sure the `path/to/db/humann` should contain a `chocophlan`, `uniref` and `utility_mapping` directory. These can be obtained by the following command:
```bash
docker pull biobakery/humann:latest

docker run --rm -v $(pwd):/scripts biobakery/humann:latest \
    humann_databases --download chocophlan full ./path/to/db/humann \
    && humann_databases --download uniref uniref90_diamond ./path/to/db/humann \
    && humann_databases --download utility_mapping full ./path/to/db/humann \
    && metaphlan --install --index mpa_vJun23_CHOCOPhlAnSGB_202403 --bowtie2db ./path/to/db/metaphlan
```

### Kneaddata DB
```bash
docker pull agusinac/kneaddata:latest

docker run --rm -v $(pwd):/scripts agusinac/kneaddata:latest \
    kneaddata_database \
        --download human_genome bowtie2 ./path/to/db/bowtie2
```

### CAT_pack DB
A pre-constructed diamond database can be [downloaded](https://tbb.bio.uu.nl/tina/CAT_pack_prepare/) manually or by command:
```bash
docker pull agusinac/catpack:latest

docker run --rm -v $(pwd):/scripts agusinac/catpack:latest \
    CAT_pack download \
        --db nr \
        -o path/to/db/catpack

```

### busco DB
BUSCO expects that the directory is called `busco_downloads`.
```bash
docker pull ezlabgva/busco:v5.8.2_cv1

docker run --rm -v $(pwd):/scripts ezlabgva/busco:v5.8.2_cv1 \
    busco \
        --download bacteria_odb12 \
        --download_path path/to/db/busco_downloads
```
</details>

## Support

If you are having issues, please [create an issue](https://github.com/CMG-GUTS/metabiomx/issues)

## BibTeX Citation

If you use metaBIOMx in a scientific publication, we would appreciate using the following citations:

```

```
