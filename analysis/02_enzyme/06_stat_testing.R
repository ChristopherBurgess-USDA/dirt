library(tidyverse)
library(emmeans)
library(performance)

source("bin/project_variables.R")

measures_keep <- c(
  "bg", "bg_mb",
  "cbh", "cbh_mb",
  "perox", "perox_mb",
  "phenol", "phenol_mb",
  "pep", "pep_mb",
  "c_mb_std", "c_std"
)


t_levels <- c("Double Wood", "Double Litter", "No Litter", "No Root", "No Input", "Control")

import_data <-  read_csv("data/master/enzyme_data_normalized.csv") %>%
  select(
    sample_id, treatment, pep, phenol, perox, cbh, bg, contains("mb"), contains("std")
  ) %>%
  mutate(treatment = factor(treatment, levels = t_levels))


enzyme_data <- import_data %>%
  pivot_longer(
    -c("sample_id", "treatment"), names_to = "measure", values_to = "value"
  ) %>%
  nest_by(measure) %>%
  filter(measure %in% measures_keep) %>%
  mutate(
    mods = list(lm(value ~ treatment, data = data)),
    gg = list(check_model(mods, panel = T)), 
    var_check = list(check_homogeneity(mods, mothhod = "levene"))
  )

enzyme_pairs <- enzyme_data %>%
  mutate(
    pairs = list(emmeans(mods, specs = trt.vs.ctrlk ~ treatment)),
    contrast = list(pairs$contrast %>% broom::tidy())
  ) %>%
  select(measure, contrast) %>%
  unnest(contrast) %>%
  arrange(measure, desc(adj.p.value)) %>%
  mutate(
    sig = if_else(adj.p.value <= .1, "*", ""),
    sig = if_else(adj.p.value <= .05, "**", sig),
    sig = if_else(adj.p.value <= .01, "***", sig)
    )
  
write_csv(enzyme_pairs, "data/enzyme/stat_results.csv")
