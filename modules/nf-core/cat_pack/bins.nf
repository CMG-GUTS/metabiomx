process CATPACK_BINS {
    tag "${meta.id}"
    label 'process_medium'

    input:
    tuple val(meta), path(bins, stageAs: 'bins/*')
    tuple val(meta2), path(database)
    tuple val(meta3), path(taxonomy)
    tuple val(meta4), path(proteins)
    tuple val(meta5), path(diamond_table)

    output:
    tuple val(meta), path("*.ORF2LCA.txt"), emit: orf2lca
    tuple val(meta), path("*.bin2classification.txt"), emit: bin2classification
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
    def premade_proteins = proteins ? "-p ${proteins}" : ''
    def premade_table = diamond_table ? "-d ${diamond_table}" : ''
    """
    CAT_pack bins \\
        -n ${task.cpus} \\
        -b bins/ \\
        -d ${database} \\
        -t ${taxonomy} \\
        ${premade_proteins} \\
        ${premade_table} \\
        -o ${prefix} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        catpack: \$(CAT_pack --version | sed 's/CAT_pack pack v//g;s/ .*//g')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.ORF2LCA.txt
    touch ${prefix}.bin2classification.txt
    touch ${prefix}.log
    touch ${prefix}.diamond
    touch ${prefix}.predicted_proteins.faa
    touch ${prefix}.predicted_proteins.gff

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        catpack: \$(CAT_pack --version | sed 's/CAT_pack pack v//g;s/ .*//g')
    END_VERSIONS
    """
}