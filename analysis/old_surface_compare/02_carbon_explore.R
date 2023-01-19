library(tidyverse)


f_levels = c("Unprotected", "Aggregated", "Adsorbed", "Bulk")
frac_hash = hashmap(c("LF", "IF", "HF", "bulk"), f_levels)

t_levels = c("Double Wood", "Double Litter", "Control", "No Litter", "No Root", "No Input")

color_pal = setNames(
  c("#7570B3", "#E7298A", "#1B9E77", "#D95F02", "#A6761D", "#666666"),
  t_levels
)

t_hash <- setNames(c("dw", "dl", "co", "nl", "nr", "ni"), t_levels)

carbon_data = read_csv("data/master/dirt_master_meta_data.csv") %>%
  mutate(
    treatment = factor(treatment, levels = t_levels),
    porsity = 100-(bulkden_g_cm3/2.52*100)
  )
