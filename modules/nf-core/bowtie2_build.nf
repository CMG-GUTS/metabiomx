process BOWTIE2_BUILD {
    tag "$fasta"
    label 'process_high'

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('bowtie2')    , emit: index
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    mkdir bowtie2
    bowtie2-build $args --threads $task.cpus $fasta bowtie2/${fasta.baseName}
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie2: \$(echo \$(bowtie2 --version 2>&1) | sed 's/^.*bowtie2-align-s version //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    """
    mkdir bowtie2
    touch bowtie2/${fasta.baseName}.{1..4}.bt2
    touch bowtie2/${fasta.baseName}.rev.{1,2}.bt2

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie2: \$(echo \$(bowtie2 --version 2>&1) | sed 's/^.*bowtie2-align-s version //; s/ .*\$//')
    END_VERSIONS
    """
}