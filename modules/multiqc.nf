process MULTIQC {
    publishDir "${params.data_dir}/multiqc", mode: "copy"
    label 'process_low'

    container "quay.io/biocontainers/multiqc:1.27.1--pyhdfd78af_0"
    conda "bioconda::multiqc=1.27.1"

    input:
    path multiqc_files
    path (multiqc_config)
    
    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data
    path "*_plots"             , optional:true, emit: plots
    
    script:
    
    """
    multiqc \
        . \
        -f \
        --config "${multiqc_config}"
    """
}