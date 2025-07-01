[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.10.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![nf-test](https://img.shields.io/badge/tested_with-nf--test-337ab7.svg)](https://code.askimed.com/nf-test)

# metaBIOMx `v1.0`

The new metapipe version 3 is compatible with [NF-core modules](https://github.com/nf-core/modules) and uses both docker and singularity containers. The user is able to save intermediate files, by default only the output from decontamination, read annotation and contig annotation is saved unless specified otherwise. The new MetaPIPE also comes with the option to perform either read or contig annotation. At the moment only a single assembler is used, but in the future multiple assembles can be specified. Making this MetaPipe version 3 a true modularized and adaptable workflow.

## Installation

Clone the repository in a directory of your choice:
```bash
git clone https://gitlab.cmbi.umcn.nl/rtc-bioinformatics/metapipe.git
```

The pipeline is containeraized, meaning it can be runned via docker or singularity images. No further actions need to be performed when using the docker profile, except a docker registery needs to be set on your local system, see [docker](https://docs.docker.com/engine/install/). In case singularity is used, please specify the `singularity.cacheDir` in the nextflow.config so that singularity images are saved there and re-used again.

## Usage
Since the latest version, metaBIOMx works with both a samplesheet (CSV) format or a path to the input files. Preferably, samplesheets should be provided.
```bash
nextflow run main.nf --input tests/data/samplesheet.csv -work-dir work -profile singularity
nextflow run main.nf --input 'tests/data/*.fastq.gz' -work-dir work -profile singularity
```

## Automatic database setup
The pipeline requires a set of databases which are used by the different tools within this workflow. The user can setup databases via the `--configure` flag, here it is important to specify the path for each database. The `--configure` argument will check if required database files are missing and will setup the directory structure that is compatible with the other modules. This step can be runned before processing the samples but also in combination with the `--input` and `--reads` flags.
```bash
nextflow run main.nf \
    --configure \
    --bowtie_db path/to/db/bowtie2 \
    --metaphlan_db path/to/db/metaphlan \
    --humann_db path/to/db/humann \
    --cat_pack_db path/to/db/catpack \
    --busco_db path/to/db/busco_downloads \
    -work-dir <work/dir> \
    -profile <singularity,docker>
```
<details open>
<summary>Manual database setup</summary>

### Humann3 DB
Make sure the `path/to/db/humann` should contain a `chocophlan`, `uniref` and `utility_mapping` directory. These can be obtained by the following command:
```bash
docker pull biobakery/humann:latest

docker run --rm -v $(pwd):/scripts biobakery/humann:latest \
    humann_databases --download chocophlan full ./path/to/db/humann \
    && humann_databases --download uniref uniref90_diamond ./path/to/db/humann \
    && humann_databases --download utility_mapping full ./path/to/db/humann 
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

<details open>
<summary>nf-test</summary>

nf-test needs to be installed, can be done either from [conda or pip](https://nf-co.re/docs/nf-core-tools/installation).
nf-test has already been initialised for this repository, otherwise this could be done with `nf-test init`. 
```bash
nf-test test tests/default.nf.test --wipe-snapshot --update-snapshot --profile docker
nf-test test tests/default.nf.test --profile docker
```
</details>