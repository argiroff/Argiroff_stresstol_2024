
library(tidyverse)

ancombc_16s <- read_tsv("data/processed/seq_data/16S/ancombc/ancombc_results.txt")

ancombc_its <- read_tsv("data/processed/seq_data/ITS/ancombc/ancombc_results.txt")

length(unique(ancombc_16s$otu_id))

length(unique(ancombc_its$otu_id))

sig_16s <- ancombc_16s %>%
  filter(str_detect(comparison, "pcorr_")) %>%
  filter(value <= 0.05)

sig_its <- ancombc_its %>%
  filter(str_detect(comparison, "pcorr_")) %>%
  filter(value <= 0.05)

length(unique(sig_16s$otu_id))

length(unique(sig_its$otu_id))

tax_16s <- read_tsv("data/processed/seq_data/16S/otu_processed/taxonomy_table.txt")

tax_its <- read_tsv("data/processed/seq_data/ITS/otu_processed/taxonomy_table.txt")

sig_tax_16s <- sig_16s %>%
  inner_join(tax_16s, ., by = "otu_id") %>%
  select(
    otu_id,
    Phylum,
    Class,
    Order,
    Family,
    Genus
  ) %>%
  distinct(.) %>%
  
  group_by(
    Phylum,
    Class,
    Order,
    Family
  ) %>%
  summarise(n_otus = n()) %>%
  ungroup(.) %>%
  arrange(desc(n_otus)) %>%
  mutate(perc_otus = (100 * (n_otus / sum(n_otus))))

non_sig_tax_16s <- ancombc_16s %>%
  filter(str_detect(comparison, "pcorr_")) %>%
  filter(value > 0.05) %>%
  inner_join(tax_16s, ., by = "otu_id") %>%
  select(
    otu_id,
    Phylum,
    Class,
    Order,
    Family,
    Genus
  ) %>%
  distinct(.) %>%
  
  group_by(
    Phylum,
    Class,
    Order,
    Family
  ) %>%
  summarise(n_otus = n()) %>%
  ungroup(.) %>%
  arrange(desc(n_otus)) %>%
  mutate(perc_otus = (100 * (n_otus / sum(n_otus))))

sig_tax_its <- sig_its %>%
  inner_join(tax_its, ., by = "otu_id") %>%
  select(
    otu_id,
    Phylum,
    Class,
    Order,
    Family,
    Genus
  ) %>%
  distinct(.) %>%
  
  group_by(
    Phylum,
    Class,
    Order,
    Family
  ) %>%
  summarise(n_otus = n()) %>%
  ungroup(.) %>%
  arrange(desc(n_otus)) %>%
  mutate(perc_otus = (100 * (n_otus / sum(n_otus))))

non_sig_tax_its <- ancombc_its %>%
  filter(str_detect(comparison, "pcorr_")) %>%
  filter(value > 0.05) %>%
  inner_join(tax_its, ., by = "otu_id") %>%
  select(
    otu_id,
    Phylum,
    Class,
    Order,
    Family,
    Genus
  ) %>%
  distinct(.) %>%
  
  group_by(
    Phylum,
    Class,
    Order,
    Family,
    Genus
  ) %>%
  summarise(n_otus = n()) %>%
  ungroup(.) %>%
  arrange(desc(n_otus)) %>%
  mutate(perc_otus = (100 * (n_otus / sum(n_otus))))
