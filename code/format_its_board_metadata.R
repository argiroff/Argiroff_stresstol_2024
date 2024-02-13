#!/usr/bin/env Rscript --vanilla

# name : format_its_board_metadata.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   data/metadata/BOARD/BOARD_metadata_SraRunTable.txt
# output : Single uniform metadata file to merge with phyloseq object
# notes : expects order of inputs (args ##-##) output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

#### BOARD ####

# Read in
board_its_metadata <- read_tsv(
  file = clargs[1]
) %>%
  
  filter(marker_gene == "its") %>%
  
  select(
    Run, `Sample Name`, marker_gene, host_genotype, HOST,
    Organism, watering_regm, Collection_Date
  ) %>%
  
  rename(
    sample_name = "Run",
    sample_id = "Sample Name",
    community = "marker_gene",
    host_species = "HOST",
    plant_habitat = "Organism",
    treatment = "watering_regm",
    collection_date = "Collection_Date"
  ) %>%
  
  mutate(
    community = ifelse(
      community == "its",
      "Fungi",
      community
    ),
    
    plant_habitat = ifelse(
      plant_habitat == "soil metagenome",
      "Soil",
      plant_habitat
    ),
    
    plant_habitat = ifelse(
      plant_habitat == "rhizosphere metagenome",
      "Rhizosphere",
      plant_habitat
    ),
    
    plant_habitat = ifelse(
      plant_habitat == "root metagenome",
      "Root endosphere",
      plant_habitat
    ),
    
    treatment = ifelse(
      treatment == "reduced",
      "Drought",
      treatment
    ),
    
    treatment = ifelse(
      treatment == "full",
      "Control",
      treatment
    ),
    
    season = NA_character_,
    
    location = "Boardman, OR",
    
    collection_year = NA_character_,
    
    replicate = NA_character_,
    
    cutting_location = NA_character_
  ) %>%
  
  relocate(
    sample_name,
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
  )

# Save
write_tsv(
  board_its_metadata,
  file = clargs[2]
)
