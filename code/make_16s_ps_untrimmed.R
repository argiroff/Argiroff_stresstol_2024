#!/usr/bin/env Rscript --vanilla

# name : make_16s_ps_untrimmed.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   merged OTU qza, merged tax qza, merged repseq qza
# output : phyloseq object
# notes : expects order of inputs, output
#   expects input paths for merged OTU and rep seqs qzas, tax qza, and metadata
#   and output data/processed/seq_data/16S/otu_processed/ps_untrimmed.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(qiime2R)
library(phyloseq)

# Make phyloseq object
ps_16s <- qza_to_phyloseq(
  features = clargs[2],
  taxonomy = clargs[3]
)

# Add representative sequences
repseqs_16s_qza <- read_qza(
  file = clargs[1]
)

repseqs_16s <- repseqs_16s_qza$data

ps_16s <- merge_phyloseq(ps_16s, repseqs_16s)

# Add metadata
metadata_16s <- read_tsv(
  file = clargs[4],
  col_types = cols(treatment = col_character())
) %>%
  
  filter(sample_name %in% sample_names(ps_16s)) %>%
  
  distinct(.) %>%
  
  arrange(match(sample_name, sample_names(ps_16s))) %>%
  
  column_to_rownames(var = "sample_name") %>%
  
  as.data.frame(.)

metadata_16s_input <- sample_data(metadata_16s)

ps_16s <- merge_phyloseq(ps_16s, metadata_16s_input)

# Filter
ps_16s_trimmed <- subset_samples(
  ps_16s,
  collection_year == 2018 | collection_year == 2019 | is.na(collection_year)
)

ps_16s_trimmed <- subset_samples(
  ps_16s_trimmed,
  plant_habitat != "Leaf endosphere"
)

ps_16s_trimmed <- subset_samples(
  ps_16s_trimmed,
  host_species == "Populus trichocarpa"
)

# Save
write_rds(
  ps_16s_trimmed,
  file = clargs[5]
)
