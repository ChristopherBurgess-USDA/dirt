library(tidyverse)
library(hashmap)

source("bin/project_variables.R")
theme_set(theme_bw(12) + theme( panel.grid.major = element_blank(), panel.grid.minor = element_blank()))
save_path = "analysis/09_metagenome_lookup/plots/"


import_data <- read_csv("data/master/sig_metagenome_hits.csv") %>%
  mutate(feature = str_replace_all(feature, "\\.", "-"))


subtitle_hash <- setNames(import_data$Name, import_data$feature)
title_hash <- setNames(import_data$Superclass, import_data$feature)
t_hash_rev <- setNames(t_levels, t_hash)

sig_pathways <- import_data %>%
  select(type, metadata, comparison, feature)

xlab_hash <- setNames(
  c(
    "Carbon Enzyme Activity per Biomass",
    "Protease Activity (umol Tyrosine/g Biomass/h)",
    "Peroxidase Activity (nmol/g biomass/h)",
    "Phenoloxidase Activity (nmol/g biomass/h)"
  ),
  c("c_mb_std", "pep_mb", "perox_mb", "phenol_mb")
)

carbon_data = read_csv("data/master/dirt_master_meta_data.csv") %>%
  mutate(
    treatment = factor(treatment, levels = t_levels),
    porsity = 100-(bulkden_g_cm3/2.52*100),
    maom_mgCg = IF_mgCg + IF_mgCg
  ) %>%
  select(sample_id, treatment, plot, depth, bulk_mgCg, maom_mgCg)

enzyme_activity = read_csv("data/master/enzyme_data_normalized.csv") %>%
  select(sample_id, bg_mb, cbh_mb, perox_mb, phenol_mb, c_mb_std, pep_mb)

resp_data = read_csv("data/master/summer_daily_resp.csv")

meta_data <- left_join(carbon_data, enzyme_activity) %>%
  left_join(resp_data) %>%
  filter(depth == "0-10") %>%
  select(-depth) 

rm(carbon_data, enzyme_activity, resp_data)



ko_data <- read_tsv("data/master/humann_ko_rel.tsv") %>%
  select(-UNMAPPED, -UNGROUPED) %>%
  filter(str_detect(sample_id, "-a")) %>%
  mutate(across(where(is.numeric), ~.*100000)) %>%
  pivot_longer(-sample_id, names_to = "feature", values_to = "value") %>%
  pivot_wider(names_from = sample_id, values_from = value) %>%
  filter(feature %in% c("K02838", "K00151"))

metacyc_data <- read_tsv("data/master/humann_pathway_rel.tsv") %>%
  select(-UNMAPPED, -UNINTEGRATED) %>%
  filter(str_detect(sample_id, "-a")) %>%
  mutate(across(where(is.numeric), ~.*100000)) %>%
  pivot_longer(-sample_id, names_to = "feature", values_to = "value") %>%
  pivot_wider(names_from = sample_id, values_from = value) %>%
  bind_rows(ko_data)


make_plots <- function(compare_type, var, sig_feature){
  meta_data <- metacyc_data %>%
    filter(feature == sig_feature) %>%
    pivot_longer(contains("-a"), names_to = "sample_id", values_to = "value") %>%
    left_join(meta_data)
  
  if(compare_type == "metric") {
    if(var == "c_mb") {var <- "c_mb_std"}
    meta_data %>%
      select(value, sample_id, treatment, !!var) %>%
      mutate(treatment = factor(gg_treat_hash[treatment], gg_treatment)) %>%
      ggplot(aes(x = .data[[var]], color = treatment, y = value)) +
      geom_point(size = 3) +
      scale_color_manual(values = color_pal) +
      labs(
        y = sig_feature,
        subtitle = subtitle_hash[sig_feature],
        title = title_hash[sig_feature],
        x = xlab_hash[var],
        color = NULL
        ) %>%
      return()
  } else{
    keep_treatments <- c(t_hash_rev[str_sub(var, 1, 2)], "Control")
    meta_data %>%
      filter(treatment %in% keep_treatments) %>%
      mutate(treatment = factor(gg_treat_hash[treatment], gg_treatment)) %>%
      ggplot(aes(x = treatment, color = treatment, y = value)) +
      geom_point(size = 3) +
      scale_color_manual(values = color_pal) +
      labs(
        y = sig_feature,
        subtitle = subtitle_hash[sig_feature], title = title_hash[sig_feature],
        color = NULL
      ) %>%
      return()
      
  }
}

plot_df <- sig_pathways %>%
  rowwise() %>%
  mutate(gg = list(make_plots(metadata, comparison, feature)))
  
pwalk(
  list(plot_df$comparison, plot_df$feature, plot_df$gg),
  ~ggsave(
    paste0(..1, "_", ..2, ".png"),
    ..3,
    path = save_path,
    width = 6.33, height = 3.9, units = "in"
  )
)

  
