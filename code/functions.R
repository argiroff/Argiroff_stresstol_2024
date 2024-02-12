
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
