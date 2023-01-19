library(tidyverse)
library(RColorBrewer)
library(ggbreak)
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
  mutate(
    rel_val = value/total,
    phyla = if_else(phyla == "Deinococcus-Thermus", "Deinococcota", phyla)
  ) %>%
  group_by(treatment, phyla) %>%
  summarise(mean_count = mean(rel_val))
  
other_values = plot_taxa %>%
  ungroup() %>%
  group_by(treatment) %>%
  summarise(total = sum(mean_count)) %>%
  mutate(mean_count = 1 - total, phyla = "Other") %>%
  select(treatment, phyla, mean_count)

top_taxa[10] <- "Deinococcota"

taxa_gg <- plot_taxa %>%
  bind_rows(other_values) %>%
  mutate(
    treatment = factor(gg_treat_hash[treatment], levels = gg_treatment),
    phyla = factor(phyla, levels = c(top_taxa, "Other"))
  ) %>%
  ggplot(aes(x = treatment, y = mean_count, fill = phyla)) +
  geom_col(position = position_stack(reverse = T), width = .8) +
  scale_fill_brewer(palette = "Paired") +
  theme_bw(20) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_y_break(c(.05, .55), scale = 20, expand = F) +
  scale_y_continuous(
    # don't expand y scale at the lower end
    expand = expansion(mult = c(0, 0)),
    labels = c(0, 5, 60, 70, 80, 90, 100),
    limits = c(0,1),
    breaks = c(0, .05, .6, .7, .8, .9, 1),
    sec.axis = sec_axis(trans = ~., breaks = NULL)
  ) +
  labs(x = NULL, fill = NULL, y = "Phyla Abundance (%)")



taxa_gg

ggsave(
  paste0("plots/20221028_sssa_top_taxa.png"),
  taxa_gg,
  width = 9, height =5.6, bg = "white"
)

  
