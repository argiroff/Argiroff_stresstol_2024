#!/usr/bin/env Rscript --vanilla

# name : get_combined_16s_its_otu_table.R
# author: William Argiroff
# inputs : Files in otu_processed for 16S and ITS
# output : Combined tibble for 16S and ITS OTUs
# notes : expects order of inputs, output
#   expects input path data/processed/otu_processed/
#   and output paths in data/processed/seq_data/spieceasi/*
#   generated within this script

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Read in metadata
metadata_16s <- read_tsv(
  file = clargs[1]
) %>%
  
  mutate(
    sample_id2 = str_remove(sample_id, "-16S"),
    sample_id2 = str_remove(sample_id2, "-16s")
  )

metadata_its <- read_tsv(
  file = clargs[2]
) %>%
  
  mutate(
    sample_id2 = str_remove(sample_id, "-ITS"),
    sample_id2 = str_remove(sample_id2, "_its"),
    sample_id2 = str_replace(sample_id2, "_rhizo", "-rhizo")
  )

# Get sample filter
sample_id_filter <- metadata_16s %>%
  
  inner_join(., metadata_its, by = "sample_id2") %>%
  
  pull(sample_id2)

# Read in OTU tables
otu_16s <- read_tsv(
  file = clargs[3]
) %>%
  
  inner_join(metadata_16s, ., by = "sample_id") %>%
  
  filter(sample_id2 %in% sample_id_filter)

otu_its <- read_tsv(
  file = clargs[4]
) %>%
  
  inner_join(metadata_its, ., by = "sample_id") %>%
  
  filter(sample_id2 %in% sample_id_filter)

# Combine
otu <- bind_rows(
  otu_16s,
  otu_its
) %>%
  
  select(
    community,
    plant_habitat,
    location,
    sample_id2,
    otu_id,
    n_seqs
  ) %>%
  
  group_by(otu_id) %>%
  
  mutate(otu_sum = sum(n_seqs)) %>%
  
  filter(otu_sum > 0) %>%
  
  ungroup(.) %>%
  
  select(-otu_sum)

# Save OTU table
write_tsv(
  otu,
  file = clargs[5]
)
