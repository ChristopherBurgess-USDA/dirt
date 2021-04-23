#%%
import numpy as np
import pandas as pd
import os, re

data_path = "../../Thesis/dirt/enzyme/"

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")

# %%

co_08_files = [f for f in os.listdir("data/raw/CO-08-A")]
# %%
re_pattern = re.compile("\d+\.\w\.|\.txt")

# %%
file_ids = {re.sub(re_pattern, "", f): f for f in co_08_files}
# %%

depth_file = pd.read_table(
    "data/raw/CO-08-A/" + file_ids["depth"],
    header=0,
    index_col=0,
    names=["seq_id", "avg_fold"],
)
# %%
cog_file = pd.read_table(
    "data/raw/CO-08-A/" + file_ids["cog"],
    header=None,
    index_col=0,
    usecols=[0, 1, 2],
    names=["gene_id", "cog_term", "cog_percent_id"],
)
# %%
ko_file = pd.read_table(
    "data/raw/CO-08-A/" + file_ids["ko"],
    header=None,
    index_col=0,
    usecols=[0, 2, 3],
    names=["gene_id", "ko_term", "ko_percent_id"],
)

# %%
ec_file = pd.read_table(
    "data/raw/CO-08-A/" + file_ids["ec"],
    header=None,
    index_col=0,
    usecols=[0, 2, 3],
    names=["gene_id", "ec_term", "ec_percent_id"],
)
# %%
gff_file = (
    pd.read_table(
        "data/raw/CO-08-A/" + file_ids["gff"],
        header=None,
        usecols=[0, 8],
        names=["seq_id", "ids_to_parse"],
    )
    .astype(str)
    .assign(gene_id=lambda x: x["ids_to_parse"].str.replace(r".+;locus_tag=", ""))
    .assign(gene_id=lambda x: x["gene_id"].str.replace(";.*", ""))
    .filter(["seq_id", "gene_id"])
)
# %%
gene_product = pd.read_table(
    "data/raw/CO-08-A/" + file_ids["gene_product"],
    header=None,
    index_col=0,
    names=["gene_id", "function_name", "source"],
)


# %%
pfam = pd.read_table(
    "data/raw/CO-08-A/" + file_ids["pfam"],
    header=None,
    index_col=0,
    usecols=[0, 1, 7, 8],
    names=["gene_id", "pfam_id", "pfam_evalue", "pfam_bit_score"],
)

# %%
taxonomy = pd.read_table(
    "data/raw/CO-08-A/" + file_ids["phylodist"],
    header=None,
    sep="\t|;",
    engine="python",
    index_col=0,
    usecols=[0, 3, 4, 5, 6, 7, 8, 9, 10, 11],
    names=[
        "gene_id",
        "percent_id",
        "domain",
        "phylum",
        "class",
        "order",
        "family",
        "genus",
        "species",
        "taxon_name",
    ],
)

# %%

test = (
    gff_file
    .pipe(pd.merge, depth_file, on="seq_id", how="left")
    .set_index("gene_id")
    .pipe(pd.merge, gene_product, on="gene_id", how="left")
    .pipe(pd.merge, ko_file, on="gene_id", how="left")
    .pipe(pd.merge, cog_file, on="gene_id", how="left")
    .pipe(pd.merge, ec_file, on="gene_id", how="left")
    .pipe(pd.merge, pfam, on="gene_id", how="left")
    .pipe(pd.merge, taxonomy, on="gene_id", how="left")
)

# %%
