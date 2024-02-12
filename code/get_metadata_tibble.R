#!/usr/bin/env Rscript --vanilla

# name : get_metadata_tibble.R
# author: William Argiroff
# inputs : Trimmed phyloseq object, OTU tibble
# output : OTU table as a 3 column tibble
# notes : expects order of inputs, output
#   expects input paths for otu_processed/ps_trimmed.rds
#   and output data/processed/seq_data/16S/otu_processed/metadata_tibble.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

ps <- read_rds(
  clargs[1]
)

otu_filter <- read_tsv(
  file = clargs[2]
) %>%
  
  select(sample_id) %>%
  
  distinct(.) %>%
  
  pull(sample_id)

# Metadata
metadata <- sample_data(ps) %>%
  
  as.data.frame(.) %>%
  
  as_tibble(.) %>%
  
  distinct(.) %>%
  
  filter(sample_id %in% otu_filter)

write_tsv(
  metadata,
  file = clargs[3]
)
