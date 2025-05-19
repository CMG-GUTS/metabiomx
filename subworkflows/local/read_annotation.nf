/*

    READ ANNOTATION

*/
include { INTERLEAVED }             from '../../modules/local/interleaved.nf'
include { HUMANN3 }                 from '../../modules/local/humann3.nf'
include { MERGE_HUMANN3_TABLES }    from '../../modules/local/merge_humann3_tables.nf'
include { METAPHLAN_TO_BIOM }       from '../../modules/local/metaphlan_to_biom.nf'

workflow READ_ANNOTATION {
    take:
    reads
    metaphlan_db
    humann_db

    main:
    ch_versions = Channel.empty()
    ch_metaphlan = Channel.empty()
    ch_humann = Channel.empty()
    
    INTERLEAVED(reads)

    HUMANN3(
        INTERLEAVED.out.interleaved_reads,
        humann_db.first(),
        metaphlan_db.first()
    )
    ch_versions = ch_versions.mix(HUMANN3.out.versions)

    MERGE_HUMANN3_TABLES(
        HUMANN3.out.genefamilies.collect{ it[1] },
        HUMANN3.out.pathabundance.collect{ it[1] },
        HUMANN3.out.pathcoverage.collect{ it[1] },
        HUMANN3.out.profiles.collect{ it[1] }
    )

    METAPHLAN_TO_BIOM(
        MERGE_HUMANN3_TABLES.out.merged_profiles
    )

    emit:
    interleaved             = INTERLEAVED.out.interleaved_reads
    humann3_genes           = MERGE_HUMANN3_TABLES.out.merged_genefamilies
    humann3_pathabundance   = MERGE_HUMANN3_TABLES.out.merged_pathabundance
    humann3_pathcoverage    = MERGE_HUMANN3_TABLES.out.merged_pathcoverage
    metaphlan_profiles      = MERGE_HUMANN3_TABLES.out.merged_profiles
    metaphlan_biom          = METAPHLAN_TO_BIOM.out.biom
    versions                = ch_versions 
}