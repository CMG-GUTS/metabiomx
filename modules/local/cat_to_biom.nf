process CAT_TO_BIOM {
    label 'process_single'

    input:
    path(tax_files)
    path(sam_stats)

    output:
    path("CAT_with_taxonomy.biom")          , emit: biom
    path("versions.yml")                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    python3 $projectDir/bin/python/anot2biom.py \\
        --file-tax $tax_files \\
        --file-counts $sam_stats \\
        --outdir .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch CAT_with_taxonomy.biom

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}