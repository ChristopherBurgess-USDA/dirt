import pandas as pd, re, os

data_path = "data/humann/"

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")

## Reading in the raw data
raw_path = pd.read_csv(
    data_path + "humann_pathabundance_rel_unstratified.tsv", sep="\t"
)

## Making a dict to rename the columns in the data
col_names = list(raw_path.columns)[1:]
col_rename = {i: re.sub(r"(_Abundance)", "", i).lower() for i in col_names}
col_rename["# Pathway"] = "pathway"

path_data = raw_path.rename(columns=col_rename)

## pulling out the pathway description out of the pathway column for astestics
path_data[["pathway", "description"]] = path_data["pathway"].str.split(
    ": ", expand=True
)

## Saving the data
path_data.to_csv("data/humann_pathway_rel.csv", index=False, header=True)

## Reading in the raw coverage data for the pathways and doing the same steps do the data as see in the path_data
raw_coverage = pd.read_csv(data_path + "humann_pathcoverage_unstratified.tsv", sep="\t")
col_names = list(raw_coverage.columns)[1:]
col_rename = {i: re.sub(r"(_.*)", "", i).lower() for i in col_names}
col_rename["# Pathway"] = "pathway"

coverage_data = raw_coverage.rename(columns=col_rename)
coverage_data[["pathway", "description"]] = coverage_data["pathway"].str.split(
    ": ", expand=True
)
coverage_data.to_csv("data/humann_pathway_coverage.csv", index=False, header=True)
