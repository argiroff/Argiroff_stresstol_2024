#!/usr/bin/env Rscript --vanilla

# name : format_16s_metadata.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   data/qiime2/16S/*/manifest.txt
#   data/metadata/DAVIS/*.txt
# output : Single uniform metadata file to merge with phyloseq object
# notes : expects order of inputs (args ##-##) output
#   expects input path ending in /reads/ and output path ending in data/16S/processed/

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Read in
metadata_16s <- clargs[1:3] %>%
  
  map(., .f = read_tsv) %>%
  
  bind_rows(.)

# Save
write_tsv(
  metadata_16s,
  file = clargs[4]
)
