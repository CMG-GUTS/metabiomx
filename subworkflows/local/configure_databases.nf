/*

    Checks if database paths are set up correctly, if not it will start downloading the databases.
    This is started with the `--download` argument.
    
*/
include { KNEADDATA_DOWNLOAD } from '../../modules/local/kneaddata/download.nf'
include { METAPHLAN_DOWNLOAD } from '../../modules/local/metaphlan/download.nf'
include { HUMANN_DOWNLOAD } from '../../modules/local/humann/download.nf'
include { BUSCO_DOWNLOAD } from '../../modules/local/busco/download.nf'
include { CATPACK_DOWNLOAD } from '../../modules/nf-core/cat_pack/download.nf'

workflow CONFIGURE_DATABASES {
    take:
    bowtie_db_ch
    metaphlan_db_ch
    humann_db_ch
    busco_db_ch
    catpack_db_ch

    main:
    if (!params.bypass_decon) {
        KNEADDATA_DOWNLOAD(
            "human_genome bowtie2",
            bowtie_db_ch
        )
    }

    if (!params.bypass_read_annotation) {
        METAPHLAN_DOWNLOAD(
            metaphlan_db_ch
        )

        HUMANN_DOWNLOAD(
            humann_db_ch
        )
    }

    if (!params.bypass_assembly) {
        BUSCO_DOWNLOAD(
            "bacteria_odb12",
            busco_db_ch
        )
    }

    if (!params.bypass_contig_annotation) {
        // Currently only NR is supported, GTDB isn't valid: https://github.com/MGXlab/CAT_pack/issues/82
        CATPACK_DOWNLOAD(
            "nr", 
            catpack_db_ch
        )
    }
}