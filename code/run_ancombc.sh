#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=20:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --job-name=abc_%a
#SBATCH --output=abc_%a.out
#SBATCH -p high_mem
#SBATCH -A bsd
#SBATCH --array=1-2

cd /lustre/or-scratch/cades-bsd/7wa/stresstol_ancombc/ancombc/16S/

infile=$(awk "NR==${SLURM_ARRAY_TASK_ID}" ancombc_infiles.txt)
outfile=$(awk "NR==${SLURM_ARRAY_TASK_ID}" ancombc_outfiles.txt)

source activate r-cades-ancombc

Rscript ancombc_16s.R $infile $outfile

conda deactivate
