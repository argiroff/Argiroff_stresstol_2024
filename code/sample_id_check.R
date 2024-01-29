library(tidyverse)

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
  
  select(ID, `sample-id`)

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
