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

    // KNEADDATA DB DEPENDENCIES
    if (params.bowtie_db) {
        bowtie_ch = ensureDir(params.bowtie_db)

        if (!params.bypass_decon) {
            KNEADDATA_DOWNLOAD(
                "human_genome bowtie2",
                bowtie_ch
            ).db_dir_out.set{ kneaddata_db_ch }
        }
    } else if (params.bypass_decon) {
        kneaddata_db_ch = Channel.empty()
        log.warn("The database configuration for 'params.bowtie_db' is skipped due to '--bypass_decon'")

    } else {
        error("Missing --bowtie_db declaration, if you do not need it please use '--bypass_decon'")
    }

    // METAPHLAN3 & HUMANN3 DB DEPENDENCIES
    if (params.metaphlan_db && params.humann_db) {
        metaphlan_ch = ensureDir(params.metaphlan_db)
        humann_ch = ensureDir(params.humann_db)

        if (!params.bypass_read_annotation) {
            METAPHLAN_DOWNLOAD(
                params.metaphlan_db_index,
                metaphlan_ch
            ).db_dir_out.set{ metaphlan_db_ch }

            HUMANN_DOWNLOAD(
                humann_ch
            ).db_dir_out.set{ humann_db_ch }
        }

    } else if (params.bypass_read_annotation) {
        metaphlan_db_ch = Channel.empty()
        humann_db_ch = Channel.empty()
        log.warn("The database configuration for 'params.metaphlan_db' and 'params.humann_db' are skipped due to '--bypass_read_annotation'")

    } else {
        error("Missing --metaphlan_db and --humann_db declarations, if you do not need it please use '--bypass_read_annotation'")
    }

    // BUSCO && CATPACK DB DEPENDENCIES
    if (params.busco_db && params.catpack_db) {
        busco_ch = ensureDir(params.busco_db)
        nr_ch = ensureDir(params.catpack_db)

        if (!params.bypass_contig_annotation) {
            BUSCO_DOWNLOAD(
                params.busco_lineage,
                busco_ch
            ).db_dir_out.set{ busco_db_ch }

            // Currently only NR is supported, GTDB isn't valid: https://github.com/MGXlab/CAT_pack/issues/82
            CATPACK_DOWNLOAD(
                "nr", 
                nr_ch
            ).db_dir_out.set{ catpack_db_ch }
        }
    } else if (params.bypass_contig_annotation) {
        busco_db_ch = Channel.empty()
        catpack_db_ch = Channel.empty()
        log.warn("The database configuration for 'params.busco_db' and 'params.catpack_db' are skipped due to '--bypass_contig_annotation'")

    } else {
        error("Missing --busco_db and --catpack_db declarations, if you do not need it please use '--bypass_contig_annotation'")
    }

    emit:
    bowtie_db               = kneaddata_db_ch
    metaphlan_db            = metaphlan_db_ch
    humann_db               = humann_db_ch
    busco_db                = busco_db_ch
    catpack_db              = catpack_db_ch
}

def ensureDir(String dirPath) {
    def dir = file(dirPath)
    if (!dir.exists()) {
        dir.mkdirs()
    }
    return Channel.fromPath(dirPath)
}