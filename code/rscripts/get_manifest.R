#### 1. Libraries ####

# Load libraries
library(tidyverse)

### 2. Functions ####

#### Function to make manifest files from a list of paths ####

make_manifest <- function(path, output.path, manifest.name) {
  
  # list paths (don't change)
  manifest <- data.frame(list.files(path), stringsAsFactors = F)
  
  absolute_filepath <- paste(path, manifest$list.files.path., sep = "")
  
  direction <- rep(c("forward","reverse"), dim(manifest)[1] / 2)
  
  # create sample_id, combine, spread, and adjust column names (don't change)
  sample_id <- sapply(strsplit(manifest$list.files.path., "_"), "[", 1)
  
  manifest1 <- cbind.data.frame(sample_id, absolute_filepath, direction)
  
  manifest2 <- spread(manifest1, key = direction, value = absolute_filepath)
  
  names(manifest2) <- c("sample-id", "forward-absolute-filepath", "reverse-absolute-filepath")
  
  tmp1 <- paste(output.path, manifest.name, sep = "/")
  
  # write as a .tsv (change location)
  write.table(
    
    manifest2, 
    
    tmp1,
    
    quote = FALSE,
    
    append = FALSE,
    
    row.names = FALSE,
    
    col.names = TRUE,
    
    sep = "\t"
    
  )
  
}

# Format path names
format_path <- function(path) {
  
  tmp1 <- paste(path, "/reads/", sep = "")
  
  return(tmp1)
  
}

# Format output
format_output <- function(manifest.name) {
  
  tmp1 <- paste("manifest_", manifest.name, ".txt", sep = "")
  
  return(tmp1)
  
}

#### 3. BC 16S ####

# BC 16S input
BC_16S_paths <- list.files(
  
  path = "data/qiime2/raw/BC/16S",
  
  full.names = TRUE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_path) %>%
  
  map_chr(., .f = normalizePath)

# BC 16S output
BC_16S_manifest_name <- list.files(
  
  path = "data/qiime2/raw/BC/16S",
  
  full.names = FALSE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_output)

# Output directory
BC_16S_manifest_output <- rep(
  
  "data/qiime2/manifest_files/BC/16S",
  
  length(BC_16S_manifest_name)
  
)

# BC 16S manifest
pmap(
  
  list(
    
    BC_16S_paths,
    
    BC_16S_manifest_output,
    
    BC_16S_manifest_name
    
  ),
  
  .f = make_manifest
  
)

#### 4. BC ITS ####

# BC ITS input
BC_ITS_paths <- list.files(
  
  path = "data/qiime2/raw/BC/ITS",
  
  full.names = TRUE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_path) %>%
  
  map_chr(., .f = normalizePath)

# BC ITS output
BC_ITS_manifest_name <- list.files(
  
  path = "data/qiime2/raw/BC/ITS",
  
  full.names = FALSE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_output)

# Output directory
BC_ITS_manifest_output <- rep(
  
  "data/qiime2/manifest_files/BC/ITS",
  
  length(BC_ITS_manifest_name)
  
)

# BC ITS manifest
pmap(
  
  list(
    
    BC_ITS_paths,
    
    BC_ITS_manifest_output,
    
    BC_ITS_manifest_name
    
  ),
  
  .f = make_manifest
  
)

#### 5. Update format path function ####

# Format path names
format_path2 <- function(path) {
  
  tmp1 <- paste(path, "/", sep = "")
  
  return(tmp1)
  
}

#### 6. DAVIS 16S ####

# DAVIS 16S input
DAVIS_16S_paths <- list.files(
  
  path = "data/qiime2/raw/DAVIS/16S",
  
  full.names = TRUE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_path2) %>%
  
  map_chr(., .f = normalizePath)

# DAVIS 16S output
DAVIS_16S_manifest_name <- list.files(
  
  path = "data/qiime2/raw/DAVIS/16S",
  
  full.names = FALSE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_output)

# Output directory
DAVIS_16S_manifest_output <- rep(
  
  "data/qiime2/manifest_files/DAVIS/16S",
  
  length(DAVIS_16S_manifest_name)
  
)

# DAVIS 16S manifest
pmap(
  
  list(
    
    DAVIS_16S_paths,
    
    DAVIS_16S_manifest_output,
    
    DAVIS_16S_manifest_name
    
  ),
  
  .f = make_manifest
  
)

#### 7. DAVIS ITS ####

# DAVIS ITS input
DAVIS_ITS_paths <- list.files(
  
  path = "data/qiime2/raw/DAVIS/ITS",
  
  full.names = TRUE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_path2) %>%
  
  map_chr(., .f = normalizePath)

# DAVIS ITS output
DAVIS_ITS_manifest_name <- list.files(
  
  path = "data/qiime2/raw/DAVIS/ITS",
  
  full.names = FALSE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_output)

# Output directory
DAVIS_ITS_manifest_output <- rep(
  
  "data/qiime2/manifest_files/DAVIS/ITS",
  
  length(DAVIS_ITS_manifest_name)
  
)

# DAVIS ITS manifest
pmap(
  
  list(
    
    DAVIS_ITS_paths,
    
    DAVIS_ITS_manifest_output,
    
    DAVIS_ITS_manifest_name
    
  ),
  
  .f = make_manifest
  
)

#### 8. BOARD 16S ####

# BOARD 16S input
BOARD_16S_paths <- list.files(
  
  path = "data/qiime2/raw/BOARD/16S",
  
  full.names = TRUE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_path2) %>%
  
  map_chr(., .f = normalizePath)

# BOARD 16S output
BOARD_16S_manifest_name <- list.files(
  
  path = "data/qiime2/raw/BOARD/16S",
  
  full.names = FALSE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_output)

# Output directory
BOARD_16S_manifest_output <- rep(
  
  "data/qiime2/manifest_files/BOARD/16S",
  
  length(BOARD_16S_manifest_name)
  
)

# BOARD 16S manifest
pmap(
  
  list(
    
    BOARD_16S_paths,
    
    BOARD_16S_manifest_output,
    
    BOARD_16S_manifest_name
    
  ),
  
  .f = make_manifest
  
)

#### 9. BOARD ITS ####

# BOARD ITS input
BOARD_ITS_paths <- list.files(
  
  path = "data/qiime2/raw/BOARD/ITS",
  
  full.names = TRUE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_path2) %>%
  
  map_chr(., .f = normalizePath)

# BOARD ITS output
BOARD_ITS_manifest_name <- list.files(
  
  path = "data/qiime2/raw/BOARD/ITS",
  
  full.names = FALSE,
  
  include.dirs = TRUE
  
) %>%
  
  map_chr(., .f = format_output)

# Output directory
BOARD_ITS_manifest_output <- rep(
  
  "data/qiime2/manifest_files/BOARD/ITS",
  
  length(BOARD_ITS_manifest_name)
  
)

# BOARD ITS manifest
pmap(
  
  list(
    
    BOARD_ITS_paths,
    
    BOARD_ITS_manifest_output,
    
    BOARD_ITS_manifest_name
    
  ),
  
  .f = make_manifest
  
)
