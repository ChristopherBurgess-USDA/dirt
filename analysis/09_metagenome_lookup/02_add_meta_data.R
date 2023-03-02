library(tidyverse)


import_data = tibble(
  file_name = fs::dir_ls("data/", recurse = T, glob = "*results.csv")
) %>%
  rowwise() %>%
  mutate(
    data = list(read_csv(file_name))
  ) %>%
  unnest(data) %>%
  mutate(feature = str_replace(feature, "\\.", "-")) %>%
  filter(metadata != "depth", !str_detect(file_name, "06")) %>%
  select(-data)


metagenome_meta_data <- read_csv("data/master/sig_metagenome_hits.csv")


left_join(import_data, metagenome_meta_data) %>%
  write_csv("data/master/sig_metagenome_hits.csv")

