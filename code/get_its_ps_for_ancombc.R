#!/usr/bin/env Rscript --vanilla

# name : get_its_ps_for_ancombc.R
# author: William Argiroff
# inputs : Files in data/processed/seq_data/16S/otu_processed/
#   merged OTU qza, merged tax qza, merged repseq qza
# output : A new directory for each split OTU table (with OTU table,
#   metadata table, tax table, and representative sequence fasta)
# notes : expects order of inputs, output
#   expects input path data/processed/seq_data/ITS/otu_processed
#   and output paths in data/processed/seq_data/ITS/ancombc/*/otu/
#   generated within this script
#   code/functions.R is a script that contains functions used in several
#   other R scripts

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

source("code/functions.R")

metadata <- read_tsv(
  file = clargs[1]
)

otu <- read_tsv(
  file = clargs[2]
) %>%
  
  inner_join(metadata, ., by = "sample_id") %>%
  
  group_by(location) %>%
  
  group_split(.) %>%
  
  map(., .f = ungroup) %>%
  
  set_names(nm = c("BC", "BOARD", "DAVIS"))

repseqs <- Biostrings::readDNAStringSet(
  filepath = clargs[3],
  format = "fasta"
)

tax_table <- read_tsv(
  file = clargs[4]
)

dir_name <- dirname(clargs[5])

filename_temp <- str_remove(
  string = clargs[5],
  pattern = paste(dir_name, "/", sep = "")
)

filename <- str_remove(
  string = filename_temp,
  pattern = "_ps.rds"
)

bc_names <- c(
  "bc_re_2018", "bc_re_2019", "bc_rh_2018",
  "bc_rh_2019"
)

board_names <- c(
  "board_bs", "board_re", "board_rh"
)

davis_treatment_names <- c(
  "davis_bs_summer", "davis_bs_winter", "davis_re_summer",
  "davis_re_winter", "davis_rh_summer", "davis_rh_winter"
)

davis_season_names <- c(
  "davis_bs_control", "davis_bs_drought", "davis_re_control",
  "davis_re_drought", "davis_rh_control", "davis_rh_drought"
)

location_names <- c(
  "location_bs", "location_re", "location_rh"
)

if(filename %in% bc_names) {
  # Split files, BC
  otu_split <- otu$BC %>%
    
    group_by(plant_habitat, collection_year) %>%
    
    group_split(.) %>%
    
    map(., .f = ungroup) %>%
    
    set_names(nm = c("BC_RH_2018", "BC_RH_2019", "BC_RE_2018", "BC_RE_2019")) %>%
    
    map(., .f = drop_0seq_otus) %>%
    
    map(., .f = drop_0seq_samples)
  
} else if(filename %in% board_names) {
  # Split files, BOARD
  otu_split <- otu$BOARD %>%
    
    group_by(plant_habitat, collection_year) %>%
    
    group_split(.) %>%
    
    map(., .f = ungroup) %>%
    
    set_names(nm = c("BOARD_RH", "BOARD_RE", "BOARD_BS")) %>%
    
    map(., .f = drop_0seq_otus) %>%
    
    map(., .f = drop_0seq_samples)
  
} else if(filename %in% davis_treatment_names) {
  # Split files, DAVIS season
  otu_split <- otu$DAVIS %>%
    
    group_by(plant_habitat, season) %>%
    
    group_split(.) %>%
    
    map(., .f = ungroup) %>%
    
    set_names(nm = c("DAVIS_RH_SUMMER", "DAVIS_RH_WINTER",
                     "DAVIS_RE_SUMMER", "DAVIS_RE_WINTER",
                     "DAVIS_BS_SUMMER", "DAVIS_BS_WINTER")) %>%
    
    map(., .f = drop_0seq_otus) %>%
    
    map(., .f = drop_0seq_samples)
  
} else if(filename %in% davis_season_names) {
  # Split files, DAVIS treatment
  otu_split <- otu$DAVIS %>%
    
    group_by(plant_habitat, treatment) %>%
    
    group_split(.) %>%
    
    map(., .f = ungroup) %>%
    
    set_names(nm = c("DAVIS_RH_CONTROL", "DAVIS_RH_DROUGHT",
                     "DAVIS_RE_CONTROL", "DAVIS_RE_DROUGHT",
                     "DAVIS_BS_CONTROL", "DAVIS_BS_DROUGHT")) %>%
    
    map(., .f = drop_0seq_otus) %>%
    
    map(., .f = drop_0seq_samples)
  
} else if(filename %in% location_names) {
  # Location
  otu_split <- read_tsv(
    file = clargs[2]
  ) %>%
    
    inner_join(metadata, ., by = "sample_id") %>%
    
    group_by(plant_habitat) %>%
    
    group_split(.) %>%
    
    map(., .f = ungroup) %>%
    
    set_names(nm = c("LOCATION_RH", "LOCATION_RE", "LOCATION_BS")) %>%
    
    map(., .f = drop_0seq_otus) %>%
    
    map(., .f = drop_0seq_samples)
  
} else {
  otu_split <- clargs[2]
  
}

# Get final OTU table
extract_name <- toupper(filename)

otu_final <- otu_split %>%
  
  pluck(extract_name) %>%
  
  select(sample_id, otu_id, n_seqs) %>%
  
  pivot_wider(
    id_cols = otu_id,
    names_from = "sample_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  
  column_to_rownames(var = "otu_id") %>%
  
  as.data.frame(.)

# Get final metadata table
metadata_final <- otu_split %>%
  
  pluck(extract_name) %>%
  
  select(-c(otu_id, n_seqs)) %>%
  
  distinct(.) %>%
  
  column_to_rownames(var = "sample_id") %>%
  
  as.data.frame(.)

# Get representative sequences
otu_filter <- rownames(otu_final)

repseqs_final <- repseqs[otu_filter]

# Get taxonomy
taxonomy_final <- tax_table %>%
  
  filter(otu_id %in% otu_filter) %>%
  
  column_to_rownames(var = "otu_id") %>%
  
  as.data.frame(.)

# Phyloseq object
otu_in <- otu_table(otu_final, taxa_are_rows = TRUE)

metadata_in <- sample_data(metadata_final)

repseqs_in <- refseq(repseqs_final)

taxonomy_in <- tax_table(as.matrix(taxonomy_final))

ps <- phyloseq(
  otu_in,
  metadata_in,
  taxonomy_in,
  repseqs_in
)

# Refactor phyloseq object
if(filename %in% bc_names) {
  sample_data(ps)$season <- factor(
    sample_data(ps)$season,
    levels = c("Winter", "Spring", "Summer", "Fall")
  )
  
} else if(filename %in% board_names) {
  sample_data(ps)$treatment <- factor(
    sample_data(ps)$treatment,
    levels = c("Control", "Drought")
  )
  
} else if(filename %in% davis_season_names) {
  sample_data(ps)$season <- factor(
    sample_data(ps)$season,
    levels = c("Winter", "Summer")
  )
  
} else if(filename %in% davis_treatment_names) {
  sample_data(ps)$treatment <- factor(
    sample_data(ps)$treatment,
    levels = c("Control", "Drought")
  )
  
} else if(filename %in% location_names) {
  sample_data(ps)$location <- factor(
    sample_data(ps)$location,
    levels = c("Blount County, TN", "Boardman, OR", "Davis, CA")
  )
  
} else {
  ps <- ps
  
}

# Save
write_rds(
  ps,
  file = clargs[5]
)
