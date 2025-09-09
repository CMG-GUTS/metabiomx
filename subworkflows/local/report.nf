/*

    REPORT CREATION

*/

include { CREATE_ANALYSIS_MAPPING } from '../../modules/local/create_analysis_mapping.nf'
include { MULTIQC } from '../../modules/local/multiqc.nf'
include { OMICFLOW } from '../../modules/local/omicflow.nf'

import org.yaml.snakeyaml.Yaml

workflow REPORT {
    take:
    biom
    metadata
    ch_multiqc_files
    ch_versions

    main:

    if (metadata) {
        CREATE_ANALYSIS_MAPPING(
            metadata
        ).mapping.set{ metadata_ch }

        OMICFLOW(
            metadata_ch.first(),
            biom,
            []
        ).report.set{ omicflow_report }
        ch_versions = ch_versions.mix(OMICFLOW.out.versions)

    } else {
        omicflow_report = Channel.empty()
    }
    // Combine all versions
    ch_versions_parsed = ch_versions.collect().map { fileList ->
        def all_versions = []
        fileList.each { filePath ->
            File f = filePath.toFile()
            if (f.exists()) {
                def versions = new Yaml().load(f.text)
                all_versions += versions
            }
        }
        return all_versions.unique()
    }

    MULTIQC(
        ch_multiqc_files,
        params.multiqc_config,
        ch_versions_parsed,
        [], [], [], []
    )

    emit:
    technical_report                = MULTIQC.out.report
    analysis_report                 = omicflow_report
    versions                        = ch_versions
}