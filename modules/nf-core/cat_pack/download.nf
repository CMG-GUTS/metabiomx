process CATPACK_DOWNLOAD {
    tag "$db_name"
    label 'process_single'

    input:
    val(db_name)
    path(db_dir)

    output:
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    # Check taxonomy files
    TAX=\$(find -L $db_dir -name "*.dmp" -print -quit)
    # Check database files
    DB=\$(find -L $db_dir -name "*.dmnd" -print -quit)

    if [ -n "\$TAX" ] && [ -n "\$DB" ]; then
        echo "All required files are present. Skipping download."
    else
        echo "Required files missing. Downloading database..."
        mkdir -p $db_dir
        CAT_pack \\
            download \\
            ${args} \\
            --db ${db_name}
            -o ${db_dir}/
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        catpack: \$(CAT_pack --version | sed 's/CAT_pack pack v//g;s/ .*//g')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    echo "CAT_pack \\
        download \\
        ${args} \\
        --db ${db_name}
        -o ${db_dir}/"

    mkdir ${db_dir}/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        catpack: \$(CAT_pack --version | sed 's/CAT_pack pack v//g;s/ .*//g')
    END_VERSIONS
    """
}