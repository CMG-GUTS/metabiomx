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
    // INPUT FILE CHECK
    CHECK_INPUT ( 
        params.reads, 
        params.singleEnd,
        params.bowtie_db,
        params.metaphlan_db,
        params.humann_db,
        params.cat_pack_db
    )

    DECONTAMINATION(
        CHECK_INPUT.out.meta,
        params.bypass_trim,
        params.bypass_decon,
        CHECK_INPUT.out.bowtie_db
    )

    if (!params.bypass_read_annotation) {
        READ_ANNOTATION(
            DECONTAMINATION.out.decon,
            CHECK_INPUT.out.metaphlan_db,
            CHECK_INPUT.out.humann_db
        )
        // OUTPUT READ ANNOTATION
        if (params.save_interleaved_reads) {
            READ_ANNOTATION.out.interleaved.map { inputFiles -> 
                def outDir = file("${params.outdir}/interleaved")
                outDir.mkdir()
                inputFiles[1].each { inputFile -> 
                        file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
                    }
            }
        }
        if (params.save_read_annotation) {
            def outDir = file("${params.outdir}/read_annotation")
            outDir.mkdir()
            READ_ANNOTATION.out.humann3_genes.map { inputFile ->
                file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
            }
            READ_ANNOTATION.out.humann3_pathabundance.map { inputFile ->
                file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
            }
            READ_ANNOTATION.out.humann3_pathcoverage.map { inputFile ->
                file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
            }
            READ_ANNOTATION.out.metaphlan_profiles.map { inputFile ->
                file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
            }
        }
    }

    if (!params.bypass_contig_annotation) {
        CONTIG_ANNOTATION(
            DECONTAMINATION.out.decon,
            CHECK_INPUT.out.catpack_db
        )

        // OUTPUT CONTIG ANNOTATION
        if (params.save_assembly ) {
            CONTIG_ANNOTATION.out.assembly.map { inputFiles -> 
                def outDir = file("${params.outdir}/assembly")
                outDir.mkdir()
                file(inputFiles[1]).copyTo(file("${outDir}/${file(inputFiles[1]).getName()}"))
            }
        }
        if (params.save_contig_annotation) {
            CONTIG_ANNOTATION.out.taxonomy.map { inputFiles -> 
                def outDir = file("${params.outdir}/CAT_contig")
                outDir.mkdir()
                file(inputFiles[1]).copyTo(file("${outDir}/${file(inputFiles[1]).getName()}"))
            }
            CONTIG_ANNOTATION.out.counts.map { inputFile ->
                def outDir = file("${params.outdir}/CAT_contig")
                file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
            }
        }
    }
    // // OUTPUT DECONTAMINATION
    if (params.save_trim_reads & !params.bypass_trim) {
        DECONTAMINATION.out.trimmed.map { inputFiles -> 
            def outDir = file("${params.outdir}/trimmed")
            outDir.mkdir()
            inputFiles[1].each { inputFile -> 
                    file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
                }
        }
    }
    if (params.save_decon_reads & !params.bypass_decon) {
        DECONTAMINATION.out.decon.map { inputFiles -> 
            def outDir = file("${params.outdir}/decontamination")
            outDir.mkdir()
            inputFiles[1].each { inputFile -> 
                    file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
                }
        }
    }

    if (params.save_multiqc_reports) {
        DECONTAMINATION.out.multiqc_report.map { inputFile -> 
            def outDir = file("${params.outdir}/multiqc")
            outDir.mkdir()
            file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}")) 
        }
        DECONTAMINATION.out.read_stats.map { inputFile ->
            def outDir = file("${params.outdir}/multiqc")
            file(inputFile).copyTo(file("${outDir}/${file(inputFile).getName()}"))
        }
    }
}