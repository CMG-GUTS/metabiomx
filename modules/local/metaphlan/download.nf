process METAPHLAN_DOWNLOAD {
    label 'process_single'

    input:
    val(db_name)
    path(db_dir)

    output:
    path db_dir             , emit: db_dir_out 
    path "versions.yml"     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    # Search for any file ending with .bt2l under db_dir
    BT2_FILE=\$(find -L ${db_dir} -type f -name "${db_name}*" -print -quit)

    if [ -n "\$BT2_FILE" ]; then
        echo "${db_name} file found: \$BT2_FILE"
    else
        echo "No ${db_name} files found."
        echo "... Downloading latest metaphlan database"
        wget http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/${db_name}.tar \\
            && tar -xvf ${db_name}.tar -C ${db_dir} \\
            && rm ${db_name}.tar

        wget http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/bowtie2_indexes/${db_name}_bt2.tar \\
            && tar -xvf ${db_name}_bt2.tar -C ${db_dir} \\
            && rm ${db_name}_bt2.tar

        echo '${db_name}' > ${db_dir}/mpa_latest
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
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        humann3: \$(humann --version 2>&1 | awk '{print \$3}')
        diamond: \$(diamond --version 2>&1 | awk '{print \$3}')
        metaphlan3: \$(metaphlan --version 2>&1 | awk '{print \$3}')
        bowtie2: \$(bowtie2 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}