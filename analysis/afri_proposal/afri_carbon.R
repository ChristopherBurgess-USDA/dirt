library(tidyverse)

data_path <- "data/"

carbon_data <- read_csv("data/DIRT20_derek.csv") %>%
  select(treatment, trt, depth, c_percent, n_percent, CtoN) %>%
  filter(trt != "NOA", depth %in% c("0-10", "40-60")) %>%
  mutate(depth = paste0(depth, " cm")) %>%
  group_by(treatment, trt, depth) %>%
  summarise_all(list(mean = ~mean, se = ~sd))
  

tc_plot <- ggplot(data = carbon_data, aes(x = trt, y = c_percent_mean)) +
  geom_bar(stat = "identity") +
  facet_wrap(~depth, ncol = 1) +
  geom_errorbar(
    aes(ymin = c_percent_mean - c_percent_se, ymax = c_percent_mean + c_percent_se),
    width = .2) +
  labs(x = "Treatment", y = "Total Carbon (%)") +
  theme_bw(25)

tc_plot
  ggsave(
    "analysis/afri_proposal/total_carbon_percent.tiff",
    plot = tc_plot,
    height = 15, width = 10
  )
  


