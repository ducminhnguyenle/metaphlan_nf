process FASTQC {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.data_dir}/fastqc/${meta.id}", mode: "copy", pattern: "*{html,zip}"
    
    container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"
    conda "bioconda::fastqc=0.12.1"

    input:
    tuple val(meta), path(reads)
    
    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip"), emit: zip
    path "v_fastqc.txt", emit: version
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def old_new_pairs = reads instanceof Path || reads.size() == 1 ? [[ reads, "${prefix}.fastq.${reads.extension}" ]] : reads.withIndex().collect { entry, index -> [ entry, "${prefix}_${index + 1}.${entry.baseName.split('\\.').last()}.${entry.extension}" ] }
    def rename_to = old_new_pairs*.join(" ").join(" ")
    def renamed_files = old_new_pairs.collect { _old_name, new_name -> new_name }.join(" ")
    // Dividing the task.memory by task.cpu allows to stick to requested amount of RAM in the label
    def memory_in_mb = MemoryUnit.of("${task.memory}").toUnit('MB') / task.cpus
    // FastQC memory value allowed range (100 - 10000)
    def fastqc_memory = memory_in_mb > 10000 ? 10000 : (memory_in_mb < 100 ? 100 : memory_in_mb)
    """
    printf "%s %s\\n" $rename_to | while read old_name new_name; do
        [ -f "\${new_name}" ] || ln -s \${old_name} \${new_name}
    done

    fastqc \
        --threads ${task.cpus} \
        --memory ${fastqc_memory} \
        ${renamed_files}
    
    fastqc --version &> v_fastqc.txt
    """
}