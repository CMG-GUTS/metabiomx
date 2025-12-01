process BUSCO {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(contigs)
    path(busco_db)

    output:
    tuple val(meta), path("*_full_table.tsv")       , emit: full_table
    tuple val(meta), path("short_summary*")         , emit: summary
    path  "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    if [ -f ${contigs} ]; then
        gzip -dc ${contigs} > ${prefix}.fa
    fi

    busco \\
        --offline \\
        --in ${prefix}.fa \\
        --out ${prefix} \\
        --mode genome \\
        -l bacteria \\
        --download_path busco_downloads/ \\
        --cpu ${task.cpus}

    if [ -f ${prefix}/run_bacteria_odb12/full_table.tsv ]; then
        mv ${prefix}/run_bacteria_odb12/full_table.tsv ${prefix}_full_table.tsv
    fi

    if [ -f ${prefix}/short_summary.specific.*.*.txt ]; then
        mv ${prefix}/short_summary.specific.*.*.txt short_summary_${prefix}.txt
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco: \$(busco --version 2> /dev/null | sed 's/BUSCO //g' )
        python: \$(python --version)
        R: \$(R --version | head -1)
    END_VERSIONS

    sed -i.bak -E '
    /^ *python:/ s/(: *).*\\b([0-9]+\\.[0-9]+\\.[0-9]+)\\b.*/\\1 \\2/
    /^ *R:/ s/(: *).*\\b([0-9]+\\.[0-9]+\\.[0-9]+)\\b.*/\\1 \\2/
    ' versions.yml
    """
    
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    touch "${prefix}_full_table.tsv"
    touch "short_summary_${prefix}.txt"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco: stub-version
        python: stub-version
        R: stub-version
    END_VERSIONS
    """
}