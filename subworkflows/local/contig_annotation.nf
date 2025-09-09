/*

    CONTIG ANNOTATION

*/
include { SPADES } from                         '../../modules/nf-core/spades.nf'
include { BUSCO } from                          '../../modules/local/busco/busco.nf'
include { CATPACK_CONTIGS } from                '../../modules/nf-core/cat_pack/contigs.nf'
include { READ_ABUNDANCE_ESTIMATION } from      '../../modules/local/read_abundance_estimation.nf'
include { CAT_TO_BIOM } from                    '../../modules/local/cat_to_biom.nf'

workflow CONTIG_ANNOTATION {
    take:
    reads
    cat_pack_db
    busco_db

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    // Assembly via metaSpades
    if (!params.bypass_assembly) {
        SPADES(
            reads, 
            []
        ).scaffolds.set { ch_scaffolds }

        ch_multiqc_files = ch_multiqc_files.mix(SPADES.out.log.collect{ it[1] })
        ch_versions = ch_versions.mix(SPADES.out.versions)

    } else {
        ch_scaffolds = reads
    }

    // QC of assemblies
    BUSCO(
        ch_scaffolds,
        busco_db.first()
    )
    
    ch_versions = ch_versions.mix(BUSCO.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(BUSCO.out.summary.collect{ it[1] })

    // Contig Annotation
    CATPACK_CONTIGS(
        ch_scaffolds,
        // [], [], 
        cat_pack_db.first()
    ).classification_with_names.set{ ch_tax_contigs }

    ch_versions = ch_versions.mix(CATPACK_CONTIGS.out.versions)

    if (!params.bypass_assembly) { 
        // Read count via mapping reads to contigs
        READ_ABUNDANCE_ESTIMATION(
            reads,
            ch_scaffolds
        ).stats.set{ ch_read_stats }

        ch_versions = ch_versions.mix(READ_ABUNDANCE_ESTIMATION.out.versions)
        ch_multiqc_files = ch_multiqc_files.mix(READ_ABUNDANCE_ESTIMATION.out.log.collect{ it[1] })

        // Combines read count and CAT taxonomy into a BIOM HDF5 file
        CAT_TO_BIOM(
            ch_tax_contigs.collect{ it[1] },
            ch_read_stats.collect{ it[1] },
            ch_scaffolds.collect{ it[1] }
        ).biom.set{ ch_biom }

        ch_versions = ch_versions.mix(CAT_TO_BIOM.out.versions)
    } else {
        // In case assembly is skipped, only 
        ch_biom = ch_tax_contigs
    }

    emit:
    assembly_original   = ch_scaffolds
    assembly_renamed    = CAT_TO_BIOM.out.renamed_scaffolds
    assembly_combined   = CAT_TO_BIOM.out.combined_scaffolds
    multiqc_files       = ch_multiqc_files
    biom                = ch_biom
    versions            = ch_versions
}