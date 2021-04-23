# %%
import os
import numpy as np
import pandas as pd

data_path = "../../Thesis/dirt/"

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")


# %%

carbon_data = (
    pd.read_csv(data_path + "DIRT20_soil_C_fracs_MASTER.csv")
    .query("Depth == '0-10'")
    .assign(
        Plot=lambda x: x["Plot"].astype(str).str.rjust(2, "0"),
        TRT=lambda x: x["TRT"].mask(x["TRT"] == "CTL", "CO"),
        treatment=lambda x: x["TRT"].str.lower(),
        sample_id=lambda x: x["treatment"] + "-" + x["Plot"].astype(str),
    )
    .rename(
        columns={
            "Plot": "plot",
            "bulk_percC": "c_percent",
            "bulk_percN": "n_percent",
            "LF_percC": "lf_percent",
            "IF_percC": "if_percent",
            "HF_percC": "hf_percent",
            "bulkden_g_cm3": "bulk_density",
        }
    )
)
col_order = [
    "sample_id",
    "treatment",
    "plot",
    "c_percent",
    "n_percent",
    "lf_percent",
    "if_percent",
    "hf_percent",
    "bulk_density",
]
carbon_data = carbon_data[col_order]

# %%

root_data = (
    pd.read_csv(data_path + "DIRT20_fine_roots_by_plot.csv")
    .assign(
        Plot=lambda x: x["Plot"].astype(str).str.rjust(2, "0"),
        treatment=lambda x: x["Trt"].str.lower(),
        sample_id=lambda x: x["treatment"] + "-" + x["Plot"].astype(str),
    )
    .drop(['Trt'], axis = 1)
    .rename(columns={"Plot": "plot", "root_mass_g-m2": "root_mass_g", "root_mass_sterr_g-m2": "root_mass_g_sd"})
)

master_data = pd.merge(carbon_data, root_data, on = ["sample_id", "treatment", "plot"])


# %%
master_data.to_csv("data/carbon_data.csv", index=False)
# %%
