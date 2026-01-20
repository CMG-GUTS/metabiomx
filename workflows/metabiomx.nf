/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { save_output } from            '../lib/utils.groovy'
include { CHECK_INPUT } from            '../subworkflows/local/check_input.nf'
include { CONFIGURE } from              '../subworkflows/local/configure.nf'
include { DECONTAMINATION } from        '../subworkflows/local/decontamination.nf'
include { READ_ANNOTATION } from        '../subworkflows/local/read_annotation.nf'
include { CONTIG_ANNOTATION } from      '../subworkflows/local/contig_annotation.nf'
include { REPORT } from                 '../subworkflows/local/report.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow METABIOMX {
    // Validates input
    CHECK_INPUT ()

    // Default check-up of databases
    CONFIGURE()

    // Initate empty channels
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()
    biom_read_anot = Channel.empty()
    biom_contig_anot = Channel.empty()

    if (params.input || params.reads) {
        // If assembly is bypassed, we asssume that input are assemblies itself!
        if (!params.bypass_assembly) {
            DECONTAMINATION(
                CHECK_INPUT.out.meta,
                CONFIGURE.out.bowtie_db
            )
            ch_multiqc_files = ch_multiqc_files.mix(DECONTAMINATION.out.multiqc_files)
            ch_versions = ch_versions.mix(DECONTAMINATION.out.versions)

            // Creates output channel for only clean reads
            ch_decontaminaton = DECONTAMINATION.out.decon

            // OUTPUT DECONTAMINATION
            if (params.save_trim_reads & !params.bypass_trim) {
                save_output(DECONTAMINATION.out.trimmed, "trimmed")
            }
            if (params.save_decon_reads & !params.bypass_decon) {
                save_output(DECONTAMINATION.out.decon, "decontamination")
            }
        } else {
            // Channel contains non-reads, likely assembly files
            ch_decontaminaton = CHECK_INPUT.out.meta
        }

        if (!params.bypass_read_annotation) {
            READ_ANNOTATION(
                ch_decontaminaton,
                CONFIGURE.out.metaphlan_db,
                CONFIGURE.out.humann_db
            )

            biom_read_anot = READ_ANNOTATION.out.metaphlan_biom
            ch_versions = ch_versions.mix(READ_ANNOTATION.out.versions)

            if (params.save_interleaved_reads) {
                save_output(READ_ANNOTATION.out.interleaved, "interleaved")
            }
            if (params.save_read_annotation) {
                save_output(READ_ANNOTATION.out.humann3_genes, "read_annotation")
                save_output(READ_ANNOTATION.out.humann3_pathabundance, "read_annotation")
                save_output(READ_ANNOTATION.out.humann3_pathcoverage, "read_annotation")
                save_output(READ_ANNOTATION.out.metaphlan_profiles, "read_annotation")
                save_output(READ_ANNOTATION.out.metaphlan_biom, "read_annotation")
            }
        }

        if (!params.bypass_contig_annotation) {
            CONTIG_ANNOTATION(
                ch_decontaminaton,
                CONFIGURE.out.catpack_db,
                CONFIGURE.out.busco_db
            )
            biom_contig_anot = CONTIG_ANNOTATION.out.biom
            ch_multiqc_files = ch_multiqc_files.mix(CONTIG_ANNOTATION.out.multiqc_files)
            ch_versions = ch_versions.mix(CONTIG_ANNOTATION.out.versions)

            // OUTPUT CONTIG ANNOTATION
            if (params.save_assembly && !params.bypass_assembly) {
                save_output(CONTIG_ANNOTATION.out.assembly_original, "assembly/original")
                save_output(CONTIG_ANNOTATION.out.assembly_renamed, "assembly/renamed")
                save_output(CONTIG_ANNOTATION.out.assembly_combined, "assembly")
            }
            if (params.save_contig_annotation) {
                save_output(CONTIG_ANNOTATION.out.biom, "CAT_contig")
            }
        }

        if (!params.bypass_report) {
            REPORT(
                biom_read_anot,
                biom_contig_anot,
                CHECK_INPUT.out.metadata,
                ch_multiqc_files,
                CHECK_INPUT.out.sample_size,
                ch_versions
            )

            if (params.save_final_reports) {
                save_output(REPORT.out.technical_report, "report")
                if (REPORT.out.read_report)
                    save_output(REPORT.out.read_report, "report")

                if (REPORT.out.contig_report)
                    save_output(REPORT.out.contig_report, "report")
            }
        }
    }    
}