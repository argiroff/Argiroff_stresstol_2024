#!/usr/bin/env Rscript --vanilla

# name : ps_for_ancombc.R
# author: William Argiroff
# inputs : Files in data/processed/seq_data/16S/ancombc_in/otu/*/
#   metadata tibble, OTU tibble, repseq fasta, tax txt
# output : A phyloseq object in appropriate directory
# notes : expects order of inputs, output
#   expects input path data/processed/seq_data/16S/ancombc/*
#   and output paths in data/processed/seq_data/16S/ancombc/*
#   generated within this script
#   code/functions.R is a script that contains functions used in several
#   other R scripts

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

library(phyloseq)

source("code/functions.R")

# Read in files
metadata <- read_tsv(
  file = clargs[1]
) %>%
  
  column_to_rownames(var = "sample_id") %>%
  
  as.data.frame(.)

otu <- read_tsv(
  file = clargs[2]
) %>%
  
  pivot_wider(
    id_cols = otu_id,
    names_from = "sample_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  
  column_to_rownames(var = "otu_id") %>%
  
  as.data.frame(.)

repseqs <- Biostrings::readDNAStringSet(
  filepath = clargs[3],
  format = "fasta"
)

taxonomy <- read_tsv(
  file = clargs[4]
) %>%
  
  column_to_rownames(var = "otu_id") %>%
  
  as.data.frame(.)

# Convert to phyloseq object
metadata_in <- sample_data(metadata)

otu_in <- otu_table(otu, taxa_are_rows = TRUE)

repseqs_in <- refseq(repseqs)

taxonomy_in <- tax_table(as.matrix(taxonomy))

ps <- phyloseq(
  otu_in,
  metadata_in,
  taxonomy_in,
  repseqs_in
)

# Factor
ps <- refactor_ps(ps, clargs[1])

# Save
write_rds(
  ps,
  file = clargs[5]
)
