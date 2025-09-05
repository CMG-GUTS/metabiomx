process CREATE_ANALYSIS_MAPPING {
    label 'process_single'

    input:
    val(mapping_rows)

    output:
    path("metadata.tsv")             , emit: mapping

    script:
    // Get the columns to keep
    def keep_columns = mapping_rows[0].keySet().findAll { 
        it == 'sample_id' || it.startsWith('CONTRAST_') || it.startsWith('VARIABLE_')
    }

    // Build header
    def header = keep_columns.collect { it == 'sample_id' ? 'SAMPLE_ID' : it }.join('\t')

    // Build body rows
    def rows_str = mapping_rows.collect { row -> 
        keep_columns.collect { col -> row[col] }.join('\t')
    }.join('\n')

    """
    echo "${header}" > metadata.tsv
    echo "${rows_str}" >> metadata.tsv
    """
}
