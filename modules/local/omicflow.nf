process OMICFLOW {
    label 'process_low'

    input:
    path(metadata_clean)
    path(biom_taxonomy)
    path(rooted_tree_newick)

    output:
    path "report.html"              , emit: report
    path "versions.yml"             , emit: versions

    script:
    """
    autoflow \\
        --metadata ${metadata_clean} \\
        --biom ${biom_taxonomy} \\
        --tree ${rooted_tree_newick} \\
        --cpus ${task.cpus} \\
        --threads ${task.cpus}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R: \$(R --version | head -1)
        OmicFlow: \$(Rscript -e 'cat(as.character(packageVersion("OmicFlow")))')
    END_VERSIONS

    # Rewrite the R version
    sed -i.bak -E '
    /^ *R:/ s/(: *).*\\b([0-9]+\\.[0-9]+\\.[0-9]+)\\b.*/\\1 \\2/
    ' versions.yml

    """

    stub:
    """
    touch report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R: \$(R --version)
        OmicFlow: \$(Rscript -e 'cat(as.character(packageVersion("OmicFlow")))')
    END_VERSIONS
    """
}