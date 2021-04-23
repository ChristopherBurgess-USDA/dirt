library(tidyverse)
library(nlme)
library(emmeans)
library(magrittr)
library(betareg)
library(cowplot)
library(hashmap)
library(RColorBrewer)
library(scales)

### Added in Carbon and N percent, I honestly don't think there is any difference between treatments with the enzyme data... 
## Might need to think about this some more but the model suggest that the creation of maom is not due to a lack of enzyme potential.

carbon_data = read_csv("data/carbon_data.csv")

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



carbon_data %>%
  mutate(treatment = treatment_hash[[treatment]]) %>%
  ggplot(aes(x = treatment, y = hf_percent)) +
  geom_point(size = 3) +
  theme_cowplot(16) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  labs(x = "Treatment", y = "Heavy Fraction (MAOM)")

enzyme_activity = left_join(pep_data, oxidative) %>%
  left_join(hydro_data) %>%
  mutate_at(vars(contains("activity")), scale)

# pca_results = enzyme_activity %>%
#   select(-plot, -treatment) %>%
#   column_to_rownames(var = "sample_id") %>%
#   prcomp() %$%
#   x %>%
#   as.data.frame() %>%
#   rownames_to_column(var = "sample_id") %>%
#   separate(sample_id, into = c("treatment", "plot"), sep = "-", remove = F)



enzyme_activity = left_join(enzyme_activity, carbon_data) %>%
  mutate_at(vars(contains("_percent")), ~(./100)) %>%
  mutate(
    hydro = cbh_activity + bg_activity,
    oxidative = phenol_activity + perox_activity,
    c_activity = hydro + oxidative,
    cn_activity = c_activity/pep_activity,
    total_activity = c_activity + pep_activity,
    log_roots = log(root_mass_g)
  )

model_results = betareg(hf_percent ~ c_activity, data = enzyme_activity)

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


model_results = betareg(hf_percent ~ log_roots, data = enzyme_activity)

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

