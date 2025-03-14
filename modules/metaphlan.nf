process METAPHLAN {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.data_dir}/metaphlan/${meta.id}", mode: "copy", overwrite: true,
        saveAs: { it == "v_metaphlan.txt" ? null : it }

    container "quay.io/biocontainers/metaphlan:4.1.1--pyhdfd78af_0"
    conda "bioconda::metaphlan=4.1.1"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_profile.txt"),     emit: profile
    tuple val(meta), path("*.biom"),            emit: biom
    tuple val(meta), path("*.bowtie2out.txt"),  emit: bt2out
    path "v_metaphlan.txt",                     emit: version

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def input_data = reads instanceof Path || reads.size() == 1 ? "${reads}" : "${reads[0]},${reads[1]}"

    """
    metaphlan \
        --nproc ${task.cpus} \
        --input_type fastq \
        ${input_data} \
        --bowtie2out "${prefix}.bowtie2out.txt" \
        --index "${params.mpa_index}" \
        --bowtie2db "${params.mpa_db}" \
        --output_file "${prefix}_profile.txt" \
        --biom "${prefix}.biom" \
        --unclassified_estimation --add_viruses
    
    metaphlan --version | awk '{print \$1,\$3}' > v_metaphlan.txt
    """
}