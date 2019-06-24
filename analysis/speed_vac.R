library(tidyverse)
library(readxl)

fData <- read_excel("DIRT/DNA_DIRT_Combined_mass.xlsx", sheet = "sorted")
cData <- read_excel("DIRT/DNA_DIRT_Combined_mass.xlsx", sheet = "Mass")

volMassData <- fData %>% group_by (Location, Sample) %>%
  mutate(aDNAMass = Conc *aVolume) %>%
  summarise(preVacPlotVol = sum(aVolume), massDNA = sum(aDNAMass)) %>%
  rename(Plot = Sample) %>%
  right_join(cData) %>%
  mutate(vMass = preVacMass - iMass, concPlot = massDNA/preVacPlotVol) %>%
  arrange(preVacPlotVol)
write.csv(volMassData, "DIRT/DIRT_DNA_SP_ROUT.csv")
