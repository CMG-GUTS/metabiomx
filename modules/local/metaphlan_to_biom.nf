process METAPHLAN_TO_BIOM {
    label 'process_single'

    input:
    path(merged_metaphlan_table)

    output:
    path("*.biom")                          , emit: biom
    path("versions.yml")                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    python3.11 $projectDir/bin/python/biom_wrangler.py \\
        --i-tsv $merged_metaphlan_table

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3.11 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch metaphlan_with_taxonomy.biom

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3.11 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}