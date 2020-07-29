def SOFTWARE = 'picard'

process PICARD_COLLECTMULTIPLEMETRICS {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}/${options.publish_dir}${options.publish_by_id ? "/${meta.id}" : ''}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
                      if (options.publish_results == "none") null
                      else if (filename.endsWith('.version.txt')) null
                      else filename }

    container "quay.io/biocontainers/picard:2.23.2--0"
    //container "https://depot.galaxyproject.org/singularity/picard:2.23.2--0"

    conda (params.conda ? "bioconda::picard=2.23.2" : null)

    input:
    tuple val(meta), path(bam)
    path fasta
    val options

    output:
    tuple val(meta), path("*_metrics"), emit: metrics
    tuple val(meta), path("*.pdf"), emit: pdf
    path "*.version.txt", emit: version

    script:
    prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def avail_mem = 3
    if (!task.memory) {
        log.info '[Picard CollectMultipleMetrics] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = task.memory.giga
    }
    """
    picard \\
        -Xmx${avail_mem}g \\
        CollectMultipleMetrics \\
        $options.args \\
        INPUT=$bam \\
        OUTPUT=${prefix}.CollectMultipleMetrics \\
        REFERENCE_SEQUENCE=$fasta

    echo \$(picard CollectMultipleMetrics --version 2>&1) | awk -F' ' '{print \$NF}' > ${SOFTWARE}.version.txt
    """
}
