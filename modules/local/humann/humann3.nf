process HUMANN3 {
    tag "$meta.id"
    label 'process_high'

    input:
    tuple val(meta), path(reads)
    path(humann_index)
    path(metaphlan_index)

    output:
    tuple val(meta), path("*_genefamilies.tsv")         , emit: genefamilies  
    tuple val(meta), path("*_pathabundance.tsv")        , emit: pathabundance
    tuple val(meta), path("*_pathcoverage.tsv")         , emit: pathcoverage
    tuple val(meta), path("*_metaphlan_bugs_list.tsv")  , emit: profiles
    path "versions.yml"                                 , emit: versions  

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}" 

    """
    CHOCO=`find -L $humann_index -name "*.ffn.gz" -print -quit | xargs -r dirname`
    [ -z "\$CHOCO" ] && echo "chocophlan index files not found" 1>&2 && exit 1

    UNIREF=`find -L $humann_index -name "*.dmnd" -print -quit | xargs -r dirname`
    [ -z "\$UNIREF" ] && echo "uniref index files not found" 1>&2 && exit 1

    MAPPING=`find -L $humann_index -name "*.txt.gz" -print -quit | xargs -r dirname`
    [ -z "\$MAPPING" ] && MAPPING=`find -L ./ -name "*.txt.bz2" -print -quit | xargs -r dirname`
    [ -z "\$MAPPING" ] && MAPPING=`find -L ./ -name "*.dat.bz2" -print -quit | xargs -r dirname`
    [ -z "\$MAPPING" ] && echo "mapping index files not found" 1>&2 && exit 1

    humann3 \\
        --input ${reads[0]} \\
        --output . \\
        --output-basename $prefix \\
        --nucleotide-database \$CHOCO  \\
        --protein-database \$UNIREF \\
        --metaphlan-options "--bowtie2db ${metaphlan_index} --offline" \\
        --threads ${task.cpus} \\
        --o-log ${prefix}.log

    find ./ -name "*_metaphlan_bugs_list.tsv" -exec mv {} . \\;
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        humann3: \$(humann3 --version | sed -e "s/humann v//g")
        diamond: \$(diamond --version 2>&1 | awk '{print \$3}')
        metaphlan3: \$(metaphlan --version 2>&1 | awk '{print \$3}')
        bowtie2: \$(bowtie2 --version 2>&1 | head -1 | awk '{print \$3}')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}" 
    """
    touch "${prefix}_genefamilies.tsv"
    touch "${prefix}_pathabundance.tsv"
    touch "${prefix}_pathcoverage.tsv"
    touch "${prefix}_metaphlan_bugs_list.tsv"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        humann3: stub-version
        diamond: stub-version
        metaphlan3: stub-version
        bowtie2: stub-version
    END_VERSIONS
    """
}