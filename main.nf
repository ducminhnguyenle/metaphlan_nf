#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Include workflow
include { METAPHLAN_PROFILING } from "./workflows/metaphlan_profiling"

// Initiate the workflow
workflow {
    log.info """\
    M E T A P H L A N _ P R O F I L I N G - N F   P I P E L I N E
    ===================================
    data_dir            : ${params.data_dir}
    samplesheet         : ${params.samplesheet}
    mpa_db              : ${params.mpa_db}
    mpa_index           : ${params.mpa_index}
    pipeline_version    : ${params.pipeline_version}
    nextflow_version    : ${params.nextflow_version}
    """
    .stripIndent()
    
    // Run the workflow
    METAPHLAN_PROFILING()
}