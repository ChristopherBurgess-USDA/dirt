library(tidyverse)
library(cowplot)
library(hashmap)
library(gt)
library(RColorBrewer)


f_levels = c("Unprotected", "Aggregated", "Adsorbed", "Bulk")
frac_hash = hashmap(c("LF", "IF", "HF", "bulk"), f_levels)

t_levels = c("Double Wood", "Double Litter", "Control", "No Litter", "No Root", "No Input")

carbon_data = read_csv("data/master/dirt_master_meta_data.csv") %>%
  filter(depth == "0-10") %>%
  mutate(treatment = factor(treatment, levels = t_levels))



parse_data = function(in_data) {
  in_data %>%
    pivot_longer(-c("sample_id", "treatment"), names_to ="fraction", values_to = "value") %>%
    mutate(
      fraction = str_replace(fraction, "_.+", ""),
      fraction = frac_hash[[fraction]],
      fraction = factor(fraction, levels = f_levels)
    ) %>%
    group_by(treatment, fraction) %>%
    summarise(mean = mean(value), sd = sd(value)) %>%
    mutate(mean = round(mean, 1), sd = round(sd, 1)) %>%
    ungroup() %>%
    return()
}
make_plot = function(in_data, y_lab){
  ggplot(data = in_data, aes(x = treatment, y = mean, color = treatment)) +
    geom_point(size = 4) +
    geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), width = .2) +
    theme_cowplot(16) +
    panel_border() +
    background_grid() +
    scale_color_brewer(palette = "Dark2") +
    facet_wrap(~fraction, scales = "free_y", ncol = 1) +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank()
    ) +
    labs(y = y_lab, color = "Treatment") %>%
    return()
}

c_content = carbon_data %>%
  select(sample_id, treatment, contains("mgCg"), -tot_frac_mgCg) %>%
  parse_data()

c_content %>%
  unite(col = "measure", mean, sd, sep = "\u00B1") %>%
  pivot_wider(names_from = treatment, values_from = measure) %>%
  gt(rowname_col = "fraction") %>%
  tab_header(title = "Carbon Concentration (mgC/g Soil)")

gg_content = make_plot(c_content, "Carbon Concentration (mgC/g Soil)")

gg_content

stock_data =  carbon_data %>%
  select(sample_id, treatment, contains("kgC_m2")) %>%
  parse_data()

stock_data %>%
  unite(col = "measure", mean, sd, sep = "\u00B1") %>%
  pivot_wider(names_from = treatment, values_from = measure) %>%
  gt(rowname_col = "fraction") %>%
  tab_header(title = "Carbon stock (kgC/m2)")


gg_stock = make_plot(stock_data, "Carbon stock (kgC/m2)")

gg_stock

bulk_data = tibble(
  treatment = factor(t_levels, levels = t_levels),
  mean = c(.5, .66, .61, .75, .79, .79),
  sd = c(.08, .07, .08, .06, .09, .05)
) 

bulk_data %>%
  unite(col = "measure", mean, sd, sep = "\u00B1") %>%
  pivot_wider(names_from = treatment, values_from = measure) %>%
  gt() %>%
  tab_header(title = "Bulk Density g/cm3")

ggplot(data = bulk_data, aes(x = treatment, y = mean, color = treatment)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), width = .2) +
  theme_cowplot(16) +
  panel_border() +
  background_grid() +
  scale_color_brewer(palette = "Dark2") +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  ) +
  labs(y = "Bulk Density g/cm3", color = "Treatment")

carbon_data %>%
  select(sample_id, treatment, contains("mgCg"), contains("kgC_m2"), -tot_frac_mgCg) %>%
  pivot_longer(-c("sample_id", "treatment"), names_to ="measure", values_to = "value") %>%
  separate(measure, into = c("fraction", "measure"), sep = "_", extra = "merge") %>%
  mutate(
    fraction = frac_hash[[fraction]],
    fraction = factor(fraction, levels = f_levels)
  ) %>%
  pivot_wider(names_from = "measure", values_from = "value") %>%
  ggplot(aes(x = mgCg, y = C_stock_kgC_m2, color = treatment)) +
  geom_point(size = 3) +
  facet_wrap(~fraction, scale = "free") +
  theme_cowplot(16) +
  panel_border() +
  labs(x = "Carbon Concentration (mgC/gram soil)", y = "Carbon Stock (kgC/m2)", color = "Treatment")
