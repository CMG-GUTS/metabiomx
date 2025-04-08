process BUSCO_SUMMARY {
    label 'process_single'

    input:
    path(summaries)

    output:
    path "busco_figure.png" , emit: busco_figure
    path "versions.yml"     , emit: versions

    script:

    """
    generate_plot.py -wd .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(echo \$(python --version 2>&1))
        R: \$(echo \$(R --version 2>&1))
    END_VERSIONS
    """
}
