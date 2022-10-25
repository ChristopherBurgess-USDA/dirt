#%%
import numpy as np
import pandas as pd
import os, re, glob, json

if os.getcwd() != "/home/roots/burgesch/dirt":
    os.chdir("/home/roots/burgesch/dirt")


re_pattern = re.compile("\d+\.a\.|\.txt")
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
    file_ids = {re.sub(re_pattern, "", f): f for f in files_to_parse}
    sample_id = re.sub("raw/|/IMG_Dat\S+", "", folder_location)

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
        usecols=[0, 1, 2, 8, 9],
        names=["gene_id", "cog_id", "cog_percent_id", "cog_eVal", "cog_bitScore"],
    )
    ko_file = pd.read_table(
        folder_location + file_ids["ko"],
        header=None,
        index_col=0,
        usecols=[0, 2, 3, 8, 9],
        names=["gene_id", "kegg_id", "kegg_percent_id", "kegg_eVal", "kegg_bitScore"],
    )

    ec_file = pd.read_table(
        folder_location + file_ids["ec"],
        header=None,
        index_col=0,
        usecols=[0, 2, 3, 8, 9],
        names=["gene_id", "ec_id", "ec_percent_id", "ec_eVal", "ec_bitScore"],
    )

    pfam = pd.read_table(
        folder_location + file_ids["pfam"],
        header=None,
        index_col=0,
        usecols=[0, 1, 7, 8],
        names=["gene_id", "pfam_id", "pfam_eVal", "pfam_bitScore"],
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
        .assign(fasta=sample_id)
    )
    compiled_data.to_csv("annotations/" + sample_id + "_annotations.tsv", sep="\t")
    return compiled_data


sample_directories = glob.glob("raw/*/IMG_Data/*.tar.gz")

sample_directories = [i.replace(".tar.gz", "/") for i in sample_directories]

functional_data = [compile_files(i) for i in sample_directories]

functional_df = pd.concat(functional_data)

# %%
## DRAm annotation format

dram_df = functional_df.filter(
    [
        "seq_id",
        "fasta",
        "kegg_id",
        "kegg_eVal",
        "kegg_bitScore",
        "ec_id",
        "ec_eVal",
        "ec_bitScore",
        "cog_id",
        "cog_eVal",
        "cog_bitScore",
        "pfam_id",
        "pfam_eVal",
        "pfam_bitScore",
        "avg_fold",
    ]
)


# %%
functional_df.to_csv("annotations/compiled_annotations.tsv", sep="\t")

dram_df.to_csv("annotations/DRAM_annotations.tsv", sep="\t")