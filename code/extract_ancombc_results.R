#!/usr/bin/env Rscript --vanilla

# name : extract_ancombc_results.R
# author: William Argiroff
# inputs : ANCOMBC results as .rds
# output : tibble containing ANCOMBC LFC, SE, and P values
# notes : expects order of inputs, output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get ANCOMBC output
ancombc <- read_rds(clargs[1])

indir <- paste(dirname(clargs[1]), "/", sep = "")
infile <- str_remove(clargs[1], indir)

bc_season_files <- c(
  "bc_re_2018_ancombc_results.rds",
  "bc_re_2019_ancombc_results.rds",
  "bc_rh_2018_ancombc_results.rds",
  "bc_rh_2019_ancombc_results.rds"
)

treatment_files <- c(
  "board_bs_ancombc_results.rds",
  "board_re_ancombc_results.rds",
  "board_rh_ancombc_results.rds",
  "davis_bs_summer_ancombc_results.rds",
  "davis_bs_winter_ancombc_results.rds",
  "davis_re_summer_ancombc_results.rds",
  "davis_re_winter_ancombc_results.rds",
  "davis_rh_summer_ancombc_results.rds",
  "davis_rh_winter_ancombc_results.rds"
)

davis_season_files <- c(
  "davis_bs_control_ancombc_results.rds",
  "davis_bs_drought_ancombc_results.rds",
  "davis_re_control_ancombc_results.rds",
  "davis_re_drought_ancombc_results.rds",
  "davis_rh_control_ancombc_results.rds",
  "davis_rh_drought_ancombc_results.rds"
)

location_files_temp <- "location_bs_ancombc_results.rds"

location_files <- c(
  "location_re_ancombc_results.rds",
  "location_rh_ancombc_results.rds"
)

#### Function to rename season ####

rename_season <- function(x) {
  
  tmp1 <- paste(x, "Winter", sep = "_")
  
  return(tmp1)
  
}

#### Function to rename location ####

rename_location <- function(x) {
  
  tmp1 <- str_replace(x, "\\,.*", "_BlountCounty")
  
  return(tmp1)
  
}

if(infile %in% bc_season_files) {
  
  # Global test
  ancombc_global <- ancombc$res_global %>%
    rename(
      otu_id = "taxon",
      p_global_season = "p_val",
      pcorr_global_season = "q_val",
      diff_global_season = diff_abn
    ) %>% 
    select(-W)
  
  # Pairwise test
  ancombc_pair_temp <- ancombc$res_pair %>%
    rename(otu_id = "taxon") %>%
    rename_with(., ~ str_replace_all(., "season", "")) %>%
    rename_with(., ~ str_replace(., "q_", "pcorr_")) %>%
    select(-contains("W_"))
  
  # Update column names
  ancombc_pair_names <- which(str_count(names(ancombc_pair_temp), "_") == 1)
  
  ancombc_pair <- ancombc_pair_temp %>%
    rename_with(., ~ rename_season(.x), all_of(ancombc_pair_names)) %>%
    rename(otu_id = "otu_id_Winter")
  
  # Final table
  ancombc_out <- ancombc_global %>%
    full_join(., ancombc_pair, by = "otu_id")
  
} else if(infile %in% treatment_files) {
  
  # Get results
  ancombc_out <- ancombc$res %>%
    rename(otu_id = "taxon") %>%
    rename_with(., ~ str_replace_all(., "treatmentDrought", "Drought_Control")) %>%
    rename_with(., ~ str_replace(., "q_", "pcorr_")) %>%
    select(
      -contains("Intercept"),
      -contains("W_")
    )
  
} else if(infile %in% davis_season_files) {
  
  # Get results
  ancombc_out <- ancombc$res %>%
    rename(otu_id = "taxon") %>%
    #rename_with(., ~ str_replace_all(., "seasonWinter", "Winter_Summer")) %>%
    rename_with(., ~ str_replace_all(., "seasonSummer", "Summer_Winter")) %>%
    rename_with(., ~ str_replace(., "q_", "pcorr_")) %>%
    select(
      -contains("Intercept"),
      -contains("W_")
    )
  
} else if(infile %in% location_files_temp) {
  
  # Get results
  ancombc_out <- ancombc$res %>%
    rename(otu_id = "taxon") %>%
    rename_with(., ~ str_replace_all(., "locationDavis, CA", "Davis_Boardman")) %>%
    rename_with(., ~ str_replace(., "q_", "pcorr_")) %>%
    select(
      -contains("Intercept"),
      -contains("W_")
    )
  
} else if(infile %in% location_files) {
  
  # Global test
  ancombc_global <- ancombc$res_global %>%
    rename(
      otu_id = "taxon",
      p_global_location = "p_val",
      pcorr_global_location = "q_val",
      diff_global_location = diff_abn
    ) %>% 
    select(-W)
  
  # Pairwise test
  ancombc_pair_temp <- ancombc$res_pair %>%
    rename(otu_id = "taxon") %>%
    rename_with(., ~ str_replace_all(., "location", "")) %>%
    rename_with(., ~ str_replace(., "q_", "pcorr_")) %>%
    rename_with(., ~ str_replace(., "Davis, CA_Boardman, OR", "Davis_Boardman")) %>%
    select(-contains("W_"))
  
  # Update column names
  ancombc_pair_names <- which(str_count(names(ancombc_pair_temp), "_") == 1)
  
  ancombc_pair <- ancombc_pair_temp %>%
    rename_with(., ~ rename_location(.x), all_of(ancombc_pair_names))
  
  # Final table
  ancombc_out <- ancombc_global %>%
    full_join(., ancombc_pair, by = "otu_id")
  
} else {
  
  ancombc_out <- NULL
  
}

# Save
write_tsv(
  ancombc_out,
  file = clargs[2]
)
