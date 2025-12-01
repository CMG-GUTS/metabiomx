process CATPACK_CONTIGS {
    tag "${meta.id}"
    label 'process_high'

    input:
    tuple val(meta), path(contigs)
    // tuple val(meta4), path(proteins)
    // tuple val(meta5), path(diamond_table)
    path(catpack_db)

    output:
    tuple val(meta), path("*.ORF2LCA.txt"), emit: orf2lca
    tuple val(meta), path("*.contig2classification.txt"), emit: contig2classification
    tuple val(meta), path("*_with_taxonomy.txt"), emit: classification_with_names
    tuple val(meta), path("*.log"), emit: log
    tuple val(meta), path("*.diamond"), optional: true, emit: diamond
    tuple val(meta), path("*.predicted_proteins.faa"), optional: true, emit: faa
    tuple val(meta), path("*.gff"), optional: true, emit: gff
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // def premade_proteins = proteins ? "--proteins_fasta ${proteins}" : ''
    // def premade_table = diamond_table ? "--diamond_alignment ${diamond_table}" : ''
    """
    TAX=`find -L $catpack_db -name "*.dmp" -print -quit | xargs -r dirname`
    [ -z "\$TAX" ] && echo "taxonomy index files not found" 1>&2 && exit 1

    DB=`find -L $catpack_db -name "*.dmnd" -print -quit | xargs -r dirname`
    [ -z "\$DB" ] && echo "database index files not found" 1>&2 && exit 1

    if [ -f ${contigs} ]; then
        gzip -dc ${contigs} > ${prefix}.fa
    fi

    CAT_pack contigs \\
        --nproc ${task.cpus} \\
        --contigs_fasta ${prefix}.fa \\
        --database_folder \$DB \\
        --taxonomy_folder \$TAX \\
        --out_prefix ${prefix} \\
        ${args}

    CAT_pack add_names \\
        -i *.contig2classification.txt \\
        -t \$TAX \\
        -o ${prefix}_with_taxonomy.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        catpack: \$(CAT_pack --version | sed 's/CAT_pack pack v//g;s/ .*//g')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch "${prefix}_with_taxonomy.txt"
    touch "${prefix}.ORF2LCA.txt"
    touch "${prefix}.contig2classification.txt"
    touch "${prefix}.log"
    touch "${prefix}.diamond"
    touch "${prefix}.predicted_proteins.faa"
    touch "${prefix}.predicted_proteins.gff"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        catpack: stub-version
    END_VERSIONS
    """
}