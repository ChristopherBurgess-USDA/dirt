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

depth_compare_data <- tibble(treatments = t_levels) %>%
  rowwise() %>%
  mutate(
    data = list(
      filter(meta_data, treatment %in% c(treatments))
    ),
    file_name = paste0(t_hash[treatments], "_depth_data.tsv")
  ) 

walk2(
  depth_compare_data$file_name, depth_compare_data$data,
  ~write_tsv(.y, paste0("data/07_surface_subsurface_metagenome/", .x))
)