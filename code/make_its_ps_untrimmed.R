#!/usr/bin/env Rscript --vanilla

# name : make_its_ps_untrimmed.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   merged OTU qza, merged tax qza, merged repseq qza
# output : phyloseq object
# notes : expects order of inputs, output
#   expects input paths for merged OTU and rep seqs qzas, tax qza, and metadata
#   and output data/processed/seq_data/ITS/otu_processed/ps_untrimmed.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(qiime2R)
library(phyloseq)

# Make phyloseq object
ps <- qza_to_phyloseq(
  features = clargs[2],
  taxonomy = clargs[3]
)

# Add representative sequences
repseqs_qza <- read_qza(
  file = clargs[1]
)

repseqs <- repseqs_qza$data

ps <- merge_phyloseq(ps, repseqs)

# Add metadata
metadata <- read_tsv(
  file = clargs[5],
  col_types = cols(treatment = col_character())
) %>%
  
  filter(sample_name %in% sample_names(ps)) %>%
  
  distinct(.) %>%
  
  arrange(match(sample_name, sample_names(ps))) %>%
  
  column_to_rownames(var = "sample_name") %>%
  
  as.data.frame(.)

metadata_input <- sample_data(metadata)

ps <- merge_phyloseq(ps, metadata_input)

# Filter
ps_trimmed <- subset_samples(
  ps,
  collection_year == 2018 | collection_year == 2019 | is.na(collection_year)
)

ps_trimmed <- subset_samples(
  ps_trimmed,
  plant_habitat != "Leaf endosphere"
)

ps_trimmed <- subset_samples(
  ps_trimmed,
  host_species == "Populus trichocarpa"
)

# Save
write_rds(
  ps_trimmed,
  file = clargs[6]
)
