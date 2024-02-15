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
if(str_detect(clargs[1], "bc_re_2018")) {
  seq_cutoff <- 1000
  
} else if(str_detect(clargs[1], "bc_re_2019")) {
  seq_cutoff <- 1000
  
} else if(str_detect(clargs[1], "bc_rh_2018")) {
  seq_cutoff <- 5000
  
} else if(str_detect(clargs[1], "bc_rh_2019")) {
  seq_cutoff <- 5000
  
} else if(str_detect(clargs[1], "board_bs")) {
  seq_cutoff <- 1000
  
} else if(str_detect(clargs[1], "board_re")) {
  seq_cutoff <- 1000
  
} else if(str_detect(clargs[1], "board_rh")) {
  seq_cutoff <- 1000
  
} else if(str_detect(clargs[1], "davis_bs_control")) {
  seq_cutoff <- 2000
  
} else if(str_detect(clargs[1], "davis_bs_drought")) {
  seq_cutoff <- 2000
  
} else if(str_detect(clargs[1], "davis_bs_summer")) {
  seq_cutoff <- 1000
  
} else if(str_detect(clargs[1], "davis_bs_winter")) {
  seq_cutoff <- 10000
  
} else if(str_detect(clargs[1], "davis_re_control")) {
  seq_cutoff <- 200
  
} else if(str_detect(clargs[1], "davis_re_drought")) {
  seq_cutoff <- 300
  
} else if(str_detect(clargs[1], "davis_re_winter")) {
  seq_cutoff <- 200
  
} else if(str_detect(clargs[1], "davis_re_summer")) {
  seq_cutoff <- 1000
  
}else if(str_detect(clargs[1], "davis_rh_control")) {
  seq_cutoff <- 5000
  
} else if(str_detect(clargs[1], "davis_rh_drought")) {
  seq_cutoff <- 5000
  
} else if(str_detect(clargs[1], "davis_rh_summer")) {
  seq_cutoff <- 2500
  
} else if(str_detect(clargs[1], "davis_rh_winter")) {
  seq_cutoff <- 10000
  
} else if(str_detect(clargs[1], "location_bs")) {
  seq_cutoff <- 1000
  
} else if(str_detect(clargs[1], "location_re")) {
  seq_cutoff <- 300
  
} else if(str_detect(clargs[1], "location_rh")) {
  seq_cutoff <- 3000
  
} else {
  print("Design not detected, using seq. cutoff of 0.")
  
  seq_cutoff <- 0
}

# Names to determine ANCOMBC2 formula
bc_names <- paste(
  c("bc_re_2018", "bc_re_2019", "bc_rh_2018", "bc_rh_2019"),
  collapse = "|"
)

treatment_names <- paste(
  c("board_bs", "board_re", "board_rh", "davis_bs_summer", "davis_bs_winter",
    "davis_re_summer", "davis_re_winter", "davis_rh_summer", "davis_rh_winter"),
  collapse = "|"
)

davis_season_names <- paste(
  c("davis_bs_control", "davis_bs_drought", "davis_rh_control",
    "davis_rh_drought", "davis_re_control", "davis_re_drought"),
  collapse = "|"
)

location_names <- paste(
  c("location_bs", "location_re", "location_rh"),
  collapse = "|"
)

# Run ANCOMBC2
if(str_detect(clargs[1], bc_names)) {
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
  
} else if(str_detect(clargs[1], treatment_names)) {
  ancombc_results <- ancombc2(
    data = ps,
    fix_formula = "treatment",
    n_cl = 32,
    verbose = TRUE,
    lib_cut = seq_cutoff
  )
  
} else if(str_detect(clargs[1], davis_season_names)) {
  ancombc_results <- ancombc2(
    data = ps,
    fix_formula = "season",
    n_cl = 32,
    verbose = TRUE,
    lib_cut = seq_cutoff
  )
  
} else if(str_detect(clargs[1], location_names)) {
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
