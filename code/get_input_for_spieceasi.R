#!/usr/bin/env Rscript --vanilla

# name : get_input_for_spieceasi.R
# author: William Argiroff
# inputs : Files in otu_processed for 16S and ITS
# output : SPIECEASI output as spieceasi/*_ancombc_results.rds for 16s or its
# notes : expects order of inputs, output
#   expects input path data/processed/seq_data/spieceasi/*
#   and output paths in data/processed/seq_data/spieceasi/*
#   generated within this script

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# Read in metadata
otu <- read_tsv(
  file = clargs[1]
)

# Trim OTU table
if(str_detect(clargs[2], "full_bs")) {
  
  otu_trimmed <- otu %>%
    filter(plant_habitat == "Soil")
  
} else if(str_detect(clargs[2], "full_re")){
  
  otu_trimmed <- otu %>%
    filter(plant_habitat == "Root endosphere")
  
} else if(str_detect(clargs[2], "full_rh")) {
  
  otu_trimmed <- otu %>%
    filter(plant_habitat == "Rhizosphere")
  
} else if(str_detect(clargs[2], "bc_re")) {
  
  otu_trimmed <- otu %>%
    filter(
      location == "Blount County, TN" & plant_habitat == "Root endosphere"
    )
  
} else if(str_detect(clargs[2], "bc_rh")) {
  
  otu_trimmed <- otu %>%
    filter(
      location == "Blount County, TN" & plant_habitat == "Rhizosphere"
    )
  
} else if(str_detect(clargs[2], "board_bs")) {
  
  otu_trimmed <- otu %>%
    filter(
      location == "Boardman, OR" & plant_habitat == "Soil"
    )
  
} else if(str_detect(clargs[2], "board_re")) {
  
  otu_trimmed <- otu %>%
    filter(
      location == "Boardman, OR" & plant_habitat == "Root endosphere"
    )
  
} else if(str_detect(clargs[2], "board_rh")) {
  
  otu_trimmed <- otu %>%
    filter(
      location == "Boardman, OR" & plant_habitat == "Rhizosphere"
    )
  
} else if(str_detect(clargs[2], "davis_bs")) {
  
  otu_trimmed <- otu %>%
    filter(
      location == "Davis, CA" & plant_habitat == "Soil"
    )
  
} else if(str_detect(clargs[2], "davis_re")) {
  
  otu_trimmed <- otu %>%
    filter(
      location == "Davis, CA" & plant_habitat == "Root endosphere"
    )
  
} else if(str_detect(clargs[2], "davis_rh")) {
  
  otu_trimmed <- otu %>%
    filter(
      location == "Davis, CA" & plant_habitat == "Rhizosphere"
    )
  
} else {
  
  otu_trimmed <- otu
  
}

# Clean up memory
rm(otu)

gc()

# Split OTU tables by community
otu_split <- otu_trimmed %>%
  group_by(community) %>%
  group_split(.) %>%
  map(., .f = ungroup) %>%
  set_names(nm = c("BA", "FUNGI")) %>%
  map(., .f = drop_0seq_otus) %>%
  map(., .f = drop_0seq_samples2)

# Filter OTUs
otu_filtered <- pmap(
  list(otu_split, 0.1, 100),
  .f = filter_otus
) %>%
  map(., .f = drop_0seq_otus) %>%
  map(., .f = drop_0seq_samples2)

# Clean up memory
rm(otu_split)

gc()

# Get sample filter
sample_id_filter <- get_sample_id_filter(
  otu_filtered$BA,
  otu_filtered$FUNGI
)

# Format final OTU table
if(str_detect(clargs[2], "_16s_input.rds")) {
  
  otu_output <- otu_filtered$BA %>%
    filter(sample_id2 %in% sample_id_filter) %>%
    arrange(match(sample_id2, sample_id_filter))
  
} else if(str_detect(clargs[2], "_its_input.rds")) {
  
  otu_output <- otu_filtered$FUNGI %>%
    filter(sample_id2 %in% sample_id_filter) %>%
    arrange(match(sample_id2, sample_id_filter))
  
} else {
  
  otu_output <- otu_filtered
  
}

# Wide format
otu_final <- otu_output %>%
  pivot_wider(
    id_cols = sample_id2,
    names_from = "otu_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  column_to_rownames(var = "sample_id2") %>%
  as.data.frame(.) %>%
  as.matrix(.)

# Save OTU table
write_rds(
  otu_final,
  file = clargs[2]
)
