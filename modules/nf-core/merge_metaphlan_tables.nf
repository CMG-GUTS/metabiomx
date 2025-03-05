process METAPHLAN_MERGEMETAPHLANTABLES {
    label 'process_single'

    input:
    path(profiles)

    output:
    path("merged_tables.tsv")              , emit: merged_profiles
    path "versions.yml"                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    merge_metaphlan_tables.py \\
        ${profiles} -o merged_tables.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan4: \$(metaphlan --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch merged_tables.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan4: \$(metaphlan --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}