/*

    READ DECONTAMINATION

*/
include { TRIMMOMATIC } from '../../modules/nf-core/trimmomatic.nf'
include { ADAPTERREMOVAL } from '../../modules/nf-core/adapterremoval.nf'
include { FASTQC as FASTQC_reads } from '../../modules/nf-core/fastqc.nf'
include { FASTQC as FASTQC_trim } from '../../modules/nf-core/fastqc.nf'
include { FASTQC as FASTQC_decon } from '../../modules/nf-core/fastqc.nf'

include { KNEADDATA } from '../../modules/local/kneaddata/kneaddata.nf'
include { MULTIQC as MULTIQC_reads } from '../../modules/nf-core/multiqc.nf'
include { MULTIQC as MULTIQC_trim } from '../../modules/nf-core/multiqc.nf'
include { MULTIQC as MULTIQC_decon } from '../../modules/nf-core/multiqc.nf'
include { MERGE_MULTIQC_STATS } from '../../modules/local/merge_multiqc_stats.nf'

workflow DECONTAMINATION {
    take:
    reads
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

    if (!params.bypass_trim) {
        if (params.trim_tool == "trimmomatic") {
            TRIMMOMATIC(reads).trimmed_reads.set { ch_trimmed_reads }
            ch_versions = ch_versions.mix(TRIMMOMATIC.out.versions)
        } else {
            if (params.singleEnd) {
                ADAPTERREMOVAL(reads, []).singles_truncated.set { ch_trimmed_reads }
                ch_versions = ch_versions.mix(ADAPTERREMOVAL.out.versions)
            } else {
                ADAPTERREMOVAL(reads, []).paired_truncated.set { ch_trimmed_reads }
                ch_versions = ch_versions.mix(ADAPTERREMOVAL.out.versions)
            }
        }

        FASTQC_trim(ch_trimmed_reads)
        MULTIQC_trim(
            FASTQC_trim.out.zip.collect{ it[1] },
            "trimmed",
            [], [], [], [], []
        )
        ch_multiqc_stats_trim = MULTIQC_trim.out.multiqc_stats
        ch_multiqc_files = ch_multiqc_files.mix(MULTIQC_trim.out.report)
    } else {
        ch_trimmed_reads = reads
        ch_multiqc_stats_trim = Channel.empty()
    }

    if (!params.bypass_decon) {
        KNEADDATA(
            ch_trimmed_reads, 
            bowtie2db.first()
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
        ch_multiqc_stats_decon = MULTIQC_decon.out.multiqc_stats
        ch_multiqc_files = ch_multiqc_files.mix(MULTIQC_decon.out.report)
    } else {
        ch_decon_reads = ch_trimmed_reads
        ch_multiqc_stats_decon = Channel.empty()
    }

    MERGE_MULTIQC_STATS(
        MULTIQC_reads.out.multiqc_stats,
        ch_multiqc_stats_trim,
        ch_multiqc_stats_decon
    )
    
    emit:
    untrimmed           = reads
    trimmed             = ch_trimmed_reads
    decon               = ch_decon_reads
    multiqc_report      = ch_multiqc_files
    read_stats          = MERGE_MULTIQC_STATS.out.read_stats
    versions            = ch_versions
}