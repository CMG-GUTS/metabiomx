process MULTIQC {
    label 'process_single'

    input:
    path  multiqc_files, stageAs: "?/*"
    path(multiqc_config)
    val software_versions
    path(extra_multiqc_config)
    path(multiqc_logo)
    path(replace_names)
    path(sample_names)

    output:
    path "*multiqc_report.html" , emit: report
    path "*_data"               , emit: data
    path "*_plots"              , optional:true, emit: plots
    path "versions.yml"         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def config = multiqc_config ? "--config $multiqc_config" : ''
    def extra_config = extra_multiqc_config ? "--config $extra_multiqc_config" : ''
    def logo = multiqc_logo ? "--cl-config 'custom_logo: \"${multiqc_logo}\"'" : ''
    def replace = replace_names ? "--replace-names ${replace_names}" : ''
    def samples = sample_names ? "--sample-names ${sample_names}" : ''

    def versionsEcho = software_versions.collect { versionMap ->
        versionMap.collect { process, versions ->
            versions.collect { tool, version ->
                "echo -e '${process}:${tool}\\t${version}' >> software_versions.tsv"
            }.join('\n')
        }.join('\n')
    }.join('\n')

    def paramsEcho = params.collect { k, v ->
        def valueString = v.toString().replaceAll('[\\n\\r]', ' ')
        "echo -e '${k}\\t${valueString}' >> pipeline_params.tsv"
    }.join('\n')
    """
    echo -e "Software\\tVersion" > software_versions.tsv
    ${versionsEcho}

    echo -e "Parameter\\tValue" > pipeline_params.tsv
    ${paramsEcho}

    multiqc \\
        --force \\
        $args \\
        $config \\
        $extra_config \\
        $logo \\
        $replace \\
        $samples \\
        .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """

    stub:
    """
    mkdir multiqc_data
    mkdir multiqc_plots
    touch multiqc_report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """
}