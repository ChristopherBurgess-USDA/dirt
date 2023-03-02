library(tidyverse)
library(lubridate)

source("bin/project_variables.R")

carbon_data = read_csv("data/master/dirt_master_meta_data.csv") %>%
  # select(sample_id, treatment, plfa_ug_per_gsoil) %>%
  mutate(
    treatment = factor(treatment, levels = t_levels),
    maom = HF_mgCg + IF_mgCg,
    plot = as.numeric(plot)
  ) %>%
  filter(depth == "0-10") %>%
  select(sample_id, treatment, plot)
  


raw_resp <- read_csv("data/raw_data/raw_respiration_plot.csv") %>%
  mutate(date = mdy(date)) %>%
  select(date, plot, gCmean) %>%
  left_join(carbon_data)

resp_data = raw_resp %>% 
  mutate(month = month(date)) %>%
  filter(month>= 6, month <= 8) %>%
  group_by(treatment, sample_id) %>%
  summarise(daily_resp = mean(gCmean))

write_csv(resp_data, "data/master/summer_daily_resp.csv")


