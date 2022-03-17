import pandas as pd, sqlite3

if os.getcwd() != "/home/tunasteak/box/projects/dirt":
    os.chdir("/home/tunasteak/box/projects/dirt")

# Creating database
conn = sqlite3.connect("data/dirt.db")
c = conn.cursor()

## Importing all the different data
htaxa_data = pd.read_csv("data/humann_taxa.csv", header=0)
ktaxa_data = pd.read_csv("data/kraken_taxa.csv", header=0)
path_data = pd.read_csv("data/humann_pathway_rel.csv", header=0)
coverage_data = (
    pd.read_csv("data/humann_pathway_coverage.csv", header=0)
    .drop(["description"], axis=1)
    .melt(id_vars="pathway", var_name="sample_id", value_name="coverage")
)
meta_data = pd.read_csv("data/sample_id_key.csv", header=0)

## Creating the taxa_info table by merging the taxanomy from both kraken and metaphlan
taxa_col_names = [
    "clade_name",
    "kingdom",
    "phyla",
    "Class",
    "order",
    "family",
    "genus",
    "species",
]
taxa_names = (
    pd.concat([htaxa_data.filter(taxa_col_names), ktaxa_data.filter(taxa_col_names)])
    .sort_values("clade_name")
    .drop_duplicates()
    .reset_index(drop=True)
    .rename("taxa_{}".format)
)
taxa_names.reset_index(inplace=True)
taxa_names = taxa_names.rename(columns={"index": "taxa_id"})
taxa_recode = taxa_names.filter(["taxa_id", "clade_name"])

## Adding the taxa_id column to the metaphlan data and formatting it for the database.
taxa_col_names = [
    "NCBI_tax_id",
    "kingdom",
    "phyla",
    "Class",
    "order",
    "family",
    "genus",
    "species",
]
htaxa_data = (
    htaxa_data.drop(taxa_col_names, axis=1)
    .pipe(pd.merge, taxa_recode, on="clade_name")
    .drop(["clade_name"], axis=1)
    .melt(id_vars="taxa_id", var_name="sample_id", value_name="count")
)

## Adding the taxa_id column to the kraken data and formatting it for the database.
taxa_col_names = ["kingdom", "phyla", "Class", "order", "family", "genus", "species"]
ktaxa_data = (
    ktaxa_data.drop(taxa_col_names, axis=1)
    .pipe(pd.merge, taxa_recode, on="clade_name")
    .drop(["clade_name"], axis=1)
    .melt(id_vars="taxa_id", var_name="sample_id", value_name="count")
)


## Creating a table for pathways ids and their discriptions
path_ids = path_data.filter(["pathway", "description"])

## Formatting the pathway data for the database and adding the coverage information.
path_data = (
    path_data.drop(["description"], axis=1)
    .melt(id_vars="pathway", var_name="sample_id", value_name="abundance")
    .pipe(pd.merge, coverage_data, on=["pathway", "sample_id"], how="left")
)


## Creating each table make sure they have the right foreign keys
c.execute(
    """
create table if not exists sample_id
(sample_id text primary key not null,
treatment text,
plot integer,
depth text)
"""
)
c.execute(
    """
create table if not exists taxa_info
(taxa_id text primary key not null,
clade_name text,
kingdom text,
phyla text,
class text,
taxa_order text,
family text,
genus text,
species text)
"""
)
c.execute(
    """
create table if not exists path_info
(pathway text primary key not null,
description text)
"""
)
c.execute(
    """
create table if not exists metaphlan
(taxa_id text,
sample_id text,
abundance real,
foreign key(taxa_id) references taxa_info(taxa_id),
foreign key(sample_id) references sample_info(sample_id))
"""
)
c.execute(
    """
create table if not exists kraken
(taxa_id text,
sample_id text,
abundance real,
foreign key(taxa_id) references taxa_info(taxa_id),
foreign key(sample_id) references sample_info(sample_id))
"""
)
c.execute(
    """
create table if not exists humann
(pathway text,
sample_id text,
abundance real,
coverage real,
foreign key(pathway) references path_info(pathway),
foreign key(sample_id) references sample_info(sample_id))
"""
)
conn.commit()

## Adding the data do their respective tables by using pandas.to_sql function.
ktaxa_data.to_sql("kraken", conn, index=False, if_exists="append")
htaxa_data.to_sql("metaphlan", conn, index=False, if_exists="append")
taxa_names.to_sql("taxa_info", conn, index=False, if_exists="append")
meta_data.to_sql("sample_info", conn, index=False, if_exists="append")
path_data.to_sql("humann", conn, index=False, if_exists="append")
path_ids.to_sql("pathway_info", conn, index=False, if_exists="append")
