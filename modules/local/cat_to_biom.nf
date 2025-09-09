process CAT_TO_BIOM {
    label 'process_single'

    input:
    path(tax_files)
    path(sam_stats)
    path(assemblies)

    output:
    path("CAT_with_taxonomy.biom")          , emit: biom
    path("*_renamed.fa.gz")                 , emit: renamed_scaffolds
    path("combined_scaffolds*")             , emit: combined_scaffolds
    path("versions.yml")                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    python3.11 $projectDir/bin/python/anot2biom.py \\
        --file-tax $tax_files \\
        --file-counts $sam_stats \\
        --file-fasta $assemblies \\
        --outdir .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3.11 --version | sed -e "s/Python //g")
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch CAT_with_taxonomy.biom
    touch scaffolds.fa.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3.11 --version | sed -e "s/Python //g")
    END_VERSIONS
    """
}