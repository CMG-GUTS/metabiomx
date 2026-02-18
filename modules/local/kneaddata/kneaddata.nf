process KNEADDATA {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(reads)
    path(index)

    output:
    tuple val(meta), path("*kneaddata*.fastq.gz")   , emit: unmapped_reads
    tuple val(meta), path("*_kneaddata.log")        , emit: log
    path  "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    def reads_args = ""
    def read_output = ""
    def log = 'find ./ -type f -iname "*_kneaddata.log" -exec mv -t . {} +'
    if (meta.single_end) {
        reads_args = "--unpaired ${reads[0]}"
        read_output = 'find ./ -type f -iname "*kneaddata_unmatched*" -exec mv -t . {} +'
    } else {
        reads_args = "--input1 ${reads[0]} --input2 ${reads[1]}"
        read_output = 'find ./ -type f -iname "*kneaddata_paired*" -exec mv -t . {} +'
    }

    """
    kneaddata \\
        ${reads_args} \\
        -db ${index} \\
        --output ${prefix} \\
        -t ${task.cpus} \\
        --bypass-trf \\
        --bypass-trim \\
        ${args} \\
        ${args2}

    $read_output

    for file in *.fastq; do
        if [ -f "\$file" ]; then
            echo "Compressing \$file ..."
            gzip "\$file"
        else
            echo "No .fastq files found."
            break
        fi
    done

    ${log}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kneaddata: \$(kneaddata --version 2>&1 | sed -e "s/kneaddata v//g")
    END_VERSIONS

    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch "${prefix}_kneaddata_1.fastq.gz"
    touch "${prefix}_kneaddata_2.fastq.gz"
    touch "${prefix}_kneaddata.log"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kneaddata: stub-version
    END_VERSIONS
    """
}