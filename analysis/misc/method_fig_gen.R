library(tidyverse)

source("bin/project_variables.R")


m_data <- tibble(
  treatment = factor(gg_treatment, levels = gg_treatment),
  # treatment = factor(t_levels, levels = t_levels),
  above_ground = c(270, 270, 135, 0, 135, 0),
  below_ground = c(-100, -100, -100, -100, 0, 0)
) %>%
  pivot_longer(-treatment, names_to = "loc", values_to = "value")


method_fig <- ggplot(data = m_data, aes(x = treatment, y = value, color = treatment, fill = treatment)) +
  # geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 0), fill = "chocolate4") +
  geom_col(width = .8) +
  geom_hline(yintercept = 0, size = 3) +
  scale_color_manual(values = color_pal) +
  scale_fill_manual(values = color_pal) +
  scale_y_continuous(
    limits = c(-100, 300),
    breaks = c(0, 100, 200, 300),
    labels = c(0, 100, 200, 300)
  ) +
  theme_bw(20) +
  # annotate("text", x = c(1, 2, 3, 4), y = -50, size = 8, label = "Roots") +
  annotate("text", x = c(5.5), y = -50, size = 8, label = "No\nRoots") +
  theme(
    legend.position="none",
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  ) +
  labs(x = NULL, y = expression("Plant Input Estimates (gC"~m^{-2}~"year"^{-1}*")"))

method_fig

ggsave(
  paste0("plots/20221026_sssa_method_fig.png"),
  method_fig,
  width = 9, height =5.6, bg = "white"
)
