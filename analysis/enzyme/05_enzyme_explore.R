library(tidyverse)
library(nlme)
library(emmeans)

### Added in Carbon and N percent, I honestly don't think there is any difference between treatments with the enzyme data... 
## Might need to think about this some more but the model suggest that the creation of maom is not due to a lack of enzyme potential.

carbon_data = read_csv("data/carbon_data.csv")

data_import_parse = function(file_name){
  read_csv(paste0("data/enzyme/", file_name)) %>%
    separate(sample_id, into = c("treatment", "plot"), sep = "-", remove = F) %>%
    left_join(carbon_data) %>%
    return()
}



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


oxidative = import_data$data[[3]]

ox_model = lm(phenol_activity~treatment + c_percent, data = oxidative)

emmeans(ox_model)

pep_data = import_data$data[[4]] %>%
  select(treatment, plot, rep, contains("activity_"), contains("_percent")) %>%
  mutate(
    activity_24h = (activity_24h - activity_0h)/ 24,
    activity_48h = (activity_48h - activity_0h)/ 48,
    log_48h = log(activity_48h)
    # baseline = activity_0h
  ) %>%
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

