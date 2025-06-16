process BUSCO_DOWNLOAD {
    tag "$lineage"
    label 'process_single'

    input:
    val(lineage)
    path(db_dir)

    output:
    path "versions.yml"   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    # Find full path to lineage directory
    LINEAGE_DIR=\$(find "\$db_dir" -type d -name "\$lineage" -print -quit)

    if [ -z "\$LINEAGE_DIR" ]; then
        echo "Lineage directory '\$lineage' not found under \$db_dir."
        MISSING=1
    else
        echo "Found lineage directory: \$LINEAGE_DIR"

        # Check for 'hmms' directory
        if [ -d "\$LINEAGE_DIR/hmms" ]; then
            echo "'hmms' directory exists."
        else
            echo "'hmms' directory missing."
            MISSING=1
        fi

        # Check for required files
        for file in ancestral ancestral_variants dataset.cfg scores_cutoff; do
            if [ -f "\$LINEAGE_DIR/\$file" ]; then
                echo "File '\$file' exists."
            else
                echo "File '\$file' missing."
                MISSING=1
            fi
        done
    fi

    # If any required item is missing, proceed with download
    if [ "\$MISSING" = "1" ]; then
        echo "Some required files or directories are missing. Downloading database..."
        busco \\
            --download $lineage \\
            --download_path $db_dir
            $args
    else
        echo "All required files and directories are present. Skipping download."
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco: \$( busco --version 2> /dev/null | sed 's/BUSCO //g' )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    mkdir busco_downloads

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco: \$( busco --version 2> /dev/null | sed 's/BUSCO //g' )
    END_VERSIONS
    """
}