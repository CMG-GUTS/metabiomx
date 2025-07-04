process TRIMMOMATIC {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_paired_trim*.fastq.gz")   , emit: trimmed_reads
    tuple val(meta), path("*_unpaired_trim_*.fastq.gz"), emit: unpaired_reads, optional:true
    tuple val(meta), path("*_trim.log")                , emit: trim_log
    tuple val(meta), path("*_out.log")                 , emit: out_log
    tuple val(meta), path("*.summary")                 , emit: summary
    path "versions.yml"                                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def trimmed = meta.single_end ? "SE" : "PE"
    def output = meta.single_end ?
        "${prefix}_SE_paired_trim.fastq.gz" // HACK to avoid unpaired and paired in the trimmed_reads output
        : "${prefix}_paired_trim_1.fastq.gz ${prefix}_unpaired_trim_1.fastq.gz ${prefix}_paired_trim_2.fastq.gz ${prefix}_unpaired_trim_2.fastq.gz"
    def qual_trim = task.ext.args2 ?: ''
    """
    trimmomatic \\
        $trimmed \\
        -threads $task.cpus \\
        -trimlog ${prefix}_trim.log \\
        -summary ${prefix}.summary \\
        $reads \\
        $output \\
        $qual_trim \\
        $args 2> >(tee ${prefix}_out.log >&2)

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimmomatic: \$(trimmomatic -version)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    if (meta.single_end) {
        output_command = "echo '' | gzip > ${prefix}_SE_paired.trim.fastq.gz"
    } else {
        output_command  = "echo '' | gzip > ${prefix}_paired_trim_1.fastq.gz\n"
        output_command += "echo '' | gzip > ${prefix}_paired_trim_2.fastq.gz\n"
        output_command += "echo '' | gzip > ${prefix}_unpaired_trim_1.fastq.gz\n"
        output_command += "echo '' | gzip > ${prefix}_unpaired_trim_2.fastq.gz"
    }

    """
    $output_command
    touch ${prefix}.summary
    touch ${prefix}_trim.log
    touch ${prefix}_out.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimmomatic: \$(trimmomatic -version)
    END_VERSIONS
    """

}