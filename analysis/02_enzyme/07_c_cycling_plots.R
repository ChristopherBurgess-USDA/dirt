library(tidyverse)
library(cowplot)
source("bin/project_variables.R")

  
import_data = read_csv("data/master/enzyme_data_normalized.csv") %>%
  select(treatment, bulk_mgCg, c_mb_std) %>%
  mutate(c_mb_std = scales::rescale(c_mb_std)) %>%
  group_by(treatment) %>%
  summarise(across(where(is.double), list(mean = mean, sd = sd))) 

resp_data = read_csv("data/raw_data/respiration_yearly_loss.csv") %>%
  mutate(sd = se*sqrt(3)) %>%
  select(treatment, resp_mean = gC_total, resp_sd = sd)

meta_data = import_data %>%
  left_join(resp_data) %>%
  ungroup() %>%
  pivot_longer(-treatment, names_to = "measure", values_to = "value") %>%
  mutate(
    value_type = if_else(str_detect(measure, "_mean"), "mean", "sd"),
    measure = str_remove(measure, "_mean|_sd"),
    
  ) %>%
  pivot_wider(names_from = value_type, values_from = value) %>%
  mutate(
    upr = mean + sd, lwr = mean - sd,
    treatment = factor(gg_treat_hash[treatment], levels = gg_treatment)
  ) %>%
  nest_by(measure)


plot_gen = function(input_data){
  ggplot(data = input_data, aes(x = treatment, y = mean, color = treatment)) +
    geom_point(size = 6) +
    geom_errorbar(aes(ymax = upr, ymin = lwr), size = 1, width = .1) +
    theme_bw(16) +
    scale_color_manual(values = color_pal) +
    theme(
      legend.position="bottom",
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank()
    )
}



plots = meta_data %>%
  mutate(gg = list(plot_gen(data)))

legend = get_legend(plots$gg[[2]] + labs(color = NULL))

bulk_gg = plots$gg[[1]] + labs(x = NULL, y = expression("Carbon Concentration (mg g"^{-1}*")")) +
  theme(legend.position="none")


resp_gg = plots$gg[[3]] +
  labs(
    x = NULL, y = expression("Soil Respiration (g m"^{-2}~"year"^{-1}*")"), color = NULL) +
  theme(legend.position="none")

resp_gg

ggsave(
  paste0("plots/20221026_sssa_carbon_concentration.png"),
  bulk_gg,
  width = 6, height = 3.75, bg = "white"
)

ggsave(
  paste0("plots/20221026_sssa_yearly_resp.png"),
  resp_gg,
  width = 6, height = 3.75, bg = "white"
)
enzyme_gg = plots$gg[[2]] + labs(x = NULL, y = "Extracellular Enzyme Activity")+
  theme_bw(20) +
  theme(
    legend.position="none",
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

enzyme_gg

ggsave(
  paste0("plots/20221026_sssa_c_mb_std.png"),
  enzyme_gg,
  width = 9, height =5.6, bg = "white"
)


plot_grid(
  bulk_gg, resp_gg, enzyme_gg, legend, ncol = 1, align = "vh", rel_heights = c(1, 1, 1, .2)
)
  
