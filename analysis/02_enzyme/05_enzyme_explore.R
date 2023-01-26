library(tidyverse)
library(nlme)
library(emmeans)
library(magrittr)
library(betareg)
library(cowplot)
library(hashmap)
library(RColorBrewer)
library(scales)
library(rlang)
library(gt)

source("bin/project_variables.R")

### Added in Carbon and N percent, I honestly don't think there is any difference between treatments with the enzyme data... 
## Might need to think about this some more but the model suggest that the creation of maom is not due to a lack of enzyme potential.


enzyme_ids = c(
  "Glucosidase", "Cellulase",
  "Phenol oxidase", "Peroxidase-raw", "Peroxidase",
  "Protease",
  "Hydrolytic", "Oxidative",
  "Carbon Degradation", "C:N Degradation", "Total Enzyme Activity"
)
enzyme_hash = hashmap(
  c(
    "bg_std", "cbh_std",
    "phenol_std", "raw_perox_std", "perox_std",
    "pep_std",
    "hydro_std", "oxi_std",
    "c_std", "cn_std", "total_std"
  ),
  enzyme_ids
)

## ************************************************************************* ##
##                   Data Import                                             ##
## ************************************************************************* ##


carbon_data = read_csv("data/master/dirt_master_meta_data.csv") %>%
  # select(sample_id, treatment, plfa_ug_per_gsoil) %>%
  mutate(treatment = factor(treatment, levels = t_levels), maom = HF_mgCg + IF_mgCg)

raw_enzyme = read_csv("data/enzyme/enzyme_data_processed.csv") %>%
  select(sample_id, contains("activity"), -raw_perox_activity) %>%
  mutate(sample_id = paste0(sample_id, "-a")) %>%
  left_join(carbon_data)


enzyme_activity = raw_enzyme %>%
  mutate(
    across(contains("activity"), ~(.x/plfa_ug_per_gsoil), .names = "{.col}_mb"),
    across(contains("mb"), ~scale(.x), .names = "{.col}_std"),
    across(contains("_std"), as.double)
  ) %>%
  rename_with(~str_replace(.x, "_activity", ""), contains("activity")) %>%
  mutate(
    hydro_mb_std = cbh_mb_std + bg_mb_std,
    oxi_mb_std = phenol_mb_std + perox_mb_std,
    c_mb_std = hydro_mb_std + oxi_mb_std,
    cn_mb_std = c_mb_std/pep_mb_std,
    total_mb_std = c_mb_std + pep_mb_std
  )



enzyme_activity = raw_enzyme %>%
  mutate(
    across(contains("activity"), ~(.x/plfa_ug_per_gsoil), .names = "{.col}_mb"),
    across(contains("activity"), ~scale(.x), .names = "{.col}_std"),
    across(contains("_std"), as.double)
  ) %>%
  rename_with(~str_replace(.x, "_activity", ""), contains("activity")) %>%
  mutate(
    hydro_mb_std = cbh_mb_std + bg_mb_std,
    oxi_mb_std = phenol_mb_std + perox_mb_std,
    c_mb_std = hydro_mb_std + oxi_mb_std,
    total_mb_std = c_mb_std + pep_mb_std,
    hydro_std = cbh_std + bg_std,
    oxi_std = phenol_std + perox_std,
    c_std = hydro_std + oxi_std,
    total_std = c_std + pep_std
  )

write_csv(enzyme_activity, "data/master/enzyme_data_normalized.csv")

enzyme_activity_meta = enzyme_activity %>%
  left_join(carbon_data) %>%
  mutate_at(vars(contains("_percent")), ~(./100)) %>%
  mutate(
    log_roots = log(root_mass_g)
  )


## ************************************************************************* ##
##                   Enzyme activity Treatment                               ##
## ************************************************************************* ##

