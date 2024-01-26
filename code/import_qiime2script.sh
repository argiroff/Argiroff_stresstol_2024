#!/usr/bin/env bash

# author: William Argiroff
# inputs: QIIME2 manifest and fastq files
# outputs: QIIME2 demux artifact into proper subdirectories in data

# Activate QIIME2 environment
echo "Activating QIIME2 environment"
source activate /opt/miniconda3/envs/qiime2-2022.8

# Filepaths
echo "Obtaining filepaths"
path1=$1
path2=`echo "$PWD"/"$path1"`
path3=`echo "$path2" | sed -E "s/manifest_files/working_qzas/"`

# Import
echo "Importing .fastq as .qza"
for infile in "$path2"*.txt; do
    outfile1=`echo "$infile" | sed -E "s/.*\///" | sed -E "s/manifest/demux/" | sed -E "s/\.txt/\.qza/"`
    outfile2=`echo "$path3""$outfile1"`
    
    progress=`echo "$infile" | sed -E "s/.*\///" | sed -E "s/manifest_//" | sed -E "s/\.txt//"`
    echo "Importing""$progress"

    qiime tools import \
        --type 'SampleData[PairedEndSequencesWithQuality]' \
        --input-path "$infile" \
        --input-format PairedEndFastqManifestPhred33V2 \
        --output-path "$outfile2"

done

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment"
conda deactivate
