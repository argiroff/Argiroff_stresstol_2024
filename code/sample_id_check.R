library(tidyverse)
library(qiime2R)
library(phyloseq)

path_16s <- list.files(
  path = "data/qiime2/16S/",
  include.dirs = TRUE,
  full.names = TRUE
)

get_manifest <- function(x) {
  tmp1 <- list.files(
    x,
    pattern = "manifest.txt",
    full.names = TRUE
  )
  
  return(tmp1)
}

dir_16s <- list.files(
  path = "data/qiime2/16S/",
  include.dirs = TRUE,
  full.names = FALSE
)

manifest_16s <- path_16s %>%
  
  map(., .f = get_manifest) %>%
  
  map(., .f = read_tsv) %>%
  
  set_names(nm = dir_16s) %>%
  
  bind_rows(.id = "ID") %>%
  
  select(ID, `sample-id`) %>%
  
  rename(sample_name = "sample-id")

path_its <- list.files(
  path = "data/qiime2/ITS/",
  include.dirs = TRUE,
  full.names = TRUE
)

dir_its <- list.files(
  path = "data/qiime2/ITS/",
  include.dirs = TRUE,
  full.names = FALSE
)

manifest_its <- path_its %>%
  
  map(., .f = get_manifest) %>%
  
  map(., .f = read_tsv) %>%
  
  set_names(nm = dir_its) %>%
  
  bind_rows(.id = "ID") %>%
  
  select(ID, `sample-id`)

# Make phyloseq object
ps_16s <- qza_to_phyloseq(
  features = "data/qiime2/final_qzas/16S/otu_97/clustered_table.qza",
  taxonomy = "data/qiime2/final_qzas/16S/otu_97_taxonomy/classification.qza"
)

# Add representative sequences
repseqs_16s_qza <- read_qza(
  file = "data/qiime2/final_qzas/16S/otu_97/clustered_sequences.qza"
)

repseqs_16s <- repseqs_16s_qza$data

ps_16s <- merge_phyloseq(ps_16s, repseqs_16s)

test3 <- read_tsv("data/processed/seq_data/16S/metadata_16s.txt", col_types = cols(treatment = col_character()))
test4 <- test3 %>%
  full_join(., manifest_16s, by = "sample_name")
