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

library(phyloseq)
library(tidyverse)

source("code/functions.R")

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
    sample_id2 = str_remove(sample_id2, "_its")
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
    sample_id,
    sample_id2,
    otu_id,
    n_seqs
  )

# Clean up memory
rm(
  otu_16s,
  otu_its,
  metadata_16s,
  metadata_its
)

gc()

# Trim OTU table
if(str_detect(clargs[5], "full_bs")) {
  otu_trimmed <- otu %>%
    
    filter(plant_habitat == "Soil")
  
} else if(str_detect(clargs[5], "full_re")){
  otu_trimmed <- otu %>%
    
    filter(plant_habitat == "Root endosphere")
  
} else if(str_detect(clargs[5], "full_rh")) {
  otu_trimmed <- otu %>%
    
    filter(plant_habitat == "Rhizosphere")
  
} else if(str_detect(clargs[5], "bc_re")) {
  otu_trimmed <- otu %>%
    
    filter(
      location == "Blount County, TN" & plant_habitat == "Root endosphere"
    )
  
} else if(str_detect(clargs[5], "bc_rh")) {
  otu_trimmed <- otu %>%
    
    filter(
      location == "Blount County, TN" & plant_habitat == "Rhizosphere"
    )
  
} else if(str_detect(clargs[5], "board_bs")) {
  otu_trimmed <- otu %>%
    
    filter(
      location == "Boardman, OR" & plant_habitat == "Soil"
    )
  
} else if(str_detect(clargs[5], "board_re")) {
  otu_trimmed <- otu %>%
    
    filter(
      location == "Boardman, OR" & plant_habitat == "Root endosphere"
    )
  
} else if(str_detect(clargs[5], "board_rh")) {
  otu_trimmed <- otu %>%
    
    filter(
      location == "Boardman, OR" & plant_habitat == "Rhizosphere"
    )
  
} else if(str_detect(clargs[5], "davis_bs")) {
  otu_trimmed <- otu %>%
    
    filter(
      location == "DAVIS, CA" & plant_habitat == "Soil"
    )
  
} else if(str_detect(clargs[5], "davis_re")) {
  otu_trimmed <- otu %>%
    
    filter(
      location == "Davis, CA" & plant_habitat == "Root endosphere"
    )
  
} else if(str_detect(clargs[5], "davis_rh")) {
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

# Format final OTU table
if(str_detect(clargs[5], "_16s_input.rds")) {
  otu_output <- otu_trimmed %>%
    
    filter(community == "Bacteria and Archaea")
  
} else if(str_detect(clargs[5], "_its_input.rds")) {
  otu_output <- otu_trimmed %>%
    
    filter(community == "Fungi")
  
} else {
  otu_output <- otu_trimmed
  
}

# Sort filter
sorted_sample_id_filter <- sort(sample_id_filter)

# Wide format
otu_final <- otu_output %>%
  
  drop_0seq_otus(.) %>%
  
  drop_0seq_samples(.) %>%
  
  select(sample_id2, otu_id, n_seqs) %>%
  
  pivot_wider(
    id_cols = sample_id2,
    names_from = "otu_id",
    values_from = "n_seqs",
    values_fill = 0
  ) %>%
  
  arrange(match(sample_id2, sorted_sample_id_filter)) %>%
  
  column_to_rownames(var = "sample_id2") %>%
  
  as.data.frame(.) %>%
  
  as.matrix(.)

# Save OTU table
write_rds(
  otu_final,
  file = clargs[5]
)
