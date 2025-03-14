process FASTP {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.data_dir}/fastp/${meta.id}", mode: "copy",
        saveAs: { it == "v_fastp.txt" ? null : it }
    
    container "quay.io/biocontainers/fastp:0.24.0--heae3180_1"
    conda "bioconda::fastp=0.24.0"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_fastp.fastq.gz"), emit: reads
    tuple val(meta), path("*_fastp.json"), emit: json
    tuple val(meta), path("*_fastp.html"), emit: html
    path "v_fastp.txt", emit: version

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    if (reads instanceof Path || reads.size() == 1) {
        """
        [ ! -f  ${prefix}.fastq.gz ] && ln -sf $reads ${prefix}.fastq.gz

        fastp \
            -i ${prefix}.fastq.gz \
            -o ${prefix}_fastp.fastq.gz \
            --json ${prefix}_fastp.json \
            --html ${prefix}_fastp.html \
            --thread ${task.cpus}
        
        fastp --version &> v_fastp.txt
        """
    } else {
        """
        [ ! -f  ${prefix}_1.fastq.gz ] && ln -sf ${reads[0]} ${prefix}_1.fastq.gz
        [ ! -f  ${prefix}_2.fastq.gz ] && ln -sf ${reads[1]} ${prefix}_2.fastq.gz

        fastp \
            -i ${prefix}_1.fastq.gz \
            -I ${prefix}_2.fastq.gz \
            -o ${prefix}_1_fastp.fastq.gz \
            -O ${prefix}_2_fastp.fastq.gz\
            --json ${prefix}_fastp.json \
            --html ${prefix}_fastp.html \
            --thread ${task.cpus} \
            --detect_adapter_for_pe
        
        fastp --version &> v_fastp.txt
        """
    }
}