process HUMANN_DOWNLOAD {
    label 'process_single'

    input:
    path(db_dir)

    output:
    path db_dir             , emit: db_dir_out 
    path "versions.yml"     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    # Check chocophlan for *.ffn.gz files (should be around 12773)
    CHOCO_COUNT=0
    if [ -d "${db_dir}/chocophlan" ]; then
        CHOCO_COUNT=\$(find "${db_dir}/chocophlan" -type f -name "*.ffn.gz" | wc -l)
    fi

    if [ "\$CHOCO_COUNT" -ge 12770 ] && [ "\$CHOCO_COUNT" -le 12776 ]; then
        echo "chocophlan: Found \$CHOCO_COUNT *.ffn.gz files (expected ~12773)."
    else
        echo "chocophlan: Found \$CHOCO_COUNT *.ffn.gz files (expected ~12773)."
        echo "... Downloading Chocophlan full database"
        humann_databases --download chocophlan full ${db_dir} --update-config no
    fi

    # Check uniref90 for .dmnd file
    UNIREF_DMND=""
    if [ -d "${db_dir}/uniref" ]; then
        UNIREF_DMND=\$(find "${db_dir}/uniref" -type f -name "*.dmnd" -print -quit)
    fi
    
    if [ -n "\$UNIREF_DMND" ]; then
        echo "uniref: .dmnd file found (\$UNIREF_DMND)."
    else
        echo "uniref: .dmnd file missing."
        echo "... Downloading Uniref90 diamond database"
        humann_databases --download uniref uniref90_diamond ${db_dir} --update-config no
    fi

    # Check utility_mapping for map*.bz2 and map*.txt.gz files
    MAP_BZ2=""
    MAP_TXT_GZ=""
    if [ -d "${db_dir}/utility_mapping" ]; then
        MAP_BZ2=\$(find "${db_dir}/utility_mapping" -type f -name "map*.bz2" -print -quit)
        MAP_TXT_GZ=\$(find "${db_dir}/utility_mapping" -type f -name "map*.txt.gz" -print -quit)
    fi

    if [ -n "\$MAP_BZ2" ] && [ -n "\$MAP_TXT_GZ" ]; then
        echo "utility_mapping: files found (\$MAP_BZ2), (\$MAP_TXT_GZ)."
    else
        echo "Required utility mappings files not found"
        echo "... Downloading utility mapping database"
        humann_databases --download utility_mapping full ${db_dir} --update-config no
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
    mkdir -p ${db_dir}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        humann3: \$(humann --version 2>&1 | awk '{print \$3}')
        diamond: \$(diamond --version 2>&1 | awk '{print \$3}')
        metaphlan3: \$(metaphlan --version 2>&1 | awk '{print \$3}')
        bowtie2: \$(bowtie2 --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}