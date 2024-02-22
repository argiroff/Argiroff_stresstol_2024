#!/usr/bin/env Rscript --vanilla

# name : run_spieceasi.R
# author: William Argiroff
# inputs : Files in otu_processed for 16S and ITS
# output : SPIECEASI results output as spieceasi/*_spieceasi_results.rds
# notes : expects order of inputs, output
#   expects input path spieceasi/*16s_input.rds and
#   spieceasi/*its_input.rds
#   and output paths in spieceasi/*_spieceasi_results.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(SpiecEasi)

# Read in data
input_16s <- readRDS(file = clargs[1])

input_its <- readRDS(file = clargs[2])

# Get network
ntwrk <- spiec.easi(
  list(input_16s, input_its),
  method = "mb",
  nlambda = 50,
  lambda.min.ratio = 1e-3,
  pulsar.params = list(thresh = 0.01, seed = 12345, ncores = 32)
)

# Get matrix of edges and nodes
ntwrk_edge <- symBeta(getOptBeta(ntwrk), mode = 'maxabs')

colnames(ntwrk_edge) <- c(colnames(input_16s), colnames(input_its))

# Save data
saveRDS(
  bc_le_edge,
  file = "output/bc_le_spieceasi_network_matrix.rds"
)
