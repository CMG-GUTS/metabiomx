process MERGE_HUMANN3_TABLES {
    label 'process_single'

    input:
    path(genefamilies)
    path(pathabundance)
    path(pathcoverage)
    path(profiles)

    output:
    path("merged_genefamilies.tsv")        , optional:true, emit: merged_genefamilies
    path("merged_pathabundance.tsv")       , optional:true, emit: merged_pathabundance
    path("merged_pathcoverage.tsv")        , optional:true, emit: merged_pathcoverage
    path("merged_metaphlan_tables.tsv")    , optional:true, emit: merged_profiles
    path "versions.yml"                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    humann_join_tables -i . -o merged_genefamilies.tsv --file_name genefamilies
    humann_join_tables -i . -o merged_pathabundance.tsv --file_name pathabundance
    humann_join_tables -i . -o merged_pathcoverage.tsv --file_name pathcoverage

    merge_metaphlan_tables.py \\
        ${profiles} -o merged_metaphlan_tables.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan3: \$(metaphlan --version 2>&1 | awk '{print \$3}')
        humann3: \$(humann3 --version | sed -e "s/humann v//g")
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch merged_genefamilies.tsv
    touch merged_pathabundance.tsv
    touch merged_pathcoverage.tsv
    touch merged_metaphlan_tables.tsv 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan4: \$(metaphlan --version 2>&1 | awk '{print \$3}')
        humann3: \$(humann3 --version | sed -e "s/humann v//g")
    END_VERSIONS
    """
}