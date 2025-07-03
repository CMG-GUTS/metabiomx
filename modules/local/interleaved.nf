process INTERLEAVED {
    tag "${meta.id}"
    label 'process_medium'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(new_meta), path("*interleaved*")  , emit: interleaved_reads
    path  "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args            = task.ext.args ?: ''
    def args2           = task.ext.args2 ?: ''
    def prefix          = task.ext.prefix ?: "${meta.id}"

    def reads_args = ""
    new_meta = meta.clone()
    if (new_meta.single_end) {
        reads_args = "in=${reads[0]}"
    } else {
        reads_args = "in1=${reads[0]} in2=${reads[1]}"
        new_meta.single_end = true
    }

    """
    reformat.sh \\
        $reads_args \\
        out=${prefix}_interleaved.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        reformat.sh: \$( reformat.sh --version | sed '/reformat.sh v/!d; s/.*v//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        reformat.sh: \$( reformat.sh --version | sed '/reformat.sh v/!d; s/.*v//' )
    END_VERSIONS
    """
}