library(tidyverse)
source("bin/project_variables.R")


carbon_data = read_csv("data/master/dirt_master_meta_data.csv") %>%
  mutate(
    treatment = factor(treatment, levels = t_levels),
    porsity = 100-(bulkden_g_cm3/2.52*100)
  ) %>%
  select(sample_id, treatment, plot, depth, contains("_mgCg"), -tot_frac_mgCg, porsity)

enzyme_activity = read_csv("data/master/enzyme_data_normalized.csv") %>%
  select(sample_id, contains(c("c_mb", "total_mb", "pep_mb")))

meta_data <- left_join(carbon_data, enzyme_activity)



co_compare_data <- tibble(treatments = t_levels) %>%
  filter(treatments != "Control") %>%
  rowwise() %>%
  mutate(
    data = list(
      filter(meta_data, depth == "0-10", treatment %in% c(treatments, "Control"))
    ),
    file_name = paste0(t_hash[treatments], "_co_data.tsv")
  )


walk2(
  co_compare_data$file_name, co_compare_data$data,
  ~write_tsv(.y, paste0("data/05_surface_treatment_metagenome/", .x))
)