#!/usr/bin/env Rscript --vanilla

# name : get_otu_tibble.R
# author: William Argiroff
# inputs : Trimmed phyloseq object
# output : OTU table as a 3 column tibble
# notes : expects order of inputs, output
#   expects input paths for otu_processed/ps_trimmed.rds
#   and output data/processed/seq_data/16S/otu_processed/otu_tibble.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

ps <- read_rds(
  clargs[1]
)

# Metadata
metadata_temp <- sample_data(ps) %>%
  
  as.data.frame(.) %>%
  
  as_tibble(rownames = NA) %>%
  
  rownames_to_column(var = "sample_name")

metadata <- metadata_temp %>%
  
  select(-sample_name) %>%
  
  distinct(.)

# OTU table, long format
otu <- otu_table(ps) %>%
  
  as.data.frame(.) %>%
  
  as_tibble(rownames = NA) %>%
  
  rownames_to_column(var = "otu_id") %>%
  
  pivot_longer(
    -otu_id,
    names_to = "sample_name",
    values_to = "n_seqs"
  ) %>%
  
  inner_join(metadata_temp, ., by = "sample_name") %>%
  
  group_by(
    sample_id,
    otu_id
  ) %>%
  
  summarise(n_seqs = sum(n_seqs)) %>%
  
  ungroup(.) %>%
  
  inner_join(metadata, ., by = "sample_id")

# Final tibble
otu_final <- otu %>%
  
  select(sample_id, otu_id, n_seqs)

# Save
write_tsv(
  otu_final,
  file = clargs[2]
)
