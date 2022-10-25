library(tidyverse)


raw_data = read_tsv("data/raw_data/humann_ko_rel_unstratified.tsv")


parsed_data <- raw_data %>%
  pivot_longer(-"# Gene Family", names_to = "sample_id", values_to = "value") %>%
  mutate(sample_id = str_to_lower(str_remove(sample_id, "_Abundance-RPKs"))) %>%
  select(ko = "# Gene Family", sample_id, value) %>%
  pivot_wider(names_from = ko, values_from = value)


write_tsv(parsed_data, "data/master/humann_ko_rel.tsv")


raw_data = read_tsv("data/raw_data/humann_ko_rpk_unstratified.tsv")


parsed_data <- raw_data %>%
  pivot_longer(-"# Gene Family", names_to = "sample_id", values_to = "value") %>%
  mutate(sample_id = str_to_lower(str_remove(sample_id, "_Abundance-RPKs"))) %>%
  select(ko = "# Gene Family", sample_id, value) %>%
  pivot_wider(names_from = ko, values_from = value)


write_tsv(parsed_data, "data/master/humann_ko_rpk.tsv")
