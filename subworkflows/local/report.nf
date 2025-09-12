/*

    REPORT CREATION

*/

include { CREATE_ANALYSIS_MAPPING } from    '../../modules/local/create_analysis_mapping.nf'
include { MULTIQC } from                    '../../modules/local/multiqc.nf'
include { OMICFLOW_read } from              '../../modules/local/omicflow/omicflow_read.nf'
include { OMICFLOW_contig } from            '../../modules/local/omicflow/omicflow_contig.nf'
include { softwareVersionsToYAML } from     '../../subworkflows/nf-core/nf_pipeline_utils.nf'
include { paramsMap } from                  '../../lib/utils.groovy'

workflow REPORT {
    take:
    biom_read
    biom_contig
    metadata
    ch_multiqc_files
    ch_versions

    main:
    omicflow_report_read = Channel.empty()
    omicflow_report_contig = Channel.empty()

    if (metadata) {
        CREATE_ANALYSIS_MAPPING(
            metadata
        ).mapping.set{ metadata_ch }

        if (!params.bypass_read_annotation) {
            OMICFLOW_read(
                metadata_ch.first(),
                biom_read,
                []
            ).report.set{ omicflow_report_read }
            ch_versions = ch_versions.mix(OMICFLOW_read.out.versions)
        }

        if (!params.bypass_contig_annotation) {
            OMICFLOW_contig(
                metadata_ch.first(),
                biom_contig,
                []
            ).report.set{ omicflow_report_contig }
            ch_versions = ch_versions.mix(OMICFLOW_contig.out.versions)
        }
    }
    // Create parameter yaml file
    ch_collated_params = Channel
        .from(paramsMap(params))
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'params_summary_mqc.yml',
            sort: true,
            newLine: true
        )
        .map { file(it) }
    ch_collated_params.view()
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_params)

    // Create software versions yaml file
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'metabiomx_software_' + 'mqc_' + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)

    MULTIQC(
        ch_multiqc_files.collect(),
        params.multiqc_config,
        [], [], [], []
    )

    emit:
    technical_report                = MULTIQC.out.report
    read_report                     = omicflow_report_read
    contig_report                   = omicflow_report_contig
    versions                        = ch_versions
}