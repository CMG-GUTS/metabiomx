process METAPHLAN4 {
    tag "$meta.id"
    label 'process_high'

    input:
    tuple val(meta), path(input)
    path metaphlan_db

    output:
    path("*_profile.txt")                    ,                emit: single_profiles
    tuple val(meta), path("*.biom")          ,                emit: biom
    tuple val(meta), path('*.bowtie2out.txt'), optional:true, emit: bt2out
    path "versions.yml"                      ,                emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def input_type  = ("$input".endsWith(".fastq.gz") || "$input".endsWith(".fq.gz")) ? "--input_type fastq" :  ("$input".contains(".fasta")) ? "--input_type fasta" : ("$input".endsWith(".bowtie2out.txt")) ? "--input_type bowtie2out" : "--input_type sam"
    def input_data  = ("$input_type".contains("fastq")) && !meta.single_end ? "${input[0]},${input[1]}" : "${input[0]}"
    
    """
    metaphlan \\
        --nproc $task.cpus \\
        $input_type \\
        $input_data \\
        $args \\
        --bowtie2out ${prefix}_bt2out.txt \\
        --bowtie2db ${metaphlan_db} \\
        --biom ${prefix}.biom \\
        --offline \\
        --output_file ${prefix}_profile.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan4: \$(metaphlan --version 2>&1 | awk '{print \$3}')
        bowtie2: \$(bowtie2 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}