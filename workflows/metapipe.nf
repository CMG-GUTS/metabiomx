/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { CHECK_INPUT } from '../subworkflows/local/check_input.nf'
include { DECONTAMINATION } from '../subworkflows/local/decontamination.nf'
include { READ_ANNOTATION } from '../subworkflows/local/read_annotation.nf'
include { CONTIG_ANNOTATION } from '../subworkflows/local/contig_annotation.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow METAPIPE {
    
    CHECK_INPUT ()

    // If assembly is bypassed, we asssume that input are assemblies itself!
    if (!params.bypass_assembly) {
        DECONTAMINATION(
            CHECK_INPUT.out.meta,
            CHECK_INPUT.out.bowtie_db
        )

        // Creates output channel for only clean reads
        ch_decontamination = DECONTAMINATION.out.decon

        // OUTPUT DECONTAMINATION
        if (params.save_trim_reads & !params.bypass_trim) {
            save_output(ch_decontaminaton.out.trimmed, "trimmed")
        }
        if (params.save_decon_reads & !params.bypass_decon) {
            save_output(ch_decontaminaton.out.decon, "decontamination")
        }

        if (params.save_multiqc_reports) {
            save_output(ch_decontaminaton.out.multiqc_report, "multiqc")
            save_output(ch_decontaminaton.out.read_stats, "multiqc")
        }
    } else {
        // Channel contains non-reads, likely assembly files
        ch_decontaminaton = CHECK_INPUT.out.meta
    }

    if (!params.bypass_read_annotation) {
        READ_ANNOTATION(
            ch_decontaminaton,
            CHECK_INPUT.out.metaphlan_db,
            CHECK_INPUT.out.humann_db
        )
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
            CHECK_INPUT.out.catpack_db,
            CHECK_INPUT.out.busco_db
        )

        // OUTPUT CONTIG ANNOTATION
        if (params.save_assembly && !params.bypass_assembly) {
            save_output(CONTIG_ANNOTATION.out.assembly, "assembly")
            save_output(CONTIG_ANNOTATION.out.assembly_qc_fig, "assembly")
            save_output(CONTIG_ANNOTATION.out.assembly_qc_raw, "assembly/busco_summaries")

        }
        if (params.save_contig_annotation) {
            save_output(CONTIG_ANNOTATION.out.biom, "CAT_contig")
        }
    }
}

def save_output(input_ch, sub_dir_name) {
    input_ch.map { item ->
        def (meta, files) = (item instanceof List && item.size() == 2) ? [item[0], item[1]] : [null, item]
        def outDir = file("${params.outdir}/${sub_dir_name}")
        outDir.mkdir()
        if (files.size() == 2) {
            files.each { inputFile ->
               file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
            }
        } else {
            file(files).copyTo(file("${outDir}/${file(files).getName()}"))
        }
    }
}