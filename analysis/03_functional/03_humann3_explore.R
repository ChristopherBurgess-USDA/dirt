library(tidyverse)
library(cowplot)
library(scales)
library(RColorBrewer)



data_path = "data/humann/"

pathway_data = read_tsv(paste0(data_path, "humann_pathabundance_rel_unstratified.tsv")) %>%
  rename("pathway" = `# Pathway`) %>%
  rename_with(~str_replace(., "_.+", "")) %>%
  pivot_longer(-pathway, names_to = "sample_id", values_to = "value") %>%
  mutate(sample_id = str_to_lower(sample_id)) %>%
  pivot_wider(names_from = sample_id, values_from = value) %>%
  separate(pathway, into = c("pathway", "description"), sep = ": ")
  separate(sample_id, into = c("treatment", "site", "depth"), sep = "-", remove = F)
  
write_csv(pathway_data, "data/master/humann_pathway_rel.csv")




genefam_data = read_tsv(paste0(data_path, "humann_genefamilies_rel_unstratified.tsv")) %>%
  rename("gene_family" = `# Gene Family`) %>%
  select(-"NI-69-A_genefamilies_rel") %>%
  rename_with(~str_replace(., "_A.+", ""))


genefam_data = genefam_data %>%
  pivot_longer(-gene_family, names_to = "sample_id", values_to = "value") %>%
  pivot_wider(names_from = "gene_family", values_from = "value") %>%
  mutate(sample_id = str_to_lower(sample_id)) %>%
  separate(sample_id, into = c("treatment", "site", "depth"), sep = "-", remove = F)


genes_mapped_data = genefam_data %>%
  select(sample_id, depth, treatment, UNMAPPED) %>%
  filter(depth == "a")

genes_mapped_data %>%
  select(sample_id, unmapped = UNMAPPED) %>%
  mutate(
    mapped = 1 - unmapped,
    sample_id = str_sub(sample_id, 1, -3)
  ) %>%
  pivot_longer(-sample_id, names_to = "mapping", values_to = "value") %>%
  ggplot(aes(x = sample_id, y = value, fill = mapping)) +
  geom_col() +
  scale_y_continuous(labels = label_number(scale = 100, suffix = "%")) +
  scale_fill_brewer(palette = "Dark2") +
  theme_cowplot(16) +
  labs(x = "Sample ID", y = "Reads Mapped", fill = "Mapping")

