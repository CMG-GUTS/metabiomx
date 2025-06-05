/*

    Fetches sample reads and puts them into the right structure
    
*/

include { samplesheetToList } from 'plugin/nf-schema'

workflow CHECK_INPUT {

    main:
    if (params.input) {
        def input = file("${params.input}", checkIfExists: true)
        def schema = file("${projectDir}/assets/schema_input.json", checkIfExists: true)
        def sample_ch = Channel.fromList(samplesheetToList(input, schema))

        meta_ch = sample_ch.map { arrayList ->
            def sample = arrayList[0]
            def files = params.singleEnd ? arrayList[1] : arrayList[1..2]
            def meta = [:]
            meta.id = sample.id
            meta.single_end = params.singleEnd
        return tuple(meta, files)
        }

    log.info "meta channel from samplesheet"

    } else if (params.reads) {
        sample_ch = Channel
            .fromFilePairs(params.reads, size: params.singleEnd ? 1 : 2, checkIfExists: true)
            .ifEmpty { exit 1, 'Cannot find any reads matching: ${reads}\n'}
        meta_ch = sample_ch.map { arrayList ->
            def sample_id = arrayList[0]
            def files = arrayList[1]
            def meta = [:]
            meta.id = sample_id
            meta.single_end = params.singleEnd
            return tuple(meta, files)
        }

        log.info "meta channel from directory"
    }

    bowtie_ch = Channel
        .fromPath(params.bowtie_db)
        .ifEmpty { exit 1, 'Cannot find directory: ${params.bowtie_db}\n'}

    metaphlan_ch = Channel
        .fromPath(params.metaphlan_db)
        .ifEmpty { exit 1, 'Cannot find directory: ${params.metaphlan_db}\n'}

    humann_ch = Channel
        .fromPath(params.humann_db)
        .ifEmpty { exit 1, 'Cannot find directory: ${params.humann_db}\n'}

    nr_ch = Channel
        .fromPath(params.cat_pack_db)
        .ifEmpty { exit 1, 'Cannot find directory: ${params.cat_pack_db}\n'}

    busco_ch = Channel
        .fromPath(params.busco_db)
        .ifEmpty { exit 1, 'Cannot find directory: ${params.busco_db}\n'}

    emit:
    meta                    = meta_ch
    bowtie_db               = bowtie_ch
    metaphlan_db            = metaphlan_ch
    humann_db               = humann_ch
    catpack_db              = nr_ch
    busco_db                = busco_ch
}