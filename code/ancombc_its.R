#!/usr/bin/env Rscript --vanilla

# name : ancombc_its.R
# author: William Argiroff
# inputs : Files in ancombc/ITS/*_ps.rds
# output : ANCOMBC output as ancombc/ITS/*_ancombc_results.rds
# notes : expects order of inputs, output
#   expects input path data/processed/seq_data/ITS/ancombc/*
#   and output paths in data/processed/seq_data/ITS/ancombc/*
#   generated within this script

clargs <- commandArgs(trailingOnly = TRUE)

library(ANCOMBC)
library(phyloseq)
library(tidyverse)

ps <- read_rds(
  file = clargs[1]
)

# Select sequence cutoff
if(clargs[1] == "bc_re_2018_ps.rds") {
  seq_cutoff <- 1000
  
} else if(clargs[1] == "bc_re_2019_ps.rds") {
  seq_cutoff <- 1000
  
} else if(clargs[1] == "bc_rh_2018_ps.rds") {
  seq_cutoff <- 5000
  
} else if(clargs[1] == "bc_rh_2019_ps.rds") {
  seq_cutoff <- 5000
  
} else if(clargs[1] == "board_bs_ps.rds") {
  seq_cutoff <- 1000
  
} else if(clargs[1] == "board_re_ps.rds") {
  seq_cutoff <- 1000
  
} else if(clargs[1] == "board_rh_ps.rds") {
  seq_cutoff <- 1000
  
} else if(clargs[1] == "davis_bs_control_ps.rds") {
  seq_cutoff <- 2000
  
} else if(clargs[1] == "davis_bs_drought_ps.rds") {
  seq_cutoff <- 2000
  
} else if(clargs[1] == "davis_bs_summer_ps.rds") {
  seq_cutoff <- 1000
  
} else if(clargs[1] == "davis_bs_winter_ps.rds") {
  seq_cutoff <- 10000
  
} else if(clargs[1] == "davis_re_control_ps.rds") {
  seq_cutoff <- 200
  
} else if(clargs[1] == "davis_re_drought_ps.rds") {
  seq_cutoff <- 300
  
} else if(clargs[1] == "davis_re_winter_ps.rds") {
  seq_cutoff <- 200
  
} else if(clargs[1] == "davis_re_summer_ps.rds") {
  seq_cutoff <- 1000
  
}else if(clargs[1] == "davis_rh_control_ps.rds") {
  seq_cutoff <- 5000
  
} else if(clargs[1] == "davis_rh_drought_ps.rds") {
  seq_cutoff <- 5000
  
} else if(clargs[1] == "davis_rh_summer_ps.rds") {
  seq_cutoff <- 2500
  
} else if(clargs[1] == "davis_rh_winter_ps.rds") {
  seq_cutoff <- 10000
  
} else if(clargs[1] == "location_bs_ps.rds") {
  seq_cutoff <- 1000
  
} else if(clargs[1] == "location_re_ps.rds") {
  seq_cutoff <- 300
  
} else if(clargs[1] == "location_rh_ps.rds") {
  seq_cutoff <- 3000
  
} else {
  print("Design not detected, using seq. cutoff of 0.")
  
  seq_cutoff <- 0
}

# Names to determine ANCOMBC2 formula
bc_names <- c(
  "bc_re_2018_ps.rds",
  "bc_re_2019_ps.rds",
  "bc_rh_2018_ps.rds",
  "bc_rh_2019_ps.rds"
)

treatment_names <- c(
  "board_bs_ps.rds",
  "board_re_ps.rds",
  "board_rh_ps.rds",
  "davis_bs_summer_ps.rds",
  "davis_bs_winter_ps.rds",
  "davis_re_summer_ps.rds",
  "davis_re_winter_ps.rds",
  "davis_rh_summer_ps.rds",
  "davis_rh_winter_ps.rds"
)

davis_season_names <- c(
  "davis_bs_control_ps.rds",
  "davis_bs_drought_ps.rds",
  "davis_rh_control_ps.rds",
  "davis_rh_drought_ps.rds",
  "davis_re_control_ps.rds",
  "davis_re_drought_ps.rds"
)

location_names <- c(
  "location_bs_ps.rds",
  "location_re_ps.rds",
  "location_rh_ps.rds"
)

# Run ANCOMBC2
if(clargs[1] %in% bc_names) {
  ancombc_results <- ancombc2(
    data = ps,
    fix_formula = "season",
    group = "season",
    global = TRUE,
    pairwise = TRUE,
    n_cl = 32,
    verbose = TRUE,
    lib_cut = seq_cutoff
  )
  
} else if(clargs[1] %in% treatment_names) {
  ancombc_results <- ancombc2(
    data = ps,
    fix_formula = "treatment",
    n_cl = 32,
    verbose = TRUE,
    lib_cut = seq_cutoff
  )
  
} else if(clargs[1] %in% davis_season_names) {
  ancombc_results <- ancombc2(
    data = ps,
    fix_formula = "season",
    n_cl = 32,
    verbose = TRUE,
    lib_cut = seq_cutoff
  )
  
} else if(clargs[1] %in% location_names) {
  ancombc_results <- ancombc2(
    data = ps,
    fix_formula = "location",
    group = "location",
    global = TRUE,
    pairwise = TRUE,
    n_cl = 32,
    verbose = TRUE,
    lib_cut = seq_cutoff
  )
  
} else {
  seq_cutoff <- NULL
  
}

# Save results
write_rds(
  ancombc_results,
  file = clargs[2]
)
