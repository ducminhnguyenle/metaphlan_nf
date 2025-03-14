// Gather software versions
process SOFTWARE_VERSIONS {
    cache false
    label 'process_low'
    publishDir "${params.data_dir}/pipeline_info", mode: "copy",
        saveAs: { it == "software_versions.csv" ? it : null}

    container "quay.io/biocontainers/python:3.12"
    conda "bioconda::python==3.12"

    input:
    path version_files

    output:
    path "software_versions_mqc.yml", emit: report
    path "software_versions.csv"

    script:
    """
    echo $params.pipeline_version > v_pipeline.txt
    echo $params.nextflow_version > v_nextflow.txt
    scrape_software_versions.py > software_versions_mqc.yml
    """
}