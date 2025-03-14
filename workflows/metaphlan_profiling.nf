#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Include modules
include { FASTQC }              from "../modules/fastqc"
include { FASTP }               from "../modules/fastp"
include { METAPHLAN }           from "../modules/metaphlan"
include { MERGE_METAPHLAN }     from "../modules/merge_metaphlan"
include { REFORMAT_METAPHLAN }  from "../modules/reformat_metaphlan"
include { MULTIQC }             from "../modules/multiqc"
include { SOFTWARE_VERSIONS }   from "../modules/software_versions"

// Channel
//     .fromFilePairs(
//         "${params.fastq_dir}/*_{1,2}.fastq.gz",
//         checkIfExists: true
//     )
//     .ifEmpty{ exit 1, "Cannot find any read files in ${params.fastq_dir}! "}
//     .set { raw_ch }

workflow METAPHLAN_PROFILING {
    Channel
    .fromPath(params.samplesheet, checkIfExists: true)
    .splitCsv(header: true)
    .map { row ->
        def meta = [id: row.sample]
        // Handle for sample with single end read
        def reads = [ row.read1, row.read2 ].collect { it?.trim() }     // Remove extra whitespaces and prevent errors if read is empty
                .findAll { it }                                         // Remove empty values
                .collect { file(it) }                                   // Convert to file object
        // Validate at least read1 exists
        if (reads.isEmpty()) {
            exit 1, "Sample ${meta.id} has no valid read files specified in ${params.samplesheet}"
        }
        // Make a tuple for each sample with its corresponding SE/PE read
        [ meta, reads ]
    }
    .set { ch_reads }
    // ch_reads.view()
    FASTQC(ch_reads)
    FASTP(ch_reads)
    METAPHLAN(FASTP.out.reads)
    ch_merged_mpa = METAPHLAN.out.profile.collect { _meta, profile -> profile }
    MERGE_METAPHLAN(ch_merged_mpa)
    REFORMAT_METAPHLAN(MERGE_METAPHLAN.out.merged_mpa)
    
    // Softwares version
    ch_versions = Channel.empty()
    ch_versions = FASTQC.out.version
                    .mix(FASTP.out.version, METAPHLAN.out.version)
                    .flatten()
                    .unique{ it.getName() }
    SOFTWARE_VERSIONS(ch_versions.collect())

    // Multiqc
    ch_multiqc_config = Channel.fromPath("${projectDir}/assets/multiqc_config.yml", checkIfExists: true)

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect { _meta, zip -> zip })
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.json.collect { _meta, json -> json })
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.html.collect { _meta, html -> html })
    ch_multiqc_files = ch_multiqc_files.mix(METAPHLAN.out.profile.collect { _meta, profile -> profile })
    ch_multiqc_files = ch_multiqc_files.mix(SOFTWARE_VERSIONS.out.report.collect())

    MULTIQC(
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList()
    )
}

/*
 * LOG ON COMPLETION
 */
workflow.onComplete {
    if (workflow.stats.ignoredCount > 0 && workflow.success) {
      log.warn "Warning, pipeline completed, but with errored process(es)"
      log.info "Number of ignored errored process(es) : ${workflow.stats.ignoredCount}"
      log.info "Number of successfully ran process(es) : ${workflow.stats.succeedCount}"
    }
    if (workflow.success) {
        log.info "[metaphlan_profiling] Pipeline completed successfully"
    } else {
        log.warn "[metaphlan_profiling] Pipeline completed with errors"
    }
}