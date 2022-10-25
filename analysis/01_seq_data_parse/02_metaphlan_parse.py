import pandas as pd, re

data_path = "data/humann/"

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")

## Reading in the raw data
raw_tax = pd.read_csv(
    data_path + "profiled_metagenome_merged.txt", sep="\t", header=1, skiprows=0
)
## Making a dict to rename the columns in the data
col_names = list(raw_tax.columns)[2:]
col_rename = {i: re.sub(r"(_profiled_metagenome)", "", i).lower() for i in col_names}
taxa_data = raw_tax.rename(columns=col_rename)

## pulling out the taxanomy from the clade_name and making sure the taxanomic names match those of kraken
taxa_data["clade_name"] = taxa_data["clade_name"].str.replace("\w__", "")
taxa_data[
    ["kingdom", "phyla", "Class", "order", "family", "genus", "species"]
] = taxa_data["clade_name"].str.split("|", expand=True)

## Saving the data
taxa_data.to_csv("data/humann_taxa.csv", index = False, header = True)