#!/usr/bin/env Rscript --vanilla

# name : format_16s_metadata.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   data/metadata/BC/16S/*.csv data/metadata/BC/16S/*.tsv
#   data/metadata/BOARD/BOARD_metadata_SraRunTable.txt
#   data/qiime2/16S/*/manifest.txt
#   data/metadata/DAVIS/*.txt
# output : Single uniform metadata file to merge with phyloseq object
# notes : expects order of inputs (args ##-##) output
#   expects input path ending in /reads/ and output path ending in data/16S/processed/

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

#### DAVIS ####

#### Function to updated sample IDs ####

update_sample_id <- function(x, y) {
  
  if(str_detect(x, "-16S-bulksoil-16S|-bulksoil-16S|-202207-16S-SO|-bs-16S")) {
    tmp1 <- str_replace_all(x, "-16S-bulksoil-16S|-bulksoil-16S|-202207-16S-SO|-bs-16S", "-16S-BS")
    
  } else if(str_detect(x, "-16S-rhizo-16S|-rhizo-16S|-rh-16S|-rz-16S")) {
    tmp1 <- str_replace_all(x, "-16S-rhizo-16S|-rhizo-16S|-rh-16S|-rz-16S", "-16S-RH")
    
  } else if(str_detect(x, "-root-16S")) {
    tmp1 <- str_replace_all(x, "-root-16S", "-16S-RE")
    
  } else {
    tmp1 <- x
  }
  
  tmp2 <- paste(tmp1, y, sep = "-")
  return(tmp2)
}

davis_16s_manifest <- clargs[1:21] %>%
  
  .[str_detect(., "DAVIS")] %>%
  
  map(., .f = read_tsv) %>%
  
  set_names(
    nm = c("Feb_BS1", "Feb_RE1", "Feb_RH_BS", "Feb_RH1", "July_BS1",
           "July_RH_BS", "July_RH1")
  ) %>%
  
  bind_rows(.id = "ID") %>%
  
  select(`sample-id`, ID) %>%
  
  separate(ID, into = c("month", "sample_type"), extra = "merge", sep = "_") %>%
  
  mutate(
    sample_id = map2_chr(`sample-id`, month, .f = update_sample_id)
  ) %>%
  
  rename(sample_name= "sample-id") %>%
  
  select(sample_name, sample_id)

#### Function to rename columns ####

rename_cols <- function(x) {
  tmp1 <- c(
    sample_code = "ID",
    treatment = "Treatment",
    treatment="Plot...3",
    host_genotype = "Genotype",
    sample_type = "Type"
  )
  
  tmp2 <- rename(x, any_of(tmp1))
  return(tmp2)
}

#### Function to add missing columns ####

add_col <- function(x) {
  tmp1 <- c(
    sample_code = NA,
    sample_name = NA,
    sample_id = NA,
    community = NA,
    plant_habitat = NA,
    host_species = NA,
    host_genotype = NA,
    season = NA,
    collection_year = NA,
    replicate = NA,
    collection_date = NA,
    cutting_location = NA,
    treatment = NA,
    sample_type = NA,
    location = NA
  )
  
  tmp2 <- c(
    "sample_code",
    "sample_name",
    "sample_id",
    "community",
    "plant_habitat",
    "host_species",
    "host_genotype",
    "season",
    "collection_year",
    "replicate",
    "collection_date",
    "cutting_location",
    "treatment",
    "sample_type",
    "location"
  )
  
  tmp3 <- x %>%
    
    add_column(!!!tmp1[!names(tmp1) %in% names(.)]) %>%
    
    select(all_of(tmp2))
  
  return(tmp3)
}

davis_16s_metadata <- clargs[22:(length(clargs) - 1)] %>%
  
  map(., .f = read_tsv) %>%
  
  map(., .f = rename_cols) %>%
  
  map(., .f = add_col) %>%
  
  set_names(
    nm = c("Feb_BS", "Feb_BSRH", "Feb_RE", "Feb_RH",
           "July_BS", "July_RE1", "July_RE2", "July_RH")
  ) %>%
  
  bind_rows(.id = "ID") %>%
  
  separate(ID, into = c("month", "substrate"), sep = "_") %>%
  
  mutate(
    location = "Davis, CA",
    host_species = "Populus trichocarpa",
    community = "Bacteria and Archaea",
    
    sample_type = ifelse(sample_type == "Rhizo", "RH", sample_type),
    sample_type = ifelse(sample_type == "Bulk Soil", "BS", sample_type),
    sample_type = ifelse(substrate == "BS", "BS", sample_type),
    sample_type = ifelse(substrate == "RH", "RH", sample_type),
    sample_type = ifelse(substrate %in% c("RE", "RE1", "RE2"), "RE", sample_type),
    
    sample_id = paste(sample_code, "16S", sample_type, month, sep = "-"),
    
    plant_habitat = ifelse(
      sample_type == "BS",
      "Soil",
      plant_habitat
    ),
    
    plant_habitat = ifelse(
      sample_type == "RH",
      "Rhizosphere",
      plant_habitat
    ),
    
    plant_habitat = ifelse(
      sample_type == "RE",
      "Root endosphere",
      plant_habitat
    ),
    
    season = ifelse(
      month == "Feb",
      "Winter",
      season
    ),
    
    season = ifelse(
      month == "July",
      "Summer",
      season
    )
  ) %>%
  
  select(-sample_name) %>%
  
  full_join(., davis_16s_manifest, by = "sample_id", relationship = "many-to-many") %>%
  
  filter(!is.na(sample_name)) %>%
  
  mutate(
    location = ifelse(
      is.na(location),
      "Davis, CA",
      location
    ),
    
    treatment = ifelse(
      is.na(treatment) & str_detect(sample_id, "Control"),
      "Control",
      treatment
    ),
    
    treatment = ifelse(
      is.na(treatment) & str_detect(sample_id, "Drought"),
      "Drought",
      treatment
    ),
    
    plant_habitat = ifelse(
      is.na(plant_habitat) & str_detect(sample_id, "-BS-"),
      "Soil",
      plant_habitat
    ),
    
    season = ifelse(
      is.na(season) & str_detect(sample_id, "-Feb"),
      "Winter",
      season
    )
  ) %>%
  
  select(
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
  davis_16s_metadata,
  file = clargs[length(clargs)]
)
