#!/usr/bin/env bash

# Create conda env for MetaPhlAn v4.1.1 and activate it
conda env create -f environment.yml
conda activate mpa

# Download MetaPhlAn 4 database
metaphlan --install --bowtie2db "metaphlan4_db_202403/"

# Download human gut metagenome data from ENA:
# fasterq-dump -e 12 -t tmp -f -x -p -O raw/ --split-files ERR6170282
# https://www.ebi.ac.uk/ena/browser/view/ERR6170285 (PE 150)
wget -P raw/ ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR617/005/ERR6170285/ERR6170285_1.fastq.gz
wget -P raw/ ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR617/005/ERR6170285/ERR6170285_2.fastq.gz
# https://www.ebi.ac.uk/ena/browser/view/ERR6170282 (PE 150)
wget -P raw/ ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR617/002/ERR6170282/ERR6170282_1.fastq.gz
wget -P raw/ ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR617/002/ERR6170282/ERR6170282_2.fastq.gz
# https://www.ebi.ac.uk/ena/browser/view/ERR6170282 (SE 122)
wget -P raw/ ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR140/009/ERR14036909/ERR14036909.fastq.gz

# Down-sampling for easy demonstration
for fastq in raw/*.fastq.gz; do
    sample=$(basename "${fastq}" .fastq.gz)
    if [[ "${fastq}" =~ _1|_2 ]]; then
        zcat "${fastq}" | seqkit sample -p 0.001 -o fastq/${sample}.fastq.gz
    else
        zcat "${fastq}" | seqkit sample -p 0.01 -o fastq/${sample}.fastq.gz
    fi
done
