/*

    Checks if database paths are set up correctly, if not it will start downloading the databases.
    This is started with the `--download` argument.
    
*/
include { KNEADDATA_DOWNLOAD } from '../../modules/local/kneaddata/download.nf'
include { METAPHLAN_DOWNLOAD } from '../../modules/local/metaphlan/download.nf'
include { HUMANN_DOWNLOAD } from '../../modules/local/humann/download.nf'
include { BUSCO_DOWNLOAD } from '../../modules/local/busco/download.nf'
include { CATPACK_DOWNLOAD } from '../../modules/nf-core/cat_pack/download.nf'
// include { }

workflow CONFIGURE {
    main:
    bowtie_ch = ensureDirExists(params.bowtie_db)
    metaphlan_ch = ensureDirExists(params.metaphlan_db)
    humann_ch = ensureDirExists(params.humann_db)
    busco_ch = ensureDirExists(params.busco_db)
    nr_ch = ensureDirExists(params.catpack_db)

    if (!params.bypass_decon) {
        KNEADDATA_DOWNLOAD(
            "human_genome bowtie2",
            bowtie_ch
        ).db_dir_out.set{ kneaddata_db_ch }

    } else {
        kneaddata_db_ch = bowtie_ch
    }

    if (!params.bypass_read_annotation) {
        METAPHLAN_DOWNLOAD(
            metaphlan_ch
        ).db_dir_out.set{ metaphlan_db_ch }

        HUMANN_DOWNLOAD(
            humann_ch
        ).db_dir_out.set{ humann_db_ch }

    } else {
        metaphlan_db_ch = metaphlan_ch
        humann_db_ch = humann_ch
    }

    if (!params.bypass_contig_annotation) {
        BUSCO_DOWNLOAD(
            "bacteria_odb12",
            busco_ch
        ).db_dir_out.set{ busco_db_ch }
    } else {
        busco_db_ch = busco_ch
    }

    if (!params.bypass_contig_annotation) {
        // Currently only NR is supported, GTDB isn't valid: https://github.com/MGXlab/CAT_pack/issues/82
        CATPACK_DOWNLOAD(
            "nr", 
            nr_ch
        ).db_dir_out.set{ catpack_db_ch }
    } else {
        catpack_db_ch = nr_ch
    }

    emit:
    bowtie_db               = kneaddata_db_ch
    metaphlan_db            = metaphlan_db_ch
    humann_db               = humann_db_ch
    busco_db                = busco_db_ch
    catpack_db              = catpack_db_ch
}

def ensureDirExists(String dirPath) {
    def dir = file(dirPath)
    if (!dir.exists()) {
        dir.mkdirs()
    }
    return Channel.fromPath(dirPath)
}