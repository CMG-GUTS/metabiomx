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
    if (!params.bypass_read_annotation) {
        """
        cat << 'EOF' > omicflow.R
        library('OmicFlow')

        set.seed(999)
        data.table::setDTthreads(${task.cpus})

        taxa <- metagenomics\$new(
            metaData = "${metadata_clean}",
            biomData = "${biom_taxonomy}"   
        )
        taxa\$normalize()
        taxa\$feature_subset(Kingdom == "k_bacteria")
        taxa\$normalize()
        taxa\$autoFlow(
            normalize = FALSE,
            cpus = ${task.cpus}
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
    } else if (!params.bypass_contig_annotation) {
        """
        cat << 'EOF' > omicflow.R
        library('OmicFlow')

        set.seed(999)
        data.table::setDTthreads(${task.cpus})

        taxa <- metagenomics\$new(
            metaData = "${metadata_clean}",
            biomData = "${biom_taxonomy}"   
        )
        taxa\$feature_subset(Kingdom == "Bacteria")
        taxa\$normalize()
        taxa\$feature_merge(
            feature_rank = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"),
            feature_filter = c(${params.filter_bacteria})
        )
        taxa\$feature_subset(V2 >= as.numeric(${params.coverage_threshold}))
        taxa\$autoFlow(
            normalize = FALSE,
            cpus = ${task.cpus}
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
    }

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