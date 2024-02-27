#!/usr/bin/env Rscript --vanilla

# name : extract_ancombc_results.R
# author: William Argiroff
# inputs : ANCOMBC results as .rds
# output : tibble containing ANCOMBC LFC, SE, and P values
# notes : expects order of inputs, output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# Get input file names
infile_names <- clargs[c(1 : length(clargs) - 1)]
indir <- paste(dirname(clargs[1]), "/", sep = "")
list_names <- str_remove(infile_names, indir) %>%
  str_remove(., "_ancombc_results.txt")

# Read in data
ancombc <- infile_names %>%
  map(., .f = read_tsv) %>%
  set_names(nm = list_names) %>%
  
  # Combine data
  map(., .f = pivot_ancombc) %>%
  bind_rows(.id = "ID")

# Save data
write_tsv(
  ancombc,
  file = clargs[length(clargs)]
)
