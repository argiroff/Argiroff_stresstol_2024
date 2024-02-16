
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
    sample_code = NA_character_,
    sample_name = NA_character_,
    sample_id = NA_character_,
    community = NA_character_,
    plant_habitat = NA_character_,
    host_species = NA_character_,
    host_genotype = NA_character_,
    season = NA_character_,
    collection_year = NA_character_,
    replicate = NA_character_,
    collection_date = NA_character_,
    cutting_location = NA_character_,
    treatment = NA_character_,
    sample_type = NA_character_,
    location = NA_character_
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

#### Drop OTUs with no sequences ####

drop_0seq_otus <- function(x) {
  tmp1 <- x %>%
    
    group_by(otu_id) %>%
    
    mutate(otu_n_seqs = sum(n_seqs)) %>%
    
    ungroup(.) %>%
    
    filter(otu_n_seqs > 0) %>%
    
    select(-otu_n_seqs)
  
  return(tmp1)
}

#### Drop samples with no sequences ####

drop_0seq_samples <- function(x) {
  tmp1 <- x %>%
    
    group_by(sample_id) %>%
    
    mutate(sample_n_seqs = sum(n_seqs)) %>%
    
    ungroup(.) %>%
    
    filter(sample_n_seqs > 0) %>%
    
    select(-sample_n_seqs)
  
  return(tmp1)
}

#### Drop samples with no sequences 2 ####

drop_0seq_samples2 <- function(x) {
  tmp1 <- x %>%
    
    group_by(sample_id2) %>%
    
    mutate(sample_n_seqs = sum(n_seqs)) %>%
    
    ungroup(.) %>%
    
    filter(sample_n_seqs > 0) %>%
    
    select(-sample_n_seqs)
  
  return(tmp1)
}

#### Function to filter OTUs ####

filter_otus <- function(otu.tab, otu.prev, sample.cut) {
  
  tmp1 <- otu.tab %>%
    group_by(sample_id2) %>%
    mutate(sample_n_seqs = sum(n_seqs)) %>%
    ungroup(.)
  
  tmp2 <- length(unique(tmp1$sample_id2))
  
  tmp3 <- tmp1 %>%
    mutate(pres_abs = ifelse(n_seqs > 0, 1, 0)) %>%
    group_by(otu_id) %>%
    summarise(samples_pres = sum(pres_abs)) %>%
    ungroup() %>%
    mutate(prop_samples_pres = samples_pres / tmp2) %>%
    filter(prop_samples_pres >= otu.prev) %>%
    pull(otu_id)
  
  tmp4 <- tmp1 %>%
    filter(otu_id %in% tmp3) %>%
    group_by(sample_id2) %>% 
    mutate(remaining_n_seqs = sum(n_seqs)) %>% 
    ungroup() %>% 
    filter(remaining_n_seqs >= sample.cut) %>% 
    select(sample_id2, otu_id, n_seqs)
  
  return(tmp4)
  
}

#### Function to get sample ID filter ####

get_sample_id_filter <- function(otu.ba, otu.fungi) {
  
  tmp1 <- otu.ba %>%
    select(sample_id2) %>%
    distinct(.)
  
  tmp2 <- otu.fungi %>%
    select(sample_id2) %>%
    distinct(.) %>%
    inner_join(tmp1, ., by = "sample_id2") %>%
    arrange(sample_id2) %>%
    pull(sample_id2)
  
  return(tmp2)
  
}

# #### Function to write out OTU files ####
# 
# write_otu_files <- function(otu.table, list.names) {
#   tmp0 <- paste(clargs[6], list.names, sep = "/")
#   
#   if(file.exists(tmp0)) {
#     print(paste("Clearing directory ", list.names, sep = ""))
#     
#     file.remove(list.files(tmp0, full.names = TRUE))
#     
#   } else {
#     print(paste("Creating directory ", list.names, sep = ""))
#     
#     dir.create(tmp0)
#   }
#   
#   tmp1 <- otu.table %>%
#     
#     select(sample_id, otu_id, n_seqs)
#   
#   write_tsv(
#     tmp1,
#     file = paste(tmp0, "otu_table.txt", sep = "/")
#   )
#   
#   tmp2 <- otu.table %>%
#     
#     select(-c(otu_id, n_seqs)) %>%
#     
#     distinct(.)
#   
#   write_tsv(
#     tmp2,
#     file = paste(tmp0, "metadata_table.txt", sep = "/")
#   )
#   
#   tmp3 <- repseqs[unique(otu.table$otu_id)]
#   
#   Biostrings::writeXStringSet(
#     tmp3,
#     filepath = paste(tmp0, "representative_sequences.fasta", sep = "/"),
#     format = "fasta"
#   )
#   
#   tmp4 <- tax_table %>%
#     
#     filter(otu_id %in% unique(otu.table$otu_id))
#   
#   write_tsv(
#     tmp4,
#     file = paste(tmp0, "taxonomy_table.txt", sep = "/")
#   )
# }
# 
# #### Refactor phyloseq object for ancombc2 ###
# 
# refactor_ps_16s <- function(ps.obj, in.path) {
#   tmp1 <- str_remove(
#     string = in.path,
#     pattern = "data/processed/seq_data/16S/ancombc/"
#   )
#   
#   tmp2 <- str_remove(
#     string = tmp1,
#     pattern = "/metadata_table.txt"
#   )
#   
#   tmp3 <- c(
#     "BC_RE_2018", "BC_RE_2019",
#     "BC_RH_2018", "BC_RE_2019"
#   )
#   
#   tmp4 <- c(
#     "BOARD_BS", "BOARD_RE",
#     "BOARD_RH"
#   )
#   
#   tmp5 <- c(
#     "DAVIS_BS_CONTROL", "DAVIS_BS_DROUGHT",
#     "DAVIS_RH_CONTROL", "DAVIS_RH_DROUGHT"
#   )
#   
#   tmp6 <- c(
#     "DAVIS_BS_SUMMER", "DAVIS_BS_WINTER",
#     "DAVIS_RH_SUMMER", "DAVIS_RH_WINTER"
#   )
#   
#   tmp7 <- c(
#     "LOCATION_BS", "LOCATION_RE",
#     "LOCATION_RH"
#   )
#   
#   tmp9 <- ps.obj
#   
#   if(tmp2 %in% tmp3) {
#     sample_data(tmp9)$season <- factor(
#       sample_data(tmp9)$season,
#       levels = c("Winter", "Spring", "Summer", "Fall")
#     )
#     
#   } else if(tmp2 %in% tmp4) {
#     sample_data(tmp9)$treatment <- factor(
#       sample_data(tmp9)$treatment,
#       levels = c("Control", "Drought")
#     )
#     
#   } else if(tmp2 %in% tmp5) {
#     sample_data(tmp9)$season <- factor(
#       sample_data(tmp9)$season,
#       levels = c("Summer", "Winter")
#     )
#     
#   } else if(tmp2 %in% tmp6) {
#     sample_data(tmp9)$treatment <- factor(
#       sample_data(tmp9)$treatment,
#       levels = c("Control", "Drought")
#     )
#     
#   } else if(tmp2 %in% tmp7) {
#     sample_data(tmp9)$location <- factor(
#       sample_data(tmp9)$location,
#       levels = c("Blount County, TN", "Boardman, OR", "Davis, CA")
#     )
#     
#   } else {
#     tmp9 <- ps.obj
#     
#   }
#   
#   return(tmp9)
# }
