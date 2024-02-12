#!/usr/bin/env Rscript --vanilla

# name : get_taxonomy_tibble.R
# author: William Argiroff
# inputs : Trimmed phyloseq object, OTU tibble
# output : tibble of taxonomic classifications
# notes : expects order of inputs, output
#   expects input paths for otu_processed/ps_trimmed.rds
#   and otu_processed/otu_table.txt and output 
#   data/processed/seq_data/16S/otu_processed/taxonomy_tibble.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

ps <- read_rds(
  clargs[1]
)

otu_filter <- read_tsv(
  file = clargs[2]
) %>%
  
  select(otu_id) %>%
  
  distinct(.) %>%
  
  pull(otu_id)

taxonomy <- tax_table(ps) %>%
  
  as.data.frame(.) %>%
  
  as_tibble(rownames = NA) %>%
  
  rownames_to_column(var = "otu_id") %>%
  
  filter(otu_id %in% otu_filter)

# Save
write_tsv(
  taxonomy,
  file = clargs[3]
)
