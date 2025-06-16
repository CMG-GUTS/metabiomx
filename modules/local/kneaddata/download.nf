process KNEADDATA_DOWNLOAD {
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
    # Search for any file ending with .bt2 under db_dir
    BT2_FILE=\$(find "\$db_dir" -type f -name "hg37*.bt2" -print -quit)

    if [ -n "\$BT2_FILE" ]; then
        echo ".bt2 file found: \$BT2_FILE"
    else
        echo "No .bt2 files found... Downloading kneaddata database"
        kneaddata_database --download $db_name $db_dir
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kneaddata: \$(echo \$(kneaddata --version 2>&1))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    mkdir -p $db_dir

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kneaddata: \$(echo \$(kneaddata --version 2>&1))
    END_VERSIONS
    """
}