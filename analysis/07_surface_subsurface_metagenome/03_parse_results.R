library(tidyverse)

data_path = "data/07_surface_subsurface_metagenome/"

metacyc_results = tibble(
  data_path = fs::dir_ls(data_path, glob = "*_metacyc")
) %>%
  rowwise() %>%
  mutate(
    type = "metacyc",
    comparison = str_extract(data_path, pattern = "[:alpha:]{2}_depth"),
    data = list(read_tsv(paste0(data_path, "/significant_results.tsv")))
  ) %>%
  filter(nrow(data)>0) %>%
  unnest(data)

ko_results <- tibble(
  data_path = fs::dir_ls(data_path, glob = "*_ko")
) %>%
  rowwise() %>%
  mutate(
    type = "ko",
    comparison = str_extract(data_path, pattern = "[:alpha:]{2}_depth"),
    data = list(read_tsv(paste0(data_path, "/significant_results.tsv")))
  ) %>%
  filter(nrow(data)>0) %>%
  unnest(data)

bind_rows(metacyc_results, ko_results) %>%
  select(-data_path) %>%
  write_csv(paste0(data_path, "maaslin_results.csv"))



