# %%
import os
import altair as alt
import numpy as np
import pandas as pd
import statsmodels.api as sm
from sklearn.linear_model import LinearRegression

data_path = "../../Thesis/dirt/"

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")


# %%

master_data = (
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
master_data = master_data[col_order]

master_data.to_csv("data/carbon_data.csv", index=False)

# %%
