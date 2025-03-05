[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.10.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

# Metapipe `v3.0`

The new metapipe version 3 is compatible with [NF-core modules](https://github.com/nf-core/modules) and uses both docker and singularity containers. The user is able to save intermediate files, by the default only the output from decontamination, read annotation and contig annotation is saved unless specified otherwise. The new MetaPIPE also comes with the option to perform either read or contig annotation. At the moment only a single assembler is used, but in the future multiple assembles can be specified. Making this MetaPipe version 3 a true modularized and adaptable workflow.

## Table of contents
- [Usage](#usage)
- [Installation](#installation)
- [Other Requirements](#other-requirements)
- [Changelog](#changelog)

## Usage
Usage:<br>
`./nextflow run main.nf -c nextflow.config -work-dir work -profile singularity`

## Installation

Clone the repository in a directory of your choice:
```
git clone https://gitlab.cmbi.umcn.nl/rtc-bioinformatics/metapipe.git
```

Required docker images can be found in the `conf/containers.config` file. Singularity images can be made out of docker images by the following code:
```
docker save [hash] -o [name].tar
singularity build [name].sif docker-archive://[name].tar
```

## Requirements
The pipeline requires a set of databases which are used by the different tools in the workflow. These should be stored in the resources directory. Optionally the nextflow.config file can be altered to provide personal locations of the resources. Below instructions are listed for the required databases that do not come with the git repository.

### Humann3 DB
Make sure the /path/to/databases should contain a `chocophlan`, `uniref` and `utility_mapping` directory. These can be obtained by the following command:
```
docker pull biobakery/humann:latest

docker run --rm -v $(pwd):/scripts biobakery/humann:latest \
    humann_databases --download chocophlan full /path/to/databases \
    && humann_databases --download uniref uniref90_diamond /path/to/databases \
    && humann_databases --download utility_mapping full /path/to/databases 
```

### Kneaddata DB
```
docker pull agusinac/kneaddata:latest

docker run --rm -v $(pwd):/scripts agusinac/kneaddata:latest \
    kneaddata_database --download human_genome bowtie2 /path/to/databases
```

### CAT_pack DB
A pre-constructed diamond database can be [downloaded](https://tbb.bio.uu.nl/tina/CAT_pack_prepare/) manually or by command:
```
wget https://tbb.bio.uu.nl/tina/CAT_pack_prepare/20240422_CAT_nr.tar.gz -P /path/to/databases \
    && tar -xzf /path/to/databases/20240422_CAT_nr.tar.gz
```
## Changelog

### 3.0 / 2025-2-27
* Repo structure adapted, and similar to nf-core pipelines
* Added docker and singularity support
* Custom docker scripts can be found in path /containers/docker
* Overview of process and additional container & argument specification in /conf/containers.config
* Added NF-core modules and local modules
* Local modules follow same design as NF-core modules
* Added CHECK_INPUT subworkflow for params validation
* Added subworkflows for decontamination and read_annotation
* Added a main.nf that calls the workflow/metapipe.nf
* Updated Humann2 to Humann3, updated chocophlan, uniref90 and utility_mapping databases
* Changed decontamination from BBDuk to Kneaddata (uses BMtagger and Bowtie2) with new hg38 database.
* Added Contig annotation subworkflow.
* Added combine trim & decon reads into an overview
* Added NF-core compatible pipeline initialisation & validation
* Testing with 3 samples will happen to output BIOM format instead of text files [IN PROGRESS]

### 2.2 / 2022-1-4
* Altered docker pulls from 'functionprofiling' and 'taxonomyprofiling' to biobakery/humann:latest 

### 2.1 / 2022-31-3
* Added chocophlan/bowtie2 database (mpa_v30)
* Made 'taxonomyprofiling' compatible with metaphlan3

### 2.0 / 2022-30-3
* Updated Uniref90 and chocophlan databases (humann3 databases)
* Made 'functionProfiling' compatible with humann3 

### 1.4 / 2020-20-4
* Minor bug fixes
* Updated readme

### 1.4 / 2020-2-4
* Upgraded Nextflow to version 20.01.0
* Implemented automatic installation of required databases.
* Updated installation instructions

### 1.3 / 2020-30-3
* Use of docker containerization is now a requirement of the pipeline.
* Added functional profiling by HUMAnN2
* Taxonomic and Functional profiling results will now be merged into a single tab separated file
* Several bugfixes

### 1.2.1 / 2020-11-3
* Got rid of some unnecessary code at the profiling process
* Added empty resources directory to store the databases
* Updated installation instructions

### 1.2 / 2020-10-3
* 3 modes available now: QC, characterization and complete.
* Enabled Docker integration.

### 1.1 / 2020-9-3
* Added taxonomy profiling by metaphlan2, will be called by default.

### 1.0 / 2020-6-3
* Added QC stage (indexing files, trimming, decontamiation and quality assessment). 
