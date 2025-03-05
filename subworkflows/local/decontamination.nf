/*

    READ DECONTAMINATION

*/
include { TRIMMOMATIC } from '../../modules/nf-core/trimmomatic.nf'
include { FASTQC as FASTQC_reads } from '../../modules/nf-core/fastqc.nf'
include { FASTQC as FASTQC_trim } from '../../modules/nf-core/fastqc.nf'
include { FASTQC as FASTQC_decon } from '../../modules/nf-core/fastqc.nf'

include { KNEADDATA } from '../../modules/local/kneaddata.nf'
include { MULTIQC as MULTIQC_reads } from '../../modules/nf-core/multiqc.nf'
include { MULTIQC as MULTIQC_trim } from '../../modules/nf-core/multiqc.nf'
include { MULTIQC as MULTIQC_decon } from '../../modules/nf-core/multiqc.nf'
include { MERGE_MULTIQC_STATS } from '../../modules/local/merge_multiqc_stats.nf'

workflow DECONTAMINATION {
    take:
    reads
    bypass_trim
    bypass_decon
    bowtie2db

    main:
    ch_multiqc_files = Channel.empty()
    ch_versions = Channel.empty()    

    FASTQC_reads(reads)
    MULTIQC_reads(
        FASTQC_reads.out.zip.collect{ it[1] },
        "raw",
        [], [], [], [], []
    )
    ch_multiqc_files = ch_multiqc_files.mix(MULTIQC_reads.out.report)
    ch_versions = ch_versions.mix(FASTQC_reads.out.versions)
    ch_versions = ch_versions.mix(MULTIQC_reads.out.versions)

    if (!bypass_trim) {
        TRIMMOMATIC(reads).trimmed_reads.set { ch_trimmed_reads }
        ch_versions = ch_versions.mix(TRIMMOMATIC.out.versions)

        FASTQC_trim(ch_trimmed_reads)
        MULTIQC_trim(
            FASTQC_trim.out.zip.collect{ it[1] },
            "trimmed",
            [], [], [], [], []
        )
        ch_multiqc_files = ch_multiqc_files.mix(MULTIQC_trim.out.report)
    } else {
        ch_trimmed_reads = reads
    }

    if (!bypass_decon) {
        KNEADDATA(
            ch_trimmed_reads, 
            bowtie2db
        ).unmapped_reads.filter { meta, files -> 
            if (meta.single_end) {
                files[0].size() > 0
            } else {
                files[0].size() > 0 && files[1].size() > 0
            }
        }.set { ch_decon_reads }
        ch_versions = ch_versions.mix(KNEADDATA.out.versions)

        FASTQC_decon(ch_decon_reads)
        MULTIQC_decon(
            FASTQC_decon.out.zip.collect{ it[1] },
            "decon",
            [], [], [], [], []
        )
        ch_multiqc_files = ch_multiqc_files.mix(MULTIQC_decon.out.report)
    } else {
        ch_decon_reads = ch_trimmed_reads
    }

    MERGE_MULTIQC_STATS(
        MULTIQC_reads.out.multiqc_stats,
        MULTIQC_trim.out.multiqc_stats,
        MULTIQC_decon.out.multiqc_stats
    )
    
    emit:
    untrimmed           = reads
    trimmed             = ch_trimmed_reads
    decon               = ch_decon_reads
    multiqc_report      = ch_multiqc_files
    read_stats          = MERGE_MULTIQC_STATS.out.read_stats
    versions            = ch_versions
}