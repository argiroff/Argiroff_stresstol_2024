#!/usr/bin/env Rscript --vanilla

# name : format_metadata.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   data/qiime2/*/*/manifest.txt
#   data/metadata/DAVIS/*.txt
# output : Single uniform metadata file to merge with phyloseq object
# notes : expects order of inputs (args 1-3) output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Read in
metadata <- clargs[1:3] %>%
  
  map(., .f = read_tsv) %>%
  
  bind_rows(.) %>%
  
  mutate(treatment = as.character(treatment))

# Save
write_tsv(
  metadata,
  file = clargs[4]
)
