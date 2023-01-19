t_levels = c("Double Wood", "Double Litter", "Control", "No Litter", "No Root", "No Input")

color_pal = setNames(
  c("#56B4E9", "#009E73", "#666666","#CC79A7",  "#E69F00", "#D55E00"),
  t_levels
)

t_hash <- setNames(c("dw", "dl", "co", "nl", "nr", "ni"), t_levels)
f_levels = c("Unprotected", "Aggregated", "Adsorbed", "Bulk")
frac_hash = setNames(f_levels, c("LF", "IF", "HF", "bulk"))

gg_treatment = c("Double\nWood", "Double\nLitter", "Control", "No Litter", "No Root", "No Input")

gg_treat_hash = setNames(gg_treatment, t_levels)

color_pal = setNames(
  c("#56B4E9", "#009E73", "#666666","#CC79A7",  "#E69F00", "#D55E00"),
  gg_treatment
)