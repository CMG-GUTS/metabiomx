process MERGE_SAM_STATS {
    label 'process_single'

    input:
    path(sam_stats)

    output:
    path("merged_read_stats.tsv")          , emit: merged_read_stats
    path "versions.yml"                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def filename = 'merged_read_stats.tsv'

    """
    python3 $projectDir/bin/python/merge_sam_stats.py \\
        -i ${sam_stats} \\
        -o ${filename}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch merged_tables.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}