# Metaphlan profiling with Nextflow

## 1. Samplesheet format requirement

| sample | read1 | read2 |
| -------- | ------- | ------- |
| S1     | ./fastq/ERR6170282_1.fastq.gz | ./fastq/ERR6170282_2.fastq.gz |
| S2     | ./fastq/ERR6170285_1.fastq.gz | ./fastq/ERR6170285_2.fastq.gz |
| S3     | ./fastq/ERR14036909.fastq.gz  |

- **_Note_**: Samplesheet can have both `single-end` and `paired-end` reads.

## 2. How to run the pipeline

```bash
nextflow run main.nf \
    -profile docker \
    --data_dir "path/to/data_dir" \
    --samplesheet "path/to/samplesheet.csv" \
    --mpa_db "path/to/metaphlan4_db_202403" \
    --mpa_index "mpa_vJun23_CHOCOPhlAnSGB_202403"
```

- `--data_dir`: Data directory for storing output from the pipeline
- `--samplesheet`: Samplesheet in CSV format with sampleID and relevent sequencing reads (can handle both **single-end** and **paired-end**).
- `--mpa_db`: Local metaphlan database
- `--mpa_index`: Index of metaphlan database
