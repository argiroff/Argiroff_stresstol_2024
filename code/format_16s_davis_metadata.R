#!/usr/bin/env Rscript --vanilla

# name : format_16s_davis_metadata.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   data/qiime2/16S/*/manifest.txt
#   data/metadata/DAVIS/*.txt
# output : Single uniform metadata file to merge with phyloseq object
# notes : expects order of inputs (args ##-##) output

clargs <- commandArgs(trailingOnly = TRUE)

source("code/functions.R")

library(tidyverse)

#### DAVIS ####

#### Function to updated sample IDs ####

update_16s_sample_id <- function(x, y) {

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

davis_16s_manifest <- clargs[1:7] %>%

  .[str_detect(., "DAVIS")] %>%

  map(., .f = read_tsv) %>%

  set_names(
    nm = c("Feb_BS1", "Feb_RE1", "Feb_RH1", "Feb_RH_BS", "July_BS1",
           "July_RH1", "July_RH_BS")
  ) %>%

  bind_rows(.id = "ID") %>%

  select(`sample-id`, ID) %>%

  separate(ID, into = c("month", "sample_type"), extra = "merge", sep = "_") %>%

  mutate(
    sample_id = map2_chr(`sample-id`, month, .f = update_16s_sample_id)
  ) %>%

  rename(sample_name= "sample-id") %>%

  select(sample_name, sample_id)

davis_16s_metadata <- clargs[8:(length(clargs) - 1)] %>%
  
  map(., .f = read_tsv) %>%

  map(., .f = rename_cols) %>%

  map(., .f = add_col) %>%

  set_names(
    nm = c("Feb_BSRH", "Feb_BS", "Feb_RE", "Feb_RH",
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
