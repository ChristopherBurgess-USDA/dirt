library(tidyverse)
library(readxl)

import_data = read_csv("data/raw_data/DIRT20_derek.csv") %>%
  filter(depth %in% c("0-10", "40-60"), trt != "NOA") %>%
  mutate(
    trt = if_else(trt =="CTL", "co", str_to_lower(trt)),
    temp = if_else(depth == "0-10", "a", "b"),
    plot = str_pad(plot, pad = "0", side = "left", width = 2),
    sample_id = paste(trt, plot, temp, sep = "-")
  ) %>%
  select(sample_id, treatment, plot, depth, c_percent, n_percent, cn_ratio = CtoN)


raw_plfa = read_excel("data/raw_data/Total PLFAs for Chris.xlsx") %>%
  filter(!str_detect(Treatment, "OA")) %>%
  group_by(Treatment, `Plot #`) %>%
  summarise(
    plfa_ug_per_gsoil = mean(`Total PLFA (ug/g soil)`)
  ) %>%
  ungroup() %>%
  mutate(
    Treatment = str_sub(Treatment, 3),
    Treatment = if_else(Treatment == "C", "CO", Treatment),
    Treatment = str_to_lower(Treatment),
    sample_id = str_c(Treatment, str_pad(`Plot #`, 2, pad = "0", side = "left"), "a", sep = "-")
  ) %>%
  select(sample_id, plfa_ug_per_gsoil)

raw_carbon = read_excel("data/raw_data/DIRT20_soil_C_fracs_MASTER.xlsx") %>%
  filter(Depth == "0-10") %>%
  mutate(
    TRT = if_else(TRT =="CTL", "co", str_to_lower(TRT)),
    Plot = str_pad(Plot, pad = "0", side = "left", width = 2),
    sample_id = paste(TRT, Plot, "a", sep = "-")
  ) %>%
  select(-Treatment, -Plot, -Depth,-TRT, -DNPF) 
raw_root  = read_csv("data/raw_data/DIRT20_fine_roots_by_plot.csv") %>%
  mutate(
    Trt = if_else(Trt =="CTL", "co", str_to_lower(Trt)),
    Plot = str_pad(Plot, pad = "0", side = "left", width = 2),
    sample_id = paste(Trt, Plot, "a", sep = "-")
  ) %>%
  select(sample_id, root_mass = `root_mass_g-m2`, root_mass_sd = `root_mass_sterr_g-m2`)




parsed_data = left_join(import_data, raw_carbon) %>%
  left_join(raw_root) %>%
  left_join(raw_plfa)



write_csv(parsed_data, "data/dirt_master_meta_data.csv")

