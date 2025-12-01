process OMICFLOW_read {
    label 'process_low'

    input:
    path(metadata_clean)
    path(biom_taxonomy)
    path(rooted_tree_newick)

    output:
    path "read_annotated_report.html"   , emit: report
    path "versions.yml"                 , emit: versions

    script:
    """
    cat << 'EOF' > omicflow.R
    library('OmicFlow')
    library('ggplot2')

    set.seed(999)
    data.table::setDTthreads(${task.cpus})
    filter_value <- unlist(strsplit("${params.filter_bacteria}", ",\\\s*"))

    taxa <- metagenomics\$new(
        metaData = "${metadata_clean}",
        biomData = "${biom_taxonomy}"   
    )
    taxa\$normalize()
    taxa\$feature_subset(Kingdom == "k__Bacteria")
    taxa\$normalize()
    taxa\$autoFlow(
        normalize = FALSE,
        cpus = ${task.cpus},
        feature_filter = filter_value
    )
    EOF

    Rscript omicflow.R
    mv report.html read_annotated_report.html

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
        R: stub-version
        OmicFlow: stub-version
    END_VERSIONS
    """
}