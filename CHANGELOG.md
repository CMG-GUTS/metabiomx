# metaBIOMx: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0 - [2025-07-01]

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
- [#4](https://gitlab.cmbi.umcn.nl/rtc-bioinformatics/metapipe/-/issues/4) Added configure option of databases

### `Changed`
- Repo structure adapted, and similar to nf-core pipelines
- Local modules follow same design as NF-core modules
- updated Humann2 to Humann3
- updated chocophlan, uniref90 and utility_mapping databases
- decontamination from BBDuk to Kneaddata (uses BMtagger and Bowtie2) with new hg38 database.
- Singularity images are not downloaded in a singularity cacheDir to be specified by the user.

### `Fixed`

### `Dependencies`

### `Deprecated`