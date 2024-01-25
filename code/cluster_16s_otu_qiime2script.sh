#!/usr/bin/env bash

# This script uses QIIME2 to cluster 16S ASVs into OTUs at an identity cutoff of 97%

# author: William Argiroff
# inputs: QIIME2 manifest and fastq files
# outputs: QIIME2 demux artifact into proper subdirectories in data

# Activate QIIME2 environment
source activate /opt/miniconda3/envs/qiime2-2022.8

# BC

qiime vsearch cluster-features-de-novo \
  --i-table ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/BC/16S/BC_16S_merged_table.qza \
  --i-sequences ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/BC/16S/BC_16S_merged_repseqs.qza \
  --p-perc-identity 0.97 \
  --o-clustered-table ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/BC/16S/BC_16S_merged_table_otu97.qza \
  --o-clustered-sequences ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/BC/16S/BC_16S_merged_repseqs_otu97.qza

# BOARD

qiime vsearch cluster-features-de-novo \
  --i-table ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/BOARD/16S/BOARD_16S_merged_table.qza \
  --i-sequences ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/BOARD/16S/BOARD_16S_merged_repseqs.qza \
  --p-perc-identity 0.97 \
  --o-clustered-table ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/BOARD/16S/BOARD_16S_merged_table_otu97.qza \
  --o-clustered-sequences ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/BOARD/16S/BOARD_16S_merged_repseqs_otu97.qza

# DAVIS

qiime vsearch cluster-features-de-novo \
  --i-table ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/DAVIS/16S/DAVIS_16S_Feb_merged_table.qza \
  --i-sequences ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/DAVIS/16S/DAVIS_16S_Feb_merged_repseqs.qza \
  --p-perc-identity 0.97 \
  --o-clustered-table ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/DAVIS/16S/DAVIS_16S_Feb_merged_table_otu97.qza \
  --o-clustered-sequences ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/DAVIS/16S/DAVIS_16S_Feb_merged_repseqs_otu97.qza

qiime vsearch cluster-features-de-novo \
  --i-table ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/DAVIS/16S/DAVIS_16S_July_merged_table.qza \
  --i-sequences ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/DAVIS/16S/DAVIS_16S_July_merged_repseqs.qza \
  --p-perc-identity 0.97 \
  --o-clustered-table ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/DAVIS/16S/DAVIS_16S_July_merged_table_otu97.qza \
  --o-clustered-sequences ~/Documents/Argiroff_stresstol_2024/data/qiime2/final_qzas/DAVIS/16S/DAVIS_16S_July_merged_repseqs_otu97.qza

# Deactivate QIIME2

conda deactivate
