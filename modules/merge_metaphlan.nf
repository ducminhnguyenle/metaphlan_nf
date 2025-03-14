process MERGE_METAPHLAN {
    publishDir "${params.data_dir}/metaphlan", mode: "copy", overwrite: true
    label 'process_low'

    container "quay.io/biocontainers/metaphlan:4.1.1--pyhdfd78af_0"
    conda "bioconda::metaphlan=4.1.1"

    input:
    path profiles

    output:
    path "metaphlan_abundance_table.txt", emit: merged_mpa

    script:
    """
    merge_metaphlan_tables.py \
        ${profiles} \
        > "metaphlan_abundance_table.txt"
    """
}