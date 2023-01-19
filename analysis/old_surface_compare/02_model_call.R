library(tidyverse)
library(Maaslin2)
library(RColorBrewer)
library(viridis)
source("bin/project_variables.R")

humann_data = "data/master/humann_pathway_rel.tsv"

meta_data = "data/05_surface_compare/continous_removal_data.tsv"

Maaslin2(
  input_data = humann_data,
  input_metadata = meta_data,
  fixed_effects = c("c_mb_std"),
  output = "data/05_surface_compare/c_enzyme_remove",
  random_effects = c("treatment"),
  min_prevalence = .5,
  normalization = "NONE",
  min_abundance = 0
)



temp2 = read_tsv("data/05_surface_compare/bulk_mgCg/all_results.tsv")

maaslin_call = function(meta_path, output_path){
  Maaslin2(
    input_data = humann_data,
    input_metadata = meta_path,
    fixed_effects = c("treatment"),
    output = output_path,
    min_prevalence = 0.3,
    min_abundance = 0,
    normalization = "NONE"
  )
  
}

meta_data = fs::dir_ls("data/05_surface_compare/", glob = "*_co_data.tsv")

output_data = str_replace(meta_data, "_data.tsv", "_ko")

output_data

walk2(meta_data, output_data, maaslin_call)

total_data %>% ggplot(aes(x = total_mb_std, y = `P105-PWY`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
    scale_color_manual(values = color_pal) +
  labs(
    y = "TCA Cycle (relative abundance)", x = "Total Enzyme Activity", color = NULL
  )

total_data %>% ggplot(aes(x = pep_mb_std, y = `ALLANTOINDEG-PWY`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Allantoin Degradation (relative abundance", x = "Peptadase Activity", color = NULL)
