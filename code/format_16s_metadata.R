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

    sample_type = NA,

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

    treatment = NA

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

#### BOARD ####

# Read in
board_16s_metadata <- read_tsv(
  file = clargs[5]
) %>%

  filter(marker_gene == "16s") %>%

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
      community == "16s",
      "Bacteria and Archaea",
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

    season = NA,

    location = "Boardman, OR",

    collection_year = NA,

    replicate = NA,

    cutting_location = NA
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

davis_16s_manifest <- clargs[6:26] %>%

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

davis_16s_metadata <- clargs[27:34] %>%

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

    treatment = ifelse(
      str_detect(sample_id, "Control"),
      "Control",
      treatment
    ),

    treatment = ifelse(
      str_detect(sample_id, "Drought"),
      "Drought",
      treatment
    ),

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

#### Combine ####

metadata_16s <- bind_rows(
  bc_16s_metadata,
  board_16s_metadata,
  davis_16s_metadata
)

# Save
write_tsv(
  metadata_16s,
  file = clargs[35]
)
