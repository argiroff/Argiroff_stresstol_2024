#!/usr/bin/env Rscript --vanilla

# name : make_volcano_plots.R
# author: William Argiroff
# inputs : summarized ANCOMBC results
# output : tibble containing ANCOMBC LFC, SE, and P values
# notes : expects order of inputs, output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(cowplot)

source("code/functions.R")

# Get input file
indir <- paste(dirname(clargs[1]), "/", sep = "")
infile <- str_remove(clargs[1], indir)
in_name <- str_remove(infile, "_ancombc_results.txt")

# Format ancombc results
ancombc <- read_tsv(clargs[1]) %>%
  pivot_ancombc(.)

# Seasonal names
bc_seasonal_names <- c(
  "bc_re_2018",
  "bc_re_2019",
  "bc_rh_2018",
  "bc_rh_2019"
)

# Treatment names
treatment_names <- c(
  "board_bs",
  "board_re",
  "board_rh",
  "davis_bs_summer",
  "davis_bs_winter",
  "davis_re_summer",
  "davis_re_winter",
  "davis_rh_summer",
  "davis_rh_winter"
)

# Davis season names
davis_season_names <- c(
  "davis_bs_control",
  "davis_bs_drought",
  "davis_re_control",
  "davis_re_drought",
  "davis_rh_control",
  "davis_rh_drought"
)

# Location
location_names_temp <- "location_bs"

location_names <- c(
  "location_re",
  "location_rh"
)

# Format for plot 
if(in_name %in% bc_seasonal_names) {
  
  ancombc_input <- ancombc %>%
    filter(!str_detect(comparison, "global_")) %>%
    
    # Calculate log10 P values and add a significance label
    format_volcano_data(.) %>%
    
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
  
} else if(in_name %in% c(treatment_names, davis_season_names, location_names_temp)) {
  
  # Format
  ancombc_input <- ancombc %>%
    
    # Calculate log10 P values and add a significance label
    format_volcano_data(.) %>%
    
    # Update labels
    mutate(
      comparison = str_replace(comparison, "_", " vs. ")
    )
    
} else if(in_name %in% location_names) {
  
  # Format
  ancombc_input <- ancombc %>%
    filter(!str_detect(comparison, "global_")) %>%
    
    # Calculate log10 P values and add a significance label
    format_volcano_data(.) %>%
    
    # Update labels
    mutate(
      comparison = str_replace(comparison, "_", " vs. "),
      comparison = factor(
        comparison,
        levels = c("Boardman vs. BlountCounty",
                   "Davis vs. BlountCounty",
                   "Davis vs. Boardman")
      )
    )
  
}

# Plot
volcano_plot <- ggplot() +
  
  scale_y_continuous(expand = expansion(mult = 0.1)) +
  
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
  
  plot_title = "Blount County, 2018: Root endosphere"
  
  fig_height <- 6
  
} else if(in_name == "bc_re_2019") {
  
  plot_title <- "Blount County, 2019: Root endosphere"
  
  fig_height <- 6
  
} else if(in_name == "bc_rh_2018") {
  
  plot_title <- "Blount County, 2018: Rhizosphere"
  
  fig_height <- 6
  
} else if(in_name == "bc_rh_2019") {
  
  plot_title <- "Blount County, 2019: Rhizosphere"
  
  fig_height <- 6
  
} else if(in_name == "board_bs") {
  
  plot_title <- "Boardman: Soil"
  
  fig_height <- 4.5
  
} else if(in_name == "board_re") {
  
  plot_title <- "Boardman: Root endosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "board_rh") {
  
  plot_title <- "Boardman: Rhizosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_bs_summer") {
  
  plot_title <- "Davis, Summer: Soil"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_bs_winter") {
  
  plot_title <- "Davis, Winter: Soil"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_re_summer") {
  
  plot_title <- "Davis, Summer: Root endosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_re_winter") {
  
  plot_title <- "Davis, Winter: Root endosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_rh_summer") {
  
  plot_title <- "Davis, Summer: Rhizosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_rh_winter") {
  
  plot_title <- "Davis, Winter: Rhizosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_bs_control") {
  
  plot_title <- "Davis, Control: Soil"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_bs_drought") {
  
  plot_title <- "Davis, Drought: Soil"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_re_control") {
  
  plot_title <- "Davis, Control: Root endosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_re_drought") {
  
  plot_title <- "Davis, Drought: Root endosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_rh_control") {
  
  plot_title <- "Davis, Control: Rhizosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "davis_rh_drought") {
  
  plot_title <- "Davis, Drought: Rhizosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "location_bs") {
  
  plot_title <- "Geographic location: Soil"
  
  fig_height <- 4.5
  
} else if(in_name == "location_re") {
  
  plot_title <- "Geographic location: Root endosphere"
  
  fig_height <- 4.5
  
} else if(in_name == "location_rh") {
  
  plot_title <- "Geographic location: Rhizosphere"
  
  fig_height <- 4.5
  
}

# Add title
volcano_plot_final <- volcano_plot +
  labs(title = plot_title)

# Save
ggsave2(
  filename = clargs[2],
  plot = volcano_plot_final,
  device = "pdf",
  width = 6.5,
  height = fig_height,
  units = "in"
)

file.remove("Rplots.pdf")
