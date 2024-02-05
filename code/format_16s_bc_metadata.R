#!/usr/bin/env Rscript --vanilla

# name : format_16s_bc_metadata.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   data/metadata/BC/16S/*.csv data/metadata/BC/16S/*.tsv
# output : Single uniform metadata file to merge with phyloseq object
# notes : expects order of inputs, output
#   expects input path ending in /reads/ and output path ending in data/16S/processed/

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

#### BC ####

bc_16s_cut_1 <- read_csv(file = clargs[2]) %>%

  select(sample_id, cutting_location) %>%

  rename(sample_name = "sample_id")

bc_16s_cut_2 <- read_csv(file = clargs[1]) %>%

  select(sample_id, sample_code) %>%

  distinct(.) %>%

  separate(
    sample_code,
    into = c("genotype", "cutting_location", "replicate", "month", "year")
  ) %>%

  rename(sample_name = "sample_id") %>%

  select(sample_name, cutting_location) %>%

  bind_rows(bc_16s_cut_1, .)

# Sample dates
bc_16s_dates <- tibble(
  season = rep(c("Winter", "Spring", "Summer", "Fall"), 2),
  collection_date = c(
    "2018-02-19", "2018-06-07", "2018-08-22", "2018-10-04",
    "2019-02-07", "2019-05-30", "2019-08-29", "2019-10-14"
  )
) %>%
  
  mutate(collection_date =  ymd(collection_date))

# BC tsvs
bc_16s_metadata <- clargs[3:4] %>%

  map(., .f = read_tsv) %>%

  bind_rows(.) %>%

  select(
    sample_name, collection_date, env_local_scale,
    host, host_genotype, replicate
  ) %>%

  mutate(
    collection_year = year(collection_date),

    sample_name = ifelse(
      str_detect(sample_name, "RHAug|RHOct"), str_remove(sample_name, "-redo-16S"), sample_name
    ),

    sample_name = ifelse(
      str_detect(sample_name, "RHAug|RHOct"), str_replace_all(sample_name, "-", "_"), sample_name
    ),

    community = "Bacteria and Archaea"
  ) %>%

  left_join(., bc_16s_dates, by = "collection_date") %>%

  left_join(., bc_16s_cut_1, by = "sample_name") %>%

  rename(
    plant_habitat = "env_local_scale",
    host_species = "host"
  ) %>%

  mutate(
    cutting_location = ifelse(
      is.na(cutting_location), "Clatskanie", cutting_location
    ),

    plant_habitat = ifelse(
      plant_habitat == "Rhizosphere soil", "Rhizosphere", plant_habitat
    ),

    sample_type = NA_character_,

    sample_type = ifelse(
      plant_habitat == "Leaf endosphere",
      "LE",
      sample_type
    ),

    sample_type = ifelse(
      plant_habitat == "Root endosphere",
      "RE",
      sample_type
    ),

    sample_type = ifelse(
      plant_habitat == "Rhizosphere",
      "RH",
      sample_type
    ),

    location = "Blount County, TN",

    treatment = NA_character_

  ) %>%

  unite(
    sample_id,
    host_genotype,
    replicate,
    sample_type,
    cutting_location,
    season,
    collection_year,
    sep = "_",
    remove = FALSE
  ) %>%

  select(-sample_type) %>%

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

host_spp <- read_tsv(clargs[5]) %>%
  
  select(genotype, HostSpecies) %>%
  
  distinct(.) %>%
  
  rename(
    host_genotype = "genotype",
    host_species = "HostSpecies"
  ) %>%
  
  filter(!is.na(host_genotype))

bc_16s_metadata_redo <- read_csv(file = clargs[1]) %>%
  
  select(sample_id, sample_type, sample_code) %>%
  
  distinct(.) %>%
  
  separate(
    sample_code,
    into = c("host_genotype", "cutting_location", "replicate",
             "month", "collection_year")
  ) %>%
  
  inner_join(., host_spp, by = "host_genotype") %>%
  
  rename(
    sample_name = "sample_id",
    season = "month"
  ) %>%
  
  mutate(
    community = "Bacteria and Archaea",
    
    season = ifelse(
      season == "Oct",
      "Fall",
      season
    ),
    
    season = ifelse(
      season == "Aug",
      "Summer",
      season
    )
    
  ) %>%
  
  unite(
    sample_id,
    host_genotype,
    replicate,
    sample_type,
    cutting_location,
    season,
    collection_year,
    sep = "_",
    remove = FALSE
  ) %>%
  
  rename(plant_habitat = "sample_type") %>%
  
  mutate(
    plant_habitat = ifelse(
      plant_habitat == "RH",
      "Rhizosphere",
      plant_habitat
    ),
    
    location = "Blount County, TN",
    
    collection_date = NA,
    
    collection_date = ifelse(
      season == "Fall" & collection_year == 2018,
      "2018-10-04",
      collection_date
    ),
    
    collection_date = ifelse(
      season == "Summer" & collection_year == 2019,
      "2019-08-29",
      collection_date
    ),
    
    sample_name = str_replace_all(sample_name, "_", "-"),
    
    sample_name = paste(sample_name, "redo-16S", sep = "-"),
    
    collection_year = as.double(collection_year),
    
    collection_date =  ymd(collection_date),
    
    treatment = NA_character_
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

# Combine
bc_16s_metadata_full <- bind_rows(
  bc_16s_metadata,
  bc_16s_metadata_redo
)

# Save
write_tsv(
  bc_16s_metadata_full,
  file = clargs[6]
)
