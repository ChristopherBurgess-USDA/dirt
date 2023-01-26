library(tidyverse)


import_data = tibble(
  file_name = fs::dir_ls("data/", recurse = T, glob = "*results.csv")
  ) %>%
  rowwise() %>%
  mutate(
    data = list(read_csv(file_name))
  ) %>%
  unnest(data) %>%
  filter(metadata != "depth")



import_data %>% select(type, feature) %>%
  distinct() %>%
  write_csv("data/raw_data/sig_metagenome_hits.csv")



