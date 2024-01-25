#!/usr/bin/env bash

# author: William Argiroff
# inputs: QIIME2 manifest and fastq files
# outputs: QIIME2 demux artifact into proper subdirectories in data

# Activate QIIME2 environment
source activate /opt/miniconda3/envs/qiime2-2022.8

# BC

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_LE1.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_LE1.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_LE2.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_LE2.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_LE3.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_LE3.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_RE1.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_RE1.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_RE2.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_RE2.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_Redo1.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_Redo1.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_Redo2.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_Redo2.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_RH1.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_RH1.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_RH2.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_RH2.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_RH3.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_RH3.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BC/16S/manifest_BC_16S_RH4.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BC/16S/demux_BC_16S_RH4.qza

# BOARD

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BOARD/16S/manifest_16S_BS_SRA.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BOARD/16S/demux_BOARD_16S_BS.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BOARD/16S/manifest_16S_RE_SRA.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BOARD/16S/demux_BOARD_16S_RE.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/BOARD/16S/manifest_16S_RH_SRA.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/BOARD/16S/demux_BOARD_16S_RH.qza

# DAVIS

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/DAVIS/16S/manifest_DAVIS_16S_Feb_BS1.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/DAVIS/16S/demux_DAVIS_16S_Feb_BS1.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/DAVIS/16S/manifest_DAVIS_16S_Feb_RE1.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/DAVIS/16S/demux_DAVIS_16S_Feb_RE1.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/DAVIS/16S/manifest_DAVIS_16S_Feb_RH_BS.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/DAVIS/16S/demux_DAVIS_16S_Feb_RH_BS.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/DAVIS/16S/manifest_DAVIS_16S_Feb_RH1.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/DAVIS/16S/demux_DAVIS_16S_Feb_RH1.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/DAVIS/16S/manifest_DAVIS_16S_July_BS1.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/DAVIS/16S/demux_DAVIS_16S_July_BS1.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/DAVIS/16S/manifest_DAVIS_16S_July_RH_BS.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/DAVIS/16S/demux_DAVIS_16S_July_RH_BS.qza

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/manifest_files/DAVIS/16S/manifest_DAVIS_16S_July_RH1.txt \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path ~/Documents/Argiroff_stresstol_2024/data/qiime2/working_qzas/DAVIS/16S/demux_DAVIS_16S_July_RH1.qza

# Deactivate QIIME2 environment

conda deactivate
