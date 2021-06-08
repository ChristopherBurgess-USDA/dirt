library(tidyverse)
library(cowplot)
library(RColorBrewer)
library(scales)

mapped_data = read_csv("data/mapping_data/mapped_megahit_values_compare.csv") %>%
  select(sample_id, mega_reads, mega_percent, mega2500_reads = mega_2500_reads, mega2500_percent = mega_2500_percent) %>%
  pivot_longer(-c("sample_id"), names_to = "measure", values_to = "value") %>%
  separate(measure, into = c("type", "measure"), sep = "_") %>%
  pivot_wider(names_from = measure, values_from = value) %>%
  mutate(
    sample_id = str_to_lower(str_sub(sample_id, 1, -3))
  )

ggplot(data = mapped_data, aes(x = sample_id, y = percent, fill = type)) +
  geom_col(position = "dodge") +
  scale_fill_brewer(palette = "Dark2") +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  theme_cowplot(12) +
  labs(x = NULL, y = "Percent Reads Mapped", fill = NULL)
