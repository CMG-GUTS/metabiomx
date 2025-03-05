process MERGE_MULTIQC_STATS {
    label 'process_single'

    input:
    path(raw_stats)
    path(trim_stats)
    path(decon_stats)

    output:
    path "merged_multiqc_stats.tsv", emit: read_stats
    path "versions.yml"         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def raw_report = raw_stats ? "--i-raw $raw_stats" : ""
    def trim_report = trim_stats ? "--i-trim $trim_stats" : ""
    def decon_report = decon_stats ? "--i-decon $decon_stats" : ""
    """
    python3 $projectDir/bin/python/merge_multiqc_stats.py \\
        $raw_report \\
        $trim_report \\
        $decon_report \\
        --outfile merged_multiqc_stats.tsv


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python3: \$( python3 --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """

    stub:
    """

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python3: \$( python3 --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """
}