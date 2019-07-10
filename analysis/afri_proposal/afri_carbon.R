library(tidyverse)
library(hashmap)


trt_type <- hashmap(
  c("CTL", "DW", "DL", "NI", "NR", "NL"),
  c("Control", "Addition", "Addition", rep("Reduction", 3)))

depth_hash <- hashmap(c("0-10", "40-60"), c("Surface (0-10 cm)", "Subsurface (40-60 cm)"))
data_path <- "data/"

carbon_data <- read_csv("data/DIRT20_derek.csv") %>%
  select(treatment, trt, depth, c_percent, n_percent, CtoN) %>%
  filter(trt != "NOA", depth %in% c("0-10", "40-60")) %>%
  mutate(depth = depth_hash[[depth]], depth = fct_relevel(depth, c("Surface (0-10 cm)", "Subsurface (40-60 cm)"))) %>%
  mutate(treatment = str_replace(treatment, " ", "\n")) %>%
  group_by(treatment, trt, depth) %>%
  summarise_all(list(mean = ~mean, se = ~sd)) %>%
  mutate(t_type = trt_type[[trt]])

  

tc_plot <- ggplot(data = carbon_data, aes(x = treatment, y = c_percent_mean, fill = t_type)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("#7CAE00", "#00BFC4", "#F8766D"), guide = F) +
  facet_wrap(~depth, ncol = 1) +
  geom_errorbar(
    aes(ymin = c_percent_mean - c_percent_se, ymax = c_percent_mean + c_percent_se),
    width = .2) +
  labs(x = "Treatment", y = "Total Carbon (%)") +
  theme_bw(30)

tc_plot
  ggsave(
    "analysis/afri_proposal/total_carbon_percent.tiff",
    plot = tc_plot,
    height = 11, width = 8.5
  )
  


