#!/usr/bin/env bash

# author: William Argiroff
# inputs: BOARD fastq files from SRA
# outputs: gzipped fastq

gzip ~/Documents/Argiroff_stresstol_2024/data/qiime2/raw/BOARD/16S/16S_BS_SRA/*.fastq
gzip ~/Documents/Argiroff_stresstol_2024/data/qiime2/raw/BOARD/16S/16S_RE_SRA/*.fastq
gzip ~/Documents/Argiroff_stresstol_2024/data/qiime2/raw/BOARD/16S/16S_RH_SRA/*.fastq
