library(tidyverse)
source("bin/project_variables.R")


carbon_data = read_csv("data/master/dirt_master_meta_data.csv") %>%
  mutate(
    treatment = factor(treatment, levels = t_levels),
    porsity = 100-(bulkden_g_cm3/2.52*100),
    maom_mgCg = IF_mgCg + IF_mgCg
  ) %>%
  select(sample_id, treatment, plot, depth, bulk_mgCg, maom_mgCg)

enzyme_activity = read_csv("data/master/enzyme_data_normalized.csv") %>%
  select(sample_id, c_mb_std, pep_mb_std)

resp_data = read_csv("data/raw_data/respiration_yearly_loss.csv") %>%
  mutate(sd = se*sqrt(3)) %>%
  select(treatment, resp_mean = gC_total)

meta_data <- left_join(carbon_data, enzyme_activity) %>%
  left_join(resp_data) %>%
  filter(depth == "0-10") %>%
  select(-depth) %>%
  pivot_longer(
    -c("sample_id", 'treatment', "plot"), names_to = "var", values_to = "metric"
  ) %>%
  nest_by(var) %>%
  mutate(file_name = paste0(var, "_data.tsv"))


walk2(
  meta_data$file_name, meta_data$data,
  ~write_tsv(.y, paste0("data/08_continuous_metagenome/", .x))
)
