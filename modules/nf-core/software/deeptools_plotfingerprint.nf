def SOFTWARE = 'deeptools'

process DEEPTOOLS_PLOTFINGERPRINT {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}/${options.publish_dir}${options.publish_by_id ? "/${meta.id}" : ''}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
                      if (options.publish_results == "none") null
                      else if (filename.endsWith('.version.txt')) null
                      else filename }

    container "quay.io/biocontainers/deeptools:3.4.3--py_0"
    //container "https://depot.galaxyproject.org/singularity/deeptools:3.4.3--py_0"

    conda (params.conda ? "bioconda::deeptools=3.4.3" : null)

    input:
    tuple val(meta), path(bams), path(bais)
    val options

    output:
    tuple val(meta), path("*.pdf"), emit: pdf
    tuple val(meta), path("*.raw.txt"), emit: matrix
    tuple val(meta), path("*.qcmetrics.txt"), emit: metrics
    path "*.version.txt", emit: version

    script:
    prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    extend = (meta.single_end && params.fragment_size > 0) ? "--extendReads ${params.fragment_size}" : ''
    """
    plotFingerprint \\
        $options.args \\
        $extend \\
        --bamfiles ${bams.join(' ')} \\
        --plotFile ${prefix}.plotFingerprint.pdf \\
        --outRawCounts ${prefix}.plotFingerprint.raw.txt \\
        --outQualityMetrics ${prefix}.plotFingerprint.qcmetrics.txt \\
        --numberOfProcessors $task.cpus

    plotFingerprint --version | sed -e "s/plotFingerprint //g" > ${SOFTWARE}.version.txt
    """
}