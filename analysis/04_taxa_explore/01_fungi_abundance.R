library(tidyverse)
library(cowplot)
library(hashmap)

library(RColorBrewer)

f_levels <- c("Unprotected", "Aggregated", "Adsorbed", "Bulk")
frac_hash <- hashmap(c("LF", "IF", "HF", "bulk"), f_levels)

t_levels <- c("Double Wood", "Double Litter", "Control", "No Litter", "No Root", "No Input")

carbon_data <- read_csv("data/master/dirt_master_meta_data.csv") %>%
  filter(depth == "0-10") %>%
  mutate(treatment = factor(treatment, levels = t_levels))

taxa_data <- read_csv("data/master/kraken_taxa.csv") %>%
  pivot_longer(contains("-"), names_to="sample_id", values_to = "value")

fungal_data <- taxa_data %>%
  filter(kingdom %in% "Fungi", str_detect(sample_id, "a"))



make_plot <- function(input_data, p_title){
  ggplot(data = input_data, aes(x = treatment, y = mean_count, color = treatment)) +
    geom_point(size = 4) +
    geom_errorbar(aes(ymin = mean_count - sd_count, ymax = mean_count + sd_count), width = .4) +
    theme_cowplot(16) +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank()
    ) +
    panel_border() +
    background_grid() +
    scale_color_brewer(palette = "Dark2") +
    facet_wrap(~order, scales = "free_y") +
    labs(y = "Number of Fungi", color = "Treatment", title = p_title) %>%
    return()
}

fungi_orders <- fungal_data %>%
  filter(!is.na(order), is.na(family)) %>%
  select(-clade_name, -family, -genus, -species) %>%
  left_join(carbon_data) %>%
  mutate(treatment = factor(treatment, levels = t_levels)) %>%
  group_by(phyla, Class, order, treatment) %>%
  summarise(
    mean_count = mean(value),
    sd_count = sd(value)
  ) %>%
  ungroup() %>%
  nest_by(phyla) %>%
  mutate(
    plots = list(make_plot(data, phyla))
  )


