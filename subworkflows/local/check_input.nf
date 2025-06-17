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

    emit:
    meta                    = meta_ch
}