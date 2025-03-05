/*

    Fetches sample reads and puts them into the right structure
    
*/

workflow CHECK_INPUT {
    take:
    reads
    singleEnd
    bowtie_db
    metaphlan_db
    humann_db
    catpack_db

    main:
    if (singleEnd) {
        sample_ch = Channel
            .fromPath(reads)
            .ifEmpty { exit 1, 'Cannot find any reads matching: ${reads}\n'}

    } else if (!singleEnd) {
        sample_ch = Channel
            .fromFilePairs(reads)
            .ifEmpty { exit 1, 'Cannot find any reads matching: ${reads}\n'}
    }

    bowtie_ch = Channel
        .fromPath(bowtie_db)
        .ifEmpty { exit 1, 'Cannot find directory: ${bowtie_db}\n'}

    metaphlan_ch = Channel
        .fromPath(metaphlan_db)
        .ifEmpty { exit 1, 'Cannot find directory: ${metaphlan_db}\n'}

    humann_ch = Channel
        .fromPath(humann_db)
        .ifEmpty { exit 1, 'Cannot find directory: ${humann_db}\n'}

    nr_ch = Channel
        .fromPath(catpack_db)
        .ifEmpty { exit 1, 'Cannot find directory: ${catpack_db}\n'}

    meta_ch = sample_ch.map { arrayList ->
        def sample_id = arrayList[0]
        def files = arrayList[1]
        def meta = [:]
        meta.id = sample_id
        meta.single_end = params.singleEnd
        return tuple(meta, files)
    }

    emit:
    meta                    = meta_ch
    bowtie_db               = bowtie_ch
    metaphlan_db            = metaphlan_ch
    humann_db               = humann_ch
    catpack_db              = nr_ch
}