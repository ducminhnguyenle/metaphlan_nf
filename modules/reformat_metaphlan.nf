process REFORMAT_METAPHLAN {
    publishDir "${params.data_dir}/metaphlan", mode: "copy", overwrite: true
    label 'process_low'

    conda "conda-forge::pandas=2.2.3"
    container "staphb/pandas:2.2.3"

    input:
    path merged_mpa

    output:
    path "*_counts.csv", emit: tax_counts

    script:
    """
    reformat_mpa_output.py \
        --input ${merged_mpa} \
        --levels "PFGS"
    """
}