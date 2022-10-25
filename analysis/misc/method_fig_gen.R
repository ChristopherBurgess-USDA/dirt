library(tidyverse)

source("bin/project_variables.R")


m_data <- tibble(
  treatment = factor(t_levels, levels = t_levels),
  above_ground = c(270, 270, 135, 0, 135, 0),
  below_ground = c(-100, -100, -100, -100, 0, 0)
) %>%
  pivot_longer(-treatment, names_to = "loc", values_to = "value")


ggplot(data = m_data, aes(x = treatment, y = value, color = treatment, fill = treatment)) +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 0), fill = "chocolate4") +
  geom_col() +
  geom_hline(yintercept = 0, size = 3) +
  scale_color_manual(values = color_pal) +
  scale_fill_manual(values = color_pal) +
  scale_y_continuous(
    limits = c(-150, 300),
    breaks = c(-100, 0, 100, 200, 300),
    labels = c(100, 0, 100, 200, 300)
  ) +
  theme_bw(16) +
  theme(
    legend.position="none",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  labs(x = NULL, y = expression("Carbon Input  Extimates (gC"~m^{-2}~"year"^{-1}*")"))
ann
