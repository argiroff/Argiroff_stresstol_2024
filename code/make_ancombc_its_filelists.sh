#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mem-per-cpu=64G
#SBATCH --job-name=abclists
#SBATCH -p high_mem
#SBATCH -A bsd

cd /lustre/or-scratch/cades-bsd/7wa/stresstol_ancombc

ls ancombc/ITS/*_ps.rds > ancombc_its_infiles.txt
cp ancombc_its_infiles.txt ancombc_its_outfiles.txt
sed -i -E "s/\_ps.rds/\_ancombc_results.rds/g" ancombc_its_outfiles.txt