enzyme_activity %>%
  ggplot(aes(x = treatment, y = c_std, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Carbon Enzyme Activity (g soil)", x = NULL, color = NULL)

enzyme_activity %>%
  ggplot(aes(x = treatment, y = pep_std, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Protease Activity (g soil)", x = NULL, color = NULL)
enzyme_activity %>%
  ggplot(aes(x = treatment, y = c_mb_std, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Carbon Enzyme Activity (Biomass Normalization)", x = NULL, color = NULL)

enzyme_activity %>%
  ggplot(aes(x = treatment, y = pep_mb_std, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Protease Activity (Biomass Normalization)", x = NULL, color = NULL)


enzyme_activity %>%
  # filter(!(treatment %in% c("Double Wood", "Double Litter"))) %>%
  ggplot(aes(x = maom, y = c_mb_std, color = treatment)) +
  geom_point(size = 5) +
  theme_bw(16) +
  theme(
    legend.position="bottom",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  scale_color_manual(values = color_pal) +
  labs(y = "Carbon Enzyme Activity (Biomass Normalization)", x = "Mineral Associated C (mgC/gsoil)", color = NULL)


enzyme_activity %>%
  select(treatment, sample_id, ends_with("_std") & !contains("_mb")) %>%
  pivot_longer(
    -c("treatment", "sample_id"), names_to = "measure", values_to = "value"
  ) %>%
  mutate(
    measure = enzyme_hash[[measure]],
    measure = factor(measure, levels = enzyme_ids),
    treatment = factor(gg_treat_hash[treatment], levels = gg_treatment)
  ) %>%
  group_by(treatment, measure) %>%
  summarise(value_mean = mean(value), value_sd = sd(value)) %>%
  ggplot(aes(x = treatment, y = value_mean, color = treatment)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = value_mean - value_sd, ymax = value_mean + value_sd), width = .4) +
  scale_color_manual(values = color_pal) +
  theme_cowplot(16) +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  ) +
  panel_border() +
  background_grid() +
  facet_wrap(~measure, scales = "free_y") +
  labs(y = "Enzyme activity", color = "Treatment")

enzyme_activity %>%
  select(treatment, sample_id, contains("mb_std")) %>%
  rename_with(~str_replace(.x, "_mb", ""), contains("mb")) %>%
  pivot_longer(
    -c("treatment", "sample_id"), names_to = "measure", values_to = "value"
  ) %>%
  mutate(
    measure = enzyme_hash[[measure]],
    measure = factor(measure, levels = enzyme_ids),
    treatment = factor(gg_treat_hash[treatment], levels = gg_treatment)
  ) %>%
  group_by(treatment, measure) %>%
  summarise(value_mean = mean(value), value_sd = sd(value)) %>%
  ggplot(aes(x = treatment, y = value_mean, color = treatment)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = value_mean - value_sd, ymax = value_mean + value_sd), width = .4) +
  scale_color_manual(values = color_pal) +
  theme_cowplot(16) +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  ) +
  panel_border() +
  background_grid() +
  facet_wrap(~measure, scales = "free_y") +
  labs(y = "MB normalized enzyme activity", color = "Treatment")

enzyme_activity %>%
  select(treatment, sample_id, contains("soc_std")) %>%
  rename_with(~str_replace(.x, "_soc", ""), contains("soc")) %>%
  pivot_longer(
    -c("treatment", "sample_id"), names_to = "measure", values_to = "value"
  ) %>%
  mutate(
    measure = enzyme_hash[[measure]],
    measure = factor(measure, levels = enzyme_ids),
    treatment = factor(treatment, levels = t_levels)
  ) %>%
  group_by(treatment, measure) %>%
  summarise(value_mean = mean(value), value_sd = sd(value)) %>%
  ggplot(aes(x = treatment, y = value_mean, color = treatment)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = value_mean - value_sd, ymax = value_mean + value_sd), width = .4) +
  theme_cowplot(16) +
  scale_color_brewer(palette = "Dark2") +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  ) +
  panel_border() +
  background_grid() +
  facet_wrap(~measure, scales = "free_y") +
  labs(y = "SOC normalized enzyme activity", color = "Treatment",)


## ************************************************************************* ##
##                   H-Testing by treatment                                  ##
## ************************************************************************* ##

em_contrast_parse = function(em_results){
  em_results$contrasts %>%
    as.data.frame() %>%
    filter(str_detect(contrast, "co")) %>%
    return()
}

tab_gen = function(t_data){
  gt(t_data, rowname_col = "contrast") %>%
    tab_spanner_delim(delim = ";") %>%
    return()
}


enzyme_h_test = enzyme_activity %>%
  pivot_longer(
    -c("treatment", "plot", "sample_id"),
    names_to = "measure",
    values_to = "value"
  ) %>%
  nest_by(measure) %>%
  mutate(
    treat_model = list(lm(value~treatment, data = data)),
    em_results = list(emmeans(treat_model, specs = pairwise ~ treatment, adjust = "none")),
    em_contrast = list(em_contrast_parse(em_results))
  ) %>%
  unnest(em_contrast) %>%
  select(measure, contrast, estimate, p_value = p.value) %>%
  pivot_longer(c("estimate", "p_value"), names_to = "measure_2", values_to = "value")


enzyme_table = enzyme_h_test %>%
  mutate(
    measure_type = if_else(
      measure %in% c(
      "bg_std", "cbh_std",
      "phenol_std", "raw_perox_std", "perox_std",
      "pep_std"
    ),
    "non_agg",
    "agg"
    ),
  measure = enzyme_hash[[measure]],
  value = round(value, 2)
  ) %>%
  unite(c_name, measure, measure_2, sep = ";") %>%
  nest_by(measure_type) %>%
  mutate(
    data = list(pivot_wider(data, names_from = c_name, values_from = value)),
    tabs = list(tab_gen(data))
  )




## ************************************************************************* ##
##                   Old                                                     ##
## ************************************************************************* ##

enzyme_activity_raw = enzyme_activity_raw %>%
  pivot_longer(-one_of("treatment", "plot", "sample_id"), names_to = "measure", values_to = "value")

temp = lm(cbh_activity ~ treatment, data = enzyme_activity)

emmeans(temp, specs = pairwise ~ treatment, adjust = "none")



### H-testing 

model_call = function(y_var){
  y_var = ensym(y_var)
  mod_expr = expr(!! y_var ~ treatment)
  model = lm(mod_expr, data = enzyme_activity)
  model$call$formula = mod_expr
  return(model)
}

contrast_parse = function(marginals){
  marginals$contrasts %>%
    tidy() %>%
    separate(contrast, into = c("x1", "x2"), sep = " - ", remove = F) %>%
    filter(x1 == "co") %>%
    select(-x1, -x2) %>%
    return()
}

enzyme_h_test = enzyme_activity %>%
  select(contains("_activity")) %>%
  names() %>%
  tibble(test_var = .) %>%
  mutate(
    model = map(test_var, model_call),
    marginals = map(model, ~emmeans(.x, specs = pairwise ~ treatment, adjust = "none")),
    contrast = map(marginals, contrast_parse)
  )

test_results = enzyme_h_test %>%
  select(-model, -marginals) %>%
  unnest(contrast) %>%
  filter(p.value <= 0.1)

enzyme_h_test %>% filter(test_var = )

model_results = betareg(maom_percent ~ perox_activity, data = enzyme_activity)

summary(model_results)

enzyme_activity %>%
  mutate(treatment = treatment_hash[[treatment]]) %>%
  ggplot(aes(x = c_activity, y = hf_percent)) +
  geom_point(size = 3, aes(color = treatment)) +
  geom_line(aes(y = predict(model_results, enzyme_activity))) +
  scale_color_brewer(palette = "Dark2") +
  theme_cowplot(16) +
  scale_y_continuous(labels = label_number(scale = 100, suffix = "%")) +
  labs(x = "Carbon Enzyme Activity", y = "Heavy Fraction (MAOM)", color = "Treatment")


model_results = betareg(maom_percent ~ log_roots, data = enzyme_activity)

summary(model_results)

enzyme_activity %>%
  mutate(treatment = treatment_hash[[treatment]]) %>%
  ggplot(aes(x = log_roots, y = hf_percent)) +
  geom_point(size = 3, aes(color = treatment)) +
  geom_line(aes(y = predict(model_results, enzyme_activity))) +
  scale_color_brewer(palette = "Dark2") +
  theme_cowplot(16) +
  scale_y_continuous(labels = label_number(scale = 100, suffix = "%")) +
  labs(x = "Log Root Mass(g/m2)", y = "Heavy Fraction (MAOM)", color = "Treatment")


treatment_model = lm(c_activity ~ treatment, data = enzyme_activity)

summary(treatment_model)

ox_model = lm(phenol_activity~treatment + c_percent, data = oxidative)

emmeans(ox_model)

pep_data = import_data$data[[4]] %>%
  select(treatment, plot, rep, contains("activity_"), contains("_percent")) %>%
  mutate(
    activity_24_to_48h = (activity_48h - activity_24h)/ 24,
    activity_0_to_24h = (activity_24h - activity_0h)/ 24,
    activity_0_to_48h = (activity_48h - activity_0h)/ 48
  ) %>%
  select(-activity_0h, -activity_24h, -activity_48h) %>%
  pivot_longer(contains("activity_"), names_to = "time", values_to = "activity")

pep_data %>%
  mutate(treatment = treatment_hash[[treatment]]) %>%
  ggplot(aes(x = treatment, y = activity, color = time)) +
  geom_boxplot() +
  theme_cowplot(16) +
  panel_border() +
  scale_color_brewer(palette = "Dark2") +
  labs(x = "Treatment", y = "Activity", color = "Interval")


pep_explore = pep_data %>%
  select(treatment, plot, rep, activity_24h, activity_48h, activity_48h_2) %>%
  pivot_longer(contains("activity"), names_to = "time", values_to = "activity") %>%
  
  pep_data = pep_data %>%
  select(-activity_0h) %>%
  pivot_longer(contains("activity_"), names_to = "time", values_to = "activity") %>%
  mutate(
    plot = factor(plot),
    activity = if_else(activity <= 0, 0.0001, activity),
    log_activity = log(activity)
  )
## Heterostacisity so I had to log the response
pep_model = lme(log_48h ~ treatment + c_percent, random = ~1|plot, data = pep_data)
ggeffects::ggemmeans(pep_model, terms= c("time", "treatment")) %>%
  plot(connect.lines = T)


## ************************************************************************* ##
##                   to delete                                               ##
## ************************************************************************* ##

data_import_parse = function(file_name){
  read_csv(paste0("data/enzyme/", file_name)) %>%
    separate(sample_id, into = c("treatment", "plot"), sep = "-", remove = F) %>%
    return()
}

treatment_hash = hashmap(
  c("co", "dl", "dw", "ni", "nl", "nr"),
  c("Control", "Double\nLitter", "Double\nWood", "No\nInput", "No\nLitter", "No\nRoots")
)

import_data = tibble(
  data_set = c("bg_cbh", "bg_cbh_t2", "oxidative", "pep"),
  file_name = c(
    "bg_cbh_activity.csv",
    "bg_cbh_activity_take2.csv",
    "oxidative_activity.csv",
    "peptidase_activity.csv"
  )
) %>%
  mutate(
    data = map(file_name, data_import_parse)
  )



temp = import_data$data[[2]] %>%
  mutate(take = "take_2")

hydro_data = import_data$data[[1]] %>%
  mutate(take = "take_1") %>%
  bind_rows(temp)

hydro_data %>%
  mutate(treatment = treatment_hash[[treatment]]) %>%
  pivot_longer(c("cbh_activity", "bg_activity"), names_to = "activity", values_to = "values") %>%
  ggplot(aes(x = treatment, y = values, color = take)) +
  geom_point(size = 3) +
  facet_wrap(~activity, ncol = 1, scales = "free_y") +
  scale_color_brewer(palette = "Dark2") +
  theme_cowplot(16) +
  panel_border() +
  labs(x = "Treatment", y = "Activity", color = "Replicate")


temp = import_data$data[[2]] %>%
  filter(sample_id != "dw-16")
hydro_data = import_data$data[[1]] %>%
  filter(sample_id != "dl-02") %>%
  bind_rows(temp) %>%
  group_by(treatment, plot, sample_id) %>%
  summarise(cbh_activity = mean(cbh_activity), bg_activity = mean(bg_activity)) %>%
  ungroup()

hydro_data %>%
  mutate(treatment = treatment_hash[[treatment]]) %>%
  pivot_longer(c("cbh_activity", "bg_activity"), names_to = "activity", values_to = "values") %>%
  ggplot(aes(x = treatment, y = values)) +
  geom_point(size = 3) +
  facet_wrap(~activity, ncol = 1, scales = "free_y") +
  theme_cowplot(16) +
  panel_border() +
  labs(x = "Treatment", y = "Activity")

oxidative = import_data$data[[3]]

oxidative %>%
  mutate(treatment = treatment_hash[[treatment]]) %>%
  pivot_longer(c("phenol_activity", "perox_activity"), names_to = "activity", values_to = "values") %>%
  ggplot(aes(x = treatment, y = values)) +
  geom_point(size = 3) +
  facet_wrap(~activity, ncol = 1, scales = "free_y") +
  theme_cowplot(16) +
  panel_border() +
  labs(x = "Treatment", y = "Activity")

pep_data = import_data$data[[4]] %>%
  mutate(pep_activity= (activity_48h - activity_24h)/ 24) %>%
  group_by(treatment, plot, sample_id) %>%
  summarise(pep_activity = mean(pep_activity)) %>%
  ungroup()

import_data$data[[4]] %>%
  select(treatment, plot, sample_id, activity_24h, activity_48h) %>%
  group_by(treatment, plot, sample_id) %>%
  summarise(across(c(activity_24h, activity_48h), mean)) %>%
  mutate(pep_activity= (activity_48h - activity_24h)/ 24)

carbon_data %>%
  mutate(treatment = treatment_hash[[treatment]]) %>%
  ggplot(aes(x = treatment, y = maom_percent)) +
  geom_point(size = 3) +
  theme_cowplot(16) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  labs(x = "Treatment", y = "Heavy Fraction (MAOM)")

enzyme_activity_raw = left_join(pep_data, oxidative) %>%
  left_join(hydro_data) %>%
  mutate(across(c(contains("activity")), scale))

# pca_results = enzyme_activity_raw %>%
#   select(-plot, -treatment) %>%
#   column_to_rownames(var = "sample_id") %>%
#   prcomp() %$%
#   x %>%
#   as.data.frame() %>%
#   rownames_to_column(var = "sample_id") %>%
#   separate(sample_id, into = c("treatment", "plot"), sep = "-", remove = F)



enzyme_activity = left_join(enzyme_activity_raw, carbon_data) %>%
  mutate_at(vars(contains("_percent")), ~(./100)) %>%
  mutate(
    hydro_activity = cbh_activity + bg_activity,
    oxi_activity = phenol_activity + perox_activity,
    c_activity = hydro_activity + oxi_activity,
    cn_activity = c_activity/pep_activity,
    total_activity = c_activity + pep_activity,
    log_roots = log(root_mass_g)
  )


