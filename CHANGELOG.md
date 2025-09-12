# metaBIOMx: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.1.0 - [2025-09-]

### `Added`
- [#1](https://github.com/CMG-GUTS/metabiomx/issues/1) `OmicFlow` report generation for both read and contig annotation subworkflows
- [#2](https://github.com/CMG-GUTS/metabiomx/issues/2) Combined all QC software files into a single MultiQC with `multiqc_config.yaml`
- subworkflow that contains post-analysis and technical reports
- Versions are compatible with nf-core and using `softwareVersionsToYAML` function

### `Fixed`
- Version formatting of `bowtie2`, `kneaddata` and `humann3`

### `Deprecated`
- `merge_multiqc_stats`
- `busco_summary` is now part of `MultiQC`

## v1.0.1 - [2025-08-27]

### `Added`
- samplesheet documentation and example in `README.md`

### `Fixed`
- solved corrupted docker `agusinac/kneaddata:latest`
- singularity caches happens automatically within the `projectDir`.

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
- [#6](https://gitlab.cmbi.umcn.nl/rtc-bioinformatics/metapipe/-/issues/6) duplicate headers from spades