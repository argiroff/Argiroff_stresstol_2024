#!/usr/bin/env Rscript --vanilla

# name : get_input_for_spieceasi.R
# author: William Argiroff
# inputs : Files in spieceasi/*_ps.rds
# output : SPIECEASI output as spieceasi/*_ancombc_results.rds
# notes : expects order of inputs, output
#   expects input path data/processed/seq_data/spieceasi/*
#   and output paths in data/processed/seq_data/spieceasi/*
#   generated within this script

clargs <- commandArgs(trailingOnly = TRUE)

library(ANCOMBC)
library(phyloseq)
library(tidyverse)

test1 <- 
