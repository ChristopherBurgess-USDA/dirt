# %% setup

"""This script parses the raw bg and cbh data into activity"""

import pandas as pd
import os
import re
import altair as alt

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")

data_path = "data/humann/"

# %% pathway data import and parse

pathway_data = (
    pd.read_table(data_path + "humann_pathabundance_rel_unstratified.tsv")
    .rename(columns={"# Pathway": "pathway"})
    .rename(columns=lambda x: re.sub("_.+$", "", x))
    .melt(id_vars=["pathway"])
    .assign(sample_id=lambda x: x["variable"].str.lower())
    .drop(columns=["variable"])
    .pivot(index="sample_id", columns="pathway", values="value")
    .reset_index()
)
pathway_data[["treatment", "site", "depth"]] = pathway_data.sample_id.str.split(
    "-", expand=True
)

# %% gene family data import and parse
genefam_data = (
    pd.read_table(data_path + "humann_genefamilies_rel_unstratified.tsv")
    .rename(columns={"# Gene Family": "genes"})
    .drop(columns=["NI-69-A_genefamilies_rel"])
    .rename(columns=lambda x: re.sub("_.+$", "", x))
    .melt(id_vars=["genes"])
    .assign(sample_id=lambda x: x["variable"].str.lower())
    .drop(columns=["variable"])
    .pivot(index="sample_id", columns="genes", values="value")
    .reset_index()
)

genefam_data[["treatment", "site", "depth"]] = genefam_data.sample_id.str.split(
    "-", expand=True
)


# %%

alt.Chart(pathway_data).mark_bar().encode(
    alt.Y("UNMAPPED:Q", title="unmapped reads (%)", axis=alt.Axis(format="%")),
    color=alt.Color("treatment", legend=None),
    x="sample_id",
)
# %%
