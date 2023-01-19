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



co_compare_data <- tibble(treatments = t_levels) %>%
  filter(treatments != "Control") %>%
  rowwise() %>%
  mutate(
    data = list(
      filter(meta_data, depth == "0-10", treatment %in% c(treatments, "Control"))
    ),
    file_name = paste0(t_hash[treatments], "_co_data.tsv")
  )

walk2(
  co_compare_data$file_name, co_compare_data$data,
  ~write_tsv(.y, paste0("data/05_surface_compare/", .x))
)

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
  ~write_tsv(.y, paste0("data/06_subsurface_compare/", .x))
)

filter(meta_data, depth == "0-10") %>%
  write_tsv("data/05_surface_compare/continous_data.tsv")

filter(
  meta_data,
  depth == "0-10",
  treatment %in% c("Control", "Double Wood", "Double Litter")
) %>%
  write_tsv("data/05_surface_compare/continous_addition_data.tsv")

filter(
  meta_data,
  depth == "0-10",
  !(treatment %in% c("Control", "Double Wood", "Double Litter"))
) %>%
  write_tsv("data/05_surface_compare/continous_removal_data.tsv")

humann_metacyc = read_csv("data/master/humann_pathway_rel.csv") 

pathway_data = humann_metacyc %>%
  select(-description) %>%
  pivot_longer(-pathway, names_to = "sample_id", values_to = "value") %>%
  pivot_wider(names_from = pathway, values_from = value)

pathway_data %>% write_tsv("data/master/humann_pathway_rel.tsv")

compiled_data = left_join(meta_data, pathway_data)


compiled_data %>% ggplot(aes(x = treatment, y = `UNMAPPED`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  scale_y_continuous(labels = scales::percent_format())+
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Reads Mapped", x = NULL, color = NULL)


compiled_data %>% ggplot(aes(x = total_mb_std, y = `PWY490-3`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Assimilatory Nitrate Reduction", x = "Total Enzyme Activity", color = NULL)

compiled_data %>% ggplot(aes(x = total_mb_std, y = `P105-PWY`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "TCA cycle", x = "Total Enzyme Activity", color = NULL)

compiled_data %>% ggplot(aes(x = pep_mb_std, y = `PWY-5655`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Nitroaromatic Degradation ", x = "Peptadase Activity", color = NULL)

compiled_data %>% ggplot(aes(x = pep_mb_std, y = `GALLATE-DEGRADATION-II-PWY`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Gallate (lignin and tannins) Degradation", x = "Peptadase Activity", color = NULL)


carbon_data %>% ggplot(aes(x = treatment, y = `bulk_mgCg`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  # scale_y_continuous(labels = scales::percent_format())+
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Bulk C Concentration (mgC/g)", x = NULL, color = NULL)

carbon_data %>% ggplot(aes(x = treatment, y = `bulk_C_stock_kgC_m2`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  # scale_y_continuous(labels = scales::percent_format())+
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Bulk C Stock (kgC/m2)", x = NULL, color = NULL)

carbon_data %>% ggplot(aes(x = treatment, y = `LF_mgCg`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  # scale_y_continuous(labels = scales::percent_format())+
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Unprotected C Concentration (mgC/g)", x = NULL, color = NULL)

carbon_data %>% ggplot(aes(x = treatment, y = `HF_mgCg`, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  # scale_y_continuous(labels = scales::percent_format())+
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Adsorbed C Concentration (mgC/g)", x = NULL, color = NULL)
