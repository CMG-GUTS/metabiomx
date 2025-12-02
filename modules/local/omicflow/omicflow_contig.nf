process OMICFLOW_contig {
    label 'process_low'

    input:
    path(metadata_clean)
    path(biom_taxonomy)
    path(rooted_tree_newick)

    output:
    path "contig_annotated_report.html"     , emit: report
    path "versions.yml"                     , emit: versions

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
    taxa\$feature_subset(Kingdom == "Bacteria")
    taxa\$normalize()
    taxa\$feature_merge(
        feature_rank = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"),
        feature_filter = filter_value
    )
    taxa\$feature_subset(V2 >= as.numeric(${params.coverage_threshold}))
    taxa\$autoFlow(
        normalize = FALSE,
        threads = ${task.cpus}
    )
    EOF

    Rscript omicflow.R
    mv report.html contig_annotated_report.html

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
    touch contig_annotated_report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R: stub-version
        OmicFlow: stub-version
    END_VERSIONS
    """
}