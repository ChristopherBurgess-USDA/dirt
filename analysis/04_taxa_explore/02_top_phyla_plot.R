library(tidyverse)
library(RColorBrewer)
source("bin/project_variables.R")


import_data <- read_csv("data/master/kraken_taxa.csv") %>%
  pivot_longer(contains("-"), names_to="sample_id", values_to = "value")
meta_data = read_tsv("data/05_surface_compare/continous_data.tsv") %>%
  filter(depth == "0-10") %>%
  select(sample_id, treatment) %>%
  mutate(treatment = factor(treatment, levels = t_levels))

taxa_data <- import_data %>%
  filter(str_detect(sample_id, "-a")) %>%
  filter(is.na(Class), !is.na(phyla)) 

top_taxa <- taxa_data %>%
  group_by(clade_name, phyla) %>%
  summarise(total = sum(value)) %>%
  arrange(desc(total)) %>%
  ungroup() %>%
  slice_head(n = 11) %>%
  pull(phyla)

totals <- taxa_data %>%
  group_by(sample_id) %>%
  summarise(total = sum(value))

plot_taxa <- taxa_data %>%
  filter(phyla %in% top_taxa) %>%
  left_join(meta_data) %>%
  left_join(totals) %>%
  mutate(rel_val = value/total) %>%
  group_by(treatment, phyla) %>%
  summarise(mean_count = mean(rel_val))
  
other_values = plot_taxa %>%
  ungroup() %>%
  group_by(treatment) %>%
  summarise(total = sum(mean_count)) %>%
  mutate(mean_count = 1 - total, phyla = "Other") %>%
  select(treatment, phyla, mean_count)

plot_taxa %>%
  bind_rows(other_values) %>%
  mutate(
    treatment = factor(treatment, levels = t_levels),
    phyla = factor(phyla, levels = c(top_taxa, "Other"))
  ) %>%
  ggplot(aes(x = treatment, y = mean_count, fill = phyla)) +
  geom_col(position = position_stack(reverse = T)) +
  scale_fill_brewer(palette = "Paired") +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_y_continuous(
    # don't expand y scale at the lower end
    expand = expansion(mult = c(0, 0)),
    labels = scales::percent_format(),
    limits = c(0,1)
  ) +
  labs(x = NULL, fill = NULL, y = "Phyla Abundance")
  
