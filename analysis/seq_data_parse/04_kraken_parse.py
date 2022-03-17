import pandas as pd, re

data_path = "data/kraken/"

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")

## Reading in the raw data
raw_tax = pd.read_csv(data_path + "meta_combine.txt", sep="\t", header=0)
## Making a dict to rename the columns in the data
col_names = list(raw_tax.columns)[1:]
col_rename = {i: re.sub(r"(_kracken_taxa.txt)", "", i).lower() for i in col_names}
col_rename["#Classification"] = "clade_name"
taxa_data = raw_tax.rename(columns=col_rename)

## pulling out the taxanomy from the clade_name and making sure the taxanomic names match those of metaphlan. Also I needed to remove extra taxanomic information form the fungal clade_names.
taxa_data["clade_name"] = taxa_data["clade_name"].str.replace("\w__|Eukaryota\|", "")
taxa_data[
    ["kingdom", "phyla", "Class", "order", "family", "genus", "species"]
] = taxa_data["clade_name"].str.split("|", expand=True)

## Saving the data
taxa_data.to_csv("data/kraken_taxa.csv", index=False, header=True)
