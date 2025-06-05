[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.10.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![nf-test](https://img.shields.io/badge/tested_with-nf--test-337ab7.svg)](https://code.askimed.com/nf-test)

# Metapipe `v3.0`

The new metapipe version 3 is compatible with [NF-core modules](https://github.com/nf-core/modules) and uses both docker and singularity containers. The user is able to save intermediate files, by default only the output from decontamination, read annotation and contig annotation is saved unless specified otherwise. The new MetaPIPE also comes with the option to perform either read or contig annotation. At the moment only a single assembler is used, but in the future multiple assembles can be specified. Making this MetaPipe version 3 a true modularized and adaptable workflow.

## Table of contents
- [Usage](#usage)
- [Installation](#installation)

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

### nf-test
nf-test needs to be installed, can be done either from [conda or pip](https://nf-co.re/docs/nf-core-tools/installation).
nf-test has already been initialised for this repository, otherwise this could be done with `nf-test init`. 
```bash
nf-test test tests/default.nf.test --wipe-snapshot --update-snapshot --profile docker
nf-test test tests/default.nf.test --profile docker
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