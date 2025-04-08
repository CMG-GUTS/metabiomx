/*

    CONTIG ANNOTATION

*/
include { SPADES } from                         '../../modules/nf-core/spades.nf'
include { BUSCO } from                          '../../modules/local/busco.nf'
include { BUSCO_SUMMARY } from                  '../../modules/local/busco_summary.nf'
include { CATPACK_CONTIGS } from                '../../modules/nf-core/cat_pack/contigs.nf'
include { READ_ABUNDANCE_ESTIMATION } from      '../../modules/local/read_abundance_estimation.nf'
include { MERGE_SAM_STATS } from                '../../modules/local/merge_sam_stats.nf'

workflow CONTIG_ANNOTATION {
    take:
    reads
    cat_pack_db
    busco_db

    main:
    ch_versions = Channel.empty()

    SPADES(
        reads, 
        []
    ).scaffolds.set { ch_scaffolds }
    ch_versions = ch_versions.mix(SPADES.out.versions)

    // BUSCO placeholder
    BUSCO(
        ch_scaffolds,
        busco_db.first()
    )
    ch_versions = ch_versions.mix(BUSCO.out.versions)
    
    BUSCO_SUMMARY(
        BUSCO.out.summary.collect{ it[1] }
    )

    CATPACK_CONTIGS(
        ch_scaffolds,
        // [], [], 
        cat_pack_db.first()
    )
    ch_versions = ch_versions.mix(CATPACK_CONTIGS.out.versions)

    READ_ABUNDANCE_ESTIMATION(
        reads,
        ch_scaffolds
    )
    ch_versions = ch_versions.mix(READ_ABUNDANCE_ESTIMATION.out.versions)

    MERGE_SAM_STATS(
        READ_ABUNDANCE_ESTIMATION.out.stats.collect{ it[1] }
    )
    ch_versions = ch_versions.mix(MERGE_SAM_STATS.out.versions)

    emit:
    assembly           = ch_scaffolds
    assembly_qc        = BUSCO_SUMMARY.out.busco_figure
    taxonomy           = CATPACK_CONTIGS.out.classification_with_names
    counts             = MERGE_SAM_STATS.out.merged_read_stats
    versions           = ch_versions
}