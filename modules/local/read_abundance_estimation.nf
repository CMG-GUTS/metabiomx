process READ_ABUNDANCE_ESTIMATION {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(reads)
    tuple val(meta1), path(fasta)

    output:
    tuple val(meta), path("*.sam")                  , emit: sam
    tuple val(meta), path("*.bam")                  , emit: bam            
    tuple val(meta), path("*.stats")                , emit: stats
    tuple val(meta), path("*.flags")                , emit: flags
    tuple val(meta), path("*.log")                  , emit: log
    path  "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def read_arg = meta.single_end ? "-U ${reads}" : "-1 ${reads[0]} -2 ${reads[1]}"

    """
    bowtie2-build $fasta ref
    bowtie2 \\
        --very-sensitive-local \\
        -p ${task.cpus} \\
        -x ref \\
        $read_arg \\
        -S ${prefix}.sam 2> cleaned.log

    samtools view -bS ${prefix}.sam | samtools sort - > ${prefix}.sorted.bam
    samtools index ${prefix}.sorted.bam

    samtools idxstats ${prefix}.sorted.bam > ${prefix}.stats
    samtools flagstat ${prefix}.sorted.bam > ${prefix}.flags

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie2: \$(echo \$(bowtie2 --version 2>&1))
        samtools: \$(echo \$(samtools --version 2>&1))
    END_VERSIONS
    """
}