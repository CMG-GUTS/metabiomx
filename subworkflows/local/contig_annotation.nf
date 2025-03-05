/*

    CONTIG ANNOTATION

*/
include { SPADES } from                         '../../modules/nf-core/spades.nf'
include { CATPACK_CONTIGS } from                '../../modules/nf-core/cat_pack/contigs.nf'
include { READ_ABUNDANCE_ESTIMATION } from      '../../modules/local/read_abundance_estimation.nf'
include { MERGE_SAM_STATS } from                '../../modules/local/merge_sam_stats.nf'

workflow CONTIG_ANNOTATION {
    take:
    reads
    cat_pack_db

    main:
    ch_versions = Channel.empty()

    SPADES(
        reads, 
        []
    ).scaffolds.set { ch_scaffolds }
    ch_versions = ch_versions.mix(SPADES.out.versions)

    CATPACK_CONTIGS(
        ch_scaffolds,
        // [], [], 
        cat_pack_db
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
    taxonomy           = CATPACK_CONTIGS.out.classification_with_names
    counts             = MERGE_SAM_STATS.out.merged_read_stats
    versions           = ch_versions
}