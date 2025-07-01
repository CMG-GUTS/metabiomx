process METAPHLAN_DOWNLOAD {
    label 'process_single'

    input:
    path(db_dir)

    output:
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    # Search for any file ending with .bt2l under db_dir
    BT2_FILE=\$(find -L ${db_dir} -type f -name "*CHOCOPhlAnSGB*.bt2l" -print -quit)

    if [ -n "\$BT2_FILE" ]; then
        echo ".bt2l file found: \$BT2_FILE"
    else
        echo "No .bt2l files found."
        echo "... Downloading latest metaphlan database"
        metaphlan --install --bowtie2db $db_dir
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        humann3: \$(humann --version 2>&1 | awk '{print \$3}')
        diamond: \$(diamond --version 2>&1 | awk '{print \$3}')
        metaphlan3: \$(metaphlan --version 2>&1 | awk '{print \$3}')
        bowtie2: \$(bowtie2 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    mkdir -p $db_dir

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        humann3: \$(humann --version 2>&1 | awk '{print \$3}')
        diamond: \$(diamond --version 2>&1 | awk '{print \$3}')
        metaphlan3: \$(metaphlan --version 2>&1 | awk '{print \$3}')
        bowtie2: \$(bowtie2 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}