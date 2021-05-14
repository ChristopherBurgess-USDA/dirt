# %%
import altair as alt
import numpy as np
import pandas as pd
import os

data_path = "data/mapping_data/"

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")


# %%

mapping_results = (
    pd.read_csv(data_path + "mapped_values_compare.csv")
    .assign(
        sample_id=lambda x: x["sample_id"].str.lower(),
        spades1kbp_reads=lambda x: x[
            ["spades_1kpb_read1_map", "spades_1kpb_read2_map"]
        ].mean(axis=1),
        spades1kbp_percent=lambda x: x[
            ["spades_1kpb_percent_read1_map", "spades_1kpb_precent_read2_map"]
        ].mean(axis=1),
        mega_reads=lambda x: x[["mega_read1_map", "mega_read2_map"]].mean(axis=1),
        mega_percent=lambda x: x[
            ["mega_percent_read1_map", "mega_precent_read2_map"]
        ].mean(axis=1),
    )
    .drop(
        [
            "spades_1kpb_read1_map",
            "spades_1kpb_read2_map",
            "spades_1kpb_percent_read1_map",
            "spades_1kpb_precent_read2_map",
            "mega_read1_map",
            "mega_read2_map",
            "mega_percent_read1_map",
            "mega_precent_read2_map",
        ],
        axis=1,
    )
    .rename(
        columns={
            "spades_percent_reads_map": "spades_percent",
            "spades_reads_map": "spades_reads",
        }
    )
)


# mapping_results.dtypes
# sample_id                             object
# spades_total_reads                   float64
# spades_reads                         float64
# spades_percent                       float64
# spades_reads_removed_1kbp            float64
# spades_reads_removed_percent_1kbp    float64
# spades_reads_kept_1kbp               float64
# spades_reads_kept_percent_1kbp       float64
# spades_1kpb_total_reads              float64
# mega_total_reads                     float64
# spades1kbp_reads                     float64
# spades1kbp_percent                   float64
# mega_reads                           float64
# mega_percent                         float64

# %%

## Reads removed anlysis to get to 1kbp

reads_removed = (
    mapping_results.filter(
        ["sample_id", "spades_reads_removed_1kbp", "spades_reads_kept_1kbp"]
    )
    .rename(
        columns={
            "spades_reads_removed_1kbp": "reads_removed",
            "spades_reads_kept_1kbp": "reads_left",
        }
    )
    .melt(id_vars="sample_id", value_vars=["reads_removed", "reads_left"])
)

alt.Chart(reads_removed).mark_bar().encode(
    x=alt.X("sample_id", axis=alt.Axis(title="Samples")),
    y=alt.Y("value", axis=alt.Axis(title="Number of Reads")),
    color=alt.Color("variable", legend=alt.Legend(title=None)),
)

# %%
mapping_compare = mapping_results.filter(
    [
        "sample_id",
        "spades1kbp_reads",
        "spades1kbp_percent",
        "mega_reads",
        "mega_percent",
        "spades_reads",
        "spades_percent",
    ]
).melt(
    id_vars="sample_id",
    value_vars=[
        "spades1kbp_reads",
        "spades1kbp_percent",
        "mega_reads",
        "mega_percent",
        "spades_reads",
        "spades_percent",
    ],
)

mapping_compare[["analysis", "measure"]] = mapping_compare.variable.str.split(
    "_", expand=True
)

mapping_compare = (mapping_compare.drop(["variable"], axis=1)).pivot_table(
    index=["sample_id", "analysis"], columns="measure", values="value"
)
mapping_compare.reset_index(inplace=True)
mapping_compare['percent'] = mapping_compare['percent']/100

## Have to flatten index for pandas
alt.Chart(mapping_compare).mark_bar().encode(
    x=alt.X("analysis", axis=alt.Axis(title=None, labels=False)),
    y=alt.Y("reads", axis=alt.Axis(title="Number of Reads")),
    color=alt.Color("analysis", legend=alt.Legend(title=None), scale=alt.Scale(scheme='dark2')),
    column="sample_id"
)

# %%
## Have to flatten index for pandas
alt.Chart(mapping_compare).mark_bar().encode(
    x=alt.X("analysis", axis=alt.Axis(title=None, labels=False)),
    y=alt.Y("percent", axis=alt.Axis(format='%', title="Number of Reads")),
    color=alt.Color("analysis", legend=alt.Legend(title=None), scale=alt.Scale(scheme='dark2')),
    column="sample_id"
)

# %%
