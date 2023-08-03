process HOMER_DETAIL_ANNOTATEPEAKS {
    tag "$meta.id"
    label 'process_medium'

    // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    conda "bioconda::homer=4.11"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/homer:4.11--pl526hc9558a2_3' :
        'biocontainers/homer:4.11--pl526hc9558a2_3' }"

    input:
    tuple val(meta), path(peak)
    val genome

    output:
    tuple val(meta), path("*annotatePeaks.detailed.txt"), emit: txt
    path  "versions.yml"                                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '4.11' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    installed=\$(configureHomer.pl -list)
    line=\$(echo "\$installed" | grep "$genome")
    yes_or_no=\${line:0:1}

    if [ \$yes_or_no != "+" ]; then
        configureHomer.pl -install $genome
    fi

    annotatePeaks.pl \\
        $peak \\
        $genome \\
        $args \\
        -cpu $task.cpus \\
        > ${prefix}.annotatePeaks.detailed.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        homer: $VERSION
    END_VERSIONS
    """
}
