#%%
import numpy as np
import pandas as pd
import os, re

data_path = "../../Thesis/dirt/enzyme/"

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")

# %%

## Parsing Functions


def compile_files(folder_location):
    """
    This function parses and compiles all relavent functional annotation information from the JGI annotation pipeline

    Args:
        folder_location (string): The location for the folder where all the functional annotation information is

    Returns:
        [pd.Dataframe]: Dataframe with all annotation information for a given sample.
    """
    files_to_parse = [f for f in os.listdir(folder_location)]
    file_ids = {re.sub(re_pattern, "", f): f for f in co_08_files}

    ## The gff file is used to link the sequence id with the gene. This is because the abundance of each gene is done at the sequence level and there are multiple genes per sequence.
    gff_file = (
        pd.read_table(
            folder_location + file_ids["gff"],
            header=None,
            usecols=[0, 8],
            names=["seq_id", "ids_to_parse"],
        )
        .astype(str)
        .assign(gene_id=lambda x: x["ids_to_parse"].str.replace(r".+;locus_tag=", ""))
        .assign(gene_id=lambda x: x["gene_id"].str.replace(";.*", ""))
        .filter(["seq_id", "gene_id"])
    )
    ## Here are the functional annotations which each of the difference databases
    cog_file = pd.read_table(
        folder_location + file_ids["cog"],
        header=None,
        index_col=0,
        usecols=[0, 1, 2],
        names=["gene_id", "cog_term", "cog_percent_id"],
    )
    ko_file = pd.read_table(
        folder_location + file_ids["ko"],
        header=None,
        index_col=0,
        usecols=[0, 2, 3],
        names=["gene_id", "ko_term", "ko_percent_id"],
    )

    ec_file = pd.read_table(
        folder_location + file_ids["ec"],
        header=None,
        index_col=0,
        usecols=[0, 2, 3],
        names=["gene_id", "ec_term", "ec_percent_id"],
    )

    pfam = pd.read_table(
        folder_location + file_ids["pfam"],
        header=None,
        index_col=0,
        usecols=[0, 1, 7, 8],
        names=["gene_id", "pfam_id", "pfam_evalue", "pfam_bit_score"],
    )

    ## Gene product is JGI's way or picking the best annotation.
    gene_product = pd.read_table(
        folder_location + file_ids["gene_product"],
        header=None,
        index_col=0,
        names=["gene_id", "function_name", "source"],
    )

    ## Each gene is given a taxonomic represeation here.
    taxonomy = pd.read_table(
        folder_location + file_ids["phylodist"],
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

    ## This is the file for read depth or each gene, at the sequence level.
    depth_file = pd.read_table(
        folder_location + file_ids["depth"],
        header=0,
        index_col=0,
        names=["seq_id", "avg_fold"],
    )

    ## Here is where I combine all the dataframes into a single dataframe.
    compiled_data = (
        gff_file.pipe(pd.merge, depth_file, on="seq_id", how="left")
        .set_index("gene_id")
        .pipe(pd.merge, gene_product, on="gene_id", how="left")
        .pipe(pd.merge, ko_file, on="gene_id", how="left")
        .pipe(pd.merge, cog_file, on="gene_id", how="left")
        .pipe(pd.merge, ec_file, on="gene_id", how="left")
        .pipe(pd.merge, pfam, on="gene_id", how="left")
        .pipe(pd.merge, taxonomy, on="gene_id", how="left")
    )

    return compiled_data


# %%

co_08_files = [f for f in os.listdir("data/raw/CO-08-A")]
# %%
re_pattern = re.compile("\d+\.\w\.|\.txt")


# %%

# %%


# %%


# %%
