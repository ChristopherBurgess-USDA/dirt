library(tidyverse)
library(Maaslin2)
source("bin/project_variables.R")

metacyc_data = "data/master/humann_pathway_rel.tsv"
ko_data = "data/master/humann_ko_rel.tsv"

meta_data = fs::dir_ls("data/06_subsurface_treatment_metagenome/", glob = "*_co_data.tsv")

maaslin_call = function(meta_path, metagenome_data, output_path){
  Maaslin2(
    input_data = metagenome_data,
    input_metadata = meta_path,
    fixed_effects = c("treatment"),
    output = output_path,
    min_prevalence = 0.3,
    min_abundance = 0,
    normalization = "NONE",
    reference = c("Control")
  )
  
}

output_data = str_replace(meta_data, "_data.tsv", "_metacyc")

pwalk(list(meta_data, metacyc_data, output_data), ~maaslin_call(..1, ..2, ..3))

output_data = str_replace(meta_data, "_data.tsv", "_ko")

pwalk(list(meta_data, ko_data, output_data), ~maaslin_call(..1, ..2, ..3))


