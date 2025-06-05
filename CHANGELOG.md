# metapipe: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v3.0.0 - [2025-02-27]

### `Added`
- docker and singularity support
- Custom docker scripts can be found in path /containers/docker
- Overview of process and additional container & argument specification in /conf/containers.config
- NF-core modules and local modules
- CHECK_INPUT subworkflow for params validation
- subworkflows for decontamination and read_annotation
- main.nf that calls the workflow/metapipe.nf
- Contig annotation subworkflow.
- combine trim & decon reads into an overview
- NF-core compatible pipeline initialisation & validation
- simple unit-testing for each subworkflow
- BIOM OUTPUT in read_annotation and contig_annotation

### `Changed`
- Repo structure adapted, and similar to nf-core pipelines
- Local modules follow same design as NF-core modules
- updated Humann2 to Humann3
- updated chocophlan, uniref90 and utility_mapping databases
- decontamination from BBDuk to Kneaddata (uses BMtagger and Bowtie2) with new hg38 database.

### `Fixed`

### `Dependencies`

### `Deprecated`

## v2.2.0 - [2022-01-04]

### `Added`

### `Changed`
- docker pulls from 'functionprofiling' and 'taxonomyprofiling' to biobakery/humann:latest.

### `Fixed`

### `Dependencies`

### `Deprecated`

## v2.1.0 - [2022-31-03]

### `Added`
- chocophlan/bowtie2 database (mpa_v30)

### `Changed`
- Made 'taxonomyprofiling' compatible with metaphlan3

### `Fixed`

### `Dependencies`

### `Deprecated`

## v2.0.0 - [2022-30-03]

### `Added`

### `Changed`
- Made 'functionProfiling' compatible with humann3 
- Updated Uniref90 and chocophlan databases (humann3 databases)

### `Fixed`

### `Dependencies`

### `Deprecated`

## v1.4.0 - [2020-02-04]

### `Added`
- automatic installation of required databases.

### `Changed`
- Upgraded Nextflow to version 20.01.0
- Updated installation instructions
- Updated readme

### `Fixed`
- Minor bug fixes

### `Dependencies`

### `Deprecated`

## v1.3.0 - [2020-30-03]

### `Added`
- functional profiling by HUMAnN2

### `Changed`
- Taxonomic and Functional profiling results will now be merged into a single tab separated file.
- Use of docker containerization is now a requirement of the pipeline.

### `Fixed`
- Several bugfixes

### `Dependencies`

### `Deprecated`

## v1.2.1 - [2020-11-03]

### `Added`
- empty resources directory to store the databases

### `Changed`
- Got rid of some unnecessary code at the profiling process
- updated installation instructions.

### `Fixed`

### `Dependencies`

### `Deprecated`

## v1.2.0 - [2020-10-03]

### `Added`
- Enabled Docker integration.

### `Changed`
- 3 modes available now: QC, characterization and complete.

### `Fixed`

### `Dependencies`

### `Deprecated`

## v1.1.0 - [2020-09-03]

### `Added`
- taxonomy profiling by metaphlan2, will be called by default. 

### `Changed`

### `Fixed`

### `Dependencies`

### `Deprecated`

## v1.0.0 - [2020-06-03]

### `Added`
- QC stage (indexing files, trimming, decontamiation and quality assessment). 

### `Changed`

### `Fixed`

### `Dependencies`

### `Deprecated`
