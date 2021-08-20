# %% setup
import altair as alt
import numpy as np
import pandas as pd
import os

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")


# %% Data import
def read_enzyme(file_name):
    df = pd.read_csv("data/enzyme/" + file_name).assign(
        treatment=lambda x: x["sample_id"].str[0:2],
        plot=lambda x: x["sample_id"].str[-2:],
    )
    col_names = df.columns.tolist()
    col_names = col_names[-2:] + col_names[:-2]
    df = df[col_names]
    return df


data_files = {
    "bg_cbh": "bg_cbh_activity.csv",
    "bg_cbh_t2": "bg_cbh_activity_take2.csv",
    "oxidative": "oxidative_activity.csv",
    "pep": "peptidase_activity.csv",
}

enzyme_data = {i: read_enzyme(j) for (i, j) in data_files.items()}

carbon_data = pd.read_csv("data/carbon_data.csv").assign(
    maom_percent=lambda x: x["hf_percent"] + x["if_percent"]
)

# %% oxidative data explore

data = enzyme_data.get("oxidative")

alt.Chart(data).mark_point().encode(
    x="treatment", y="phenol_activity", tooltip=["sample_id"]
).interactive()

# %% hydrolytic enzyme explore

temp = enzyme_data.get("bg_cbh_t2").assign(take="take 2")

temp_2 = enzyme_data.get("bg_cbh").assign(take="take 1")

c_hydro = pd.concat([temp_2, temp])


alt.Chart(c_hydro).mark_point().encode(
    x="treatment", y="bg_activity", color="take", tooltip=["sample_id"]
).interactive()

alt.Chart(c_hydro).mark_point().encode(
    x="treatment", y="cbh_activity", color="take", tooltip=["sample_id"]
).interactive()

# %%
## Based on the above graphs, we need to remove sample dw-16 from take 2 and dl-02 from take 1 since they clearly are non-biological outliers.

temp = temp.query("sample_id != 'dw-16'")

temp_2 = temp_2.query("sample_id != 'dl-02'")

c_hydro = (
    pd.concat([temp_2, temp])
    .convert_dtypes()
    .drop(columns=["take"])
    .groupby(["treatment", "plot", "sample_id"])
    .agg(np.mean)
    .reset_index()
)

# %% peptidase data explore
c_keep = [
    "treatment",
    "plot",
    "sample_id",
    "activity_0h",
    "activity_24h",
    "activity_48h",
]
n_enzyme = (
    enzyme_data.get("pep")
    .filter(c_keep)
    .groupby(by=["treatment", "plot", "sample_id"])
    .agg(np.mean)
    .reset_index()
    .assign(
        activity_48h=lambda x: x["activity_48h"] - x["activity_24h"],
        activity_24h=lambda x: x["activity_24h"] - x["activity_0h"],
    )
    .drop(columns=["activity_0h"])
    .pipe(
        pd.melt,
        id_vars=["treatment", "plot", "sample_id"],
        value_vars=["activity_24h", "activity_48h"],
    )
)

alt.Chart(n_enzyme).mark_point().encode(
    x="treatment", y="value:Q", column="variable:N", tooltip=["sample_id"]
).interactive()

## Based on the above data I want to use the 24-48h data.
pep_data = n_enzyme.query("variable == 'activity_48h'").eval("pep_activity = value/24")
# %% Function to standerize each column

## scaling numbers are slightly different from R not sure why... apply to all columns.
## Figured it out... it is because sklearn and np use the bias estimator


def standerize(df_column):
    return (df_column - df_column.mean()) / df_column.std()


# %% Merging and standerizing enzyme activity
enzyme_data_export = (
    pep_data.drop(columns=["variable", "value"])
    .pipe(
        pd.merge,
        right=enzyme_data.get("oxidative"),
        on=["treatment", "plot", "sample_id"],
    )
    .pipe(pd.merge, right=c_hydro, on=["treatment", "plot", "sample_id"])
)

temp = (
    enzyme_data_export.set_index(["treatment", "plot", "sample_id"])
    .apply(standerize, axis=0)
    .reset_index()
)

temp.columns = temp.columns.str.replace(r"activity", "std")

enzyme_data_export = pd.merge(
    enzyme_data_export, temp, on=["treatment", "plot", "sample_id"]
)

# %% Saving Data
enzyme_data_export.to_csv("data/enzyme/enzyme_data_processed.csv", index=False)
# %%
