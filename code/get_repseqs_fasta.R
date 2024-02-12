#!/usr/bin/env Rscript --vanilla

# name : get_repseqs_fasta.R
# author: William Argiroff
# inputs : Trimmed phyloseq object, OTU tibble
# output : rep seq fasta file
# notes : expects order of inputs, output
#   expects input paths for otu_processed/ps_trimmed.rds
#   and otu_processed/otu_table.txt and output 
#   data/processed/seq_data/16S/otu_processed/representative_sequences.fasta

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

repseqs <- refseq(ps)

# Save
Biostrings::writeXStringSet(
  repseqs,
  filepath = clargs[3],
  format = "fasta"
)
