#!/usr/bin/env Rscript --vanilla

# name : split_otu_for_ancombc.R
# author: William Argiroff
# inputs : Files in data/processed/seq_data/16S/otu_processed/
#   merged OTU qza, merged tax qza, merged repseq qza
# output : A new directory for each split OTU table (with OTU table,
#   metadata table, tax table, and representative sequence fasta)
# notes : expects order of inputs, output
#   expects input path data/processed/seq_data/16S/otu_processed
#   and output paths in data/processed/seq_data/16S/ancombc/*/otu/
#   generated within this script
#   code/functions.R is a script that contains functions used in several
#   other R scripts

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

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
  file = clargs[5]
)

# Split and save files, BC
otu_bc <- otu$BC %>%
  
  group_by(plant_habitat, collection_year) %>%
  
  group_split(.) %>%
  
  map(., .f = ungroup) %>%
  
  set_names(nm = c("BC_RH_2018", "BC_RH_2019", "BC_RE_2018", "BC_RE_2019")) %>%
  
  map(., .f = drop_0seq_otus) %>%
  
  map(., .f = drop_0seq_samples) %>%
  
  map2(., names(.), .f = write_otu_files)

rm(otu_bc)

gc()

# Split and save files, BOARD
otu_board <- otu$BOARD %>%
  
  group_by(plant_habitat, collection_year) %>%
  
  group_split(.) %>%
  
  map(., .f = ungroup) %>%
  
  set_names(nm = c("BOARD_RH", "BOARD_RE", "BOARD_BS")) %>%
  
  map(., .f = drop_0seq_otus) %>%
  
  map(., .f = drop_0seq_samples) %>%
  
  map2(., names(.), .f = write_otu_files)

rm(otu_board)

gc()

# Split and save files, DAVIS
otu_davis_season <- otu$DAVIS %>%
  
  group_by(plant_habitat, season) %>%
  
  group_split(.) %>%
  
  map(., .f = ungroup) %>%
  
  set_names(nm = c("DAVIS_RH_SUMMER", "DAVIS_RH_WINTER", "DAVIS_RE_WINTER",
                   "DAVIS_BS_SUMMER", "DAVIS_BS_WINTER")) %>%
  
  map(., .f = drop_0seq_otus) %>%
  
  map(., .f = drop_0seq_samples) %>%
  
  map2(., names(.), .f = write_otu_files)

rm(otu_davis_season)

gc()

otu_davis_treatment <- otu$DAVIS %>%
  
  filter(plant_habitat != "Root endosphere") %>%
  
  group_by(plant_habitat, treatment) %>%
  
  group_split(.) %>%
  
  map(., .f = ungroup) %>%
  
  set_names(nm = c("DAVIS_RH_CONTROL", "DAVIS_RH_DROUGHT",
                   "DAVIS_BS_CONTROL", "DAVIS_BS_DROUGHT")) %>%
  
  map(., .f = drop_0seq_otus) %>%
  
  map(., .f = drop_0seq_samples) %>%
  
  map2(., names(.), .f = write_otu_files)

rm(otu_davis_treatment)

gc()

# Location
otu_location <- read_tsv(
  file = clargs[2]
) %>%
  
  inner_join(metadata, ., by = "sample_id") %>%
  
  group_by(plant_habitat) %>%
  
  group_split(.) %>%
  
  map(., .f = ungroup) %>%
  
  set_names(nm = c("LOCATION_RH", "LOCATION_RE", "LOCATION_BS")) %>%
  
  map(., .f = drop_0seq_otus) %>%
  
  map(., .f = drop_0seq_samples) %>%
  
  map2(., names(.), .f = write_otu_files)
