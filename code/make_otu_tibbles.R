#!/usr/bin/env Rscript --vanilla

# name : make_otu_tibbles.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   merged OTU qza, merged tax qza, merged repseq qza
# output : Single uniform metadata file to merge with phyloseq object
# notes : expects order of inputs (args ##-##) output
#   expects input path ending in /reads/ and output path ending in data/16S/processed/

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

rm(
  ps_16s,
  repseqs_16s_qza,
  repseqs_16s
)

gc()

ps_16s_trimmed <- subset_samples(
  ps_16s_trimmed,
  plant_habitat != "Leaf endosphere"
)

ps_16s_trimmed <- subset_samples(
  ps_16s_trimmed,
  host_species == "Populus trichocarpa"
)

# Get sequence totals
pre_seq_total <- sum(sample_sums(ps_16s_trimmed))

# Remove sequences that are not bacteria or archaea and drop ASVs with no seqs
ps_16s_trimmed <- subset_taxa(ps_16s_trimmed, Kingdom == "d__Bacteria" | Kingdom == "d__Archaea")

ps_16s_trimmed <- subset_taxa(ps_16s_trimmed, Order != "Chloroplast")

ps_16s_trimmed <- subset_taxa(ps_16s_trimmed, Family != "Mitochondria")

ps_16s_trimmed <- prune_taxa(taxa_sums(ps_16s_trimmed) > 0, ps_16s_trimmed)

ps_16s_trimmed <- prune_samples(sample_sums(ps_16s_trimmed) > 0, ps_16s_trimmed)

# Get sequence totals
post_seq_total <- sum(sample_sums(ps_16s_trimmed))

seq_totals <- tibble(
  pre_trim = pre_seq_total,
  post_trim = post_seq_total
)

# Metadata
metadata_16s_trimmed <- sample_data(ps_16s_trimmed) %>%
  
  as.data.frame(.) %>%
  
  as_tibble(rownames = NA) %>%
  
  rownames_to_column(var = "sample_name")

metadata_16s_trimmed2 <- metadata_16s_trimmed %>%
  
  select(-sample_name) %>%
  
  distinct(.)

# OTU table, long format
otu <- otu_table(ps_16s_trimmed) %>%
  
  as.data.frame(.) %>%
  
  as_tibble(rownames = NA) %>%
  
  rownames_to_column(var = "otu_id") %>%
  
  pivot_longer(
    -otu_id,
    names_to = "sample_name",
    values_to = "n_seqs"
  ) %>%
  
  inner_join(metadata_16s_trimmed, ., by = "sample_name") %>%
  
  group_by(
    sample_id,
    otu_id
  ) %>%
  
  summarise(n_seqs = sum(n_seqs)) %>%
  
  ungroup(.) %>%
  
  inner_join(metadata_16s_trimmed2, ., by = "sample_id")

# Final tibbles
otu_final <- otu %>%
  
  select(sample_id, otu_id, n_seqs)

metadata_final <- otu %>%
  
  select(
    sample_id,
    community,
    plant_habitat,
    host_species,
    host_genotype,
    season,
    collection_year,
    replicate,
    collection_date,
    cutting_location,
    treatment,
    location
  ) %>%
  
  distinct(.)

taxonomy_final <- tax_table(ps_16s_trimmed) %>%
  
  as.data.frame(.) %>%
  
  as_tibble(rownames = NA) %>%
  
  rownames_to_column(var = "otu_id")

repseqs_final <- refseq(ps_16s_trimmed)

# Save
otu_outpath <- paste(clargs[5], "otu_table.txt", sep = "")
tax_outpath <- paste(clargs[5], "taxonomy_table.txt", sep = "")
metadata_outpath <- paste(clargs[5], "metadata_table.txt", sep = "")
repseqs_outpath <- paste(clargs[5], "representative_sequences.fasta", sep = "")
seq_summary_outpath <- paste(clargs[5], "sequence_summary.txt", sep = "")

write_tsv(
  otu_final,
  file = otu_outpath
)

write_tsv(
  taxonomy_final,
  tax_outpath
)

write_tsv(
  metadata_final,
  metadata_outpath
)

Biostrings::writeXStringSet(
  repseqs_final,
  filepath = repseqs_outpath,
  format = "fasta"
)

write_tsv(
  seq_totals,
  seq_summary_outpath
)
