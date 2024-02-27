#!/usr/bin/env Rscript --vanilla

# name : make_volcano_plots.R
# author: William Argiroff
# inputs : summarized ANCOMBC results
# output : tibble containing ANCOMBC LFC, SE, and P values
# notes : expects order of inputs, output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(cowplot)

clargs <- c(
  "data/processed/seq_data/16S/ancombc/bc_rh_2019_ancombc_results.txt",
  "results/bc_rh_2019_volcano_plot.pdf"
  )

# Get input file
indir <- paste(dirname(clargs[1]), "/", sep = "")
infile <- str_remove(clargs[1], indir)
in_name <- str_remove(infile, "_ancombc_results.txt")

# Format ancombc results
ancombc <- read_tsv(clargs[1]) %>%
  
  # Select variables
  select(
    otu_id,
    starts_with("lfc_"),
    starts_with("p_"),
    starts_with("pcorr_")
  ) %>%
  
  # Long format
  pivot_longer(
    -otu_id,
    names_to = "comparison",
    values_to = "value"
  ) %>%
  
  # Get statistic type and comparison
  separate(
    comparison,
    into = c("statistic", "comparison"),
    sep = "_",
    extra = "merge"
  ) %>%
  
  # Wide format
  pivot_wider(
    id_cols = c(otu_id, comparison),
    names_from = "statistic",
    values_from = "value"
  )

#### Function for volcano significance level ####

volcano_sig_label <- function(pval, pcorr.val) {
  
  if(pval <= 0.05 & pcorr.val > 0.05) {
    
    tmp1 <- "italic(P)<0.05"
    
  } else if(pval <= 0.05 & pcorr.val <= 0.05) {
    
    tmp1 <- "italic(P[adj.])<0.05"
    
  } else {
    
    tmp1 <- "italic(n.s)"
    
  }
  
  return(tmp1)
  
}

# Seasonal names
bc_seasonal_names <- c(
  "bc_re_2018",
  "bc_re_2019",
  "bc_rh_2018",
  "bc_rh_2019"
)

# Format for plot 
if(in_name %in% bc_seasonal_names) {
  
  ancombc_input <- ancombc %>%
    filter(!str_detect(comparison, "global_")) %>%
    
    # Calculate log10 P values and add a significance label
    mutate(
      log10_p = -1 * log10(p),
      sig_label = map2_chr(p, pcorr, .f = volcano_sig_label),
      sig_label = factor(
        sig_label,
        levels = c("italic(P[adj.])<0.05", "italic(P)<0.05", "italic(n.s)")
      )
    ) %>%
    
    # Update labels
    mutate(
      comparison = str_replace(comparison, "_", " vs. "),
      comparison = factor(
        comparison,
        levels = c("Spring vs. Winter", "Summer vs. Winter",
                   "Fall vs. Winter", "Summer vs. Spring",
                   "Fall vs. Spring", "Fall vs. Summer")
      )
    )
  
} else if() {
  
  
  
}

# Plot
volcano_plot <- ggplot() +
  
  geom_point(
    data = ancombc_input,
    aes(x = lfc, y = log10_p, fill = sig_label),
    pch = 21
  ) +
  
  facet_wrap(
    ~ comparison,
    scales = "free"
  ) + 
  
  scale_fill_manual(
    name = NULL,
    values = c("#FDAD32FF", "#3E049CFF", "grey"),
    labels = function(x) parse(text = x)
  ) +
  
  labs(
    y = bquote(italic(log[10])*"("*italic(P)*")"),
    x = "Log fold-change"
  ) +
  
  theme(
    
    # Panel background and border
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5),
    panel.background = element_blank(),
    
    # Title text
    plot.title = element_text(colour = "black", size = 14, hjust = 0.5),
    axis.title.y = element_text(colour = "black", size = 12),
    axis.title.x = element_text(colour = "black", size = 12),
    
    # Facet strip
    strip.background = element_blank(),
    strip.text = element_text(colour = "black", size = 10),
    
    # Legend
    legend.key = element_blank(),
    legend.text = element_text(colour = "black", size = 10, hjust = 0),
    legend.position = "bottom"
    
  )

# Plot title
if(in_name == "bc_re_2018") {
  
  volcano_plot_final <- volcano_plot +
    labs(title = "Blount County, 2018: Root endosphere")
  
  ggsave2(
    filename = clargs[2],
    plot = volcano_plot_final,
    device = "pdf",
    width = 6.5,
    height = 6,
    units = "in"
  )
  
} else if(in_name == "bc_re_2019") {
  
  volcano_plot_final <- volcano_plot +
    labs(title = "Blount County, 2019: Root endosphere")
  
  ggsave2(
    filename = clargs[2],
    plot = volcano_plot_final,
    device = "pdf",
    width = 6.5,
    height = 6,
    units = "in"
  )
  
} else if(in_name == "bc_rh_2018") {
  
  volcano_plot_final <- volcano_plot +
    labs(title = "Blount County, 2018: Rhizosphere")
  
  ggsave2(
    filename = clargs[2],
    plot = volcano_plot_final,
    device = "pdf",
    width = 6.5,
    height = 6,
    units = "in"
  )
  
} else if(in_name == "bc_rh_2019") {
  
  volcano_plot_final <- volcano_plot +
    labs(title = "Blount County, 2019: Rhizosphere")
  
  ggsave2(
    filename = clargs[2],
    plot = volcano_plot_final,
    device = "pdf",
    width = 6.5,
    height = 6,
    units = "in"
  )
  
}
