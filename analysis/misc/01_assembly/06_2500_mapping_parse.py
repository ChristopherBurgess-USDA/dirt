import os, re
import pandas as pd

if os.getcwd() != "/home/roots/burgesch/Myrold_Lab/Chris/dirt":
    os.chdir("/home/roots/burgesch/Myrold_Lab/Chris/dirt")

samples = [
    "CO-08-A",
    "CO-12-A",
    "CO-14-A",
    "DL-13-A",
    "DL-17-A",
    "DW-05-A",
    "DW-10-A",
    "DW-16-A",
    "NI-19-A",
    "NI-49-A",
    "NI-69-A",
    "NL-03-A",
    # "NL-07-A",
    "NL-11-A",
    "NR-01-A",
    "NR-04-A",
    # "NR-06-A",
]


def parse_megahit(file_name):
    """
    This function reads in assembly mapping results from my megahit  pipeline. Specifically, it pulls out "reads used" and "reads map" information.

    Args:
        file_name (string): Name of the sample

    Returns:
        dict: A dict of mapped values, keys are column names, values are float
    """
    megahit_map = []
    file_path = "mapped/" + file_name + "_megahit_output.txt"
    with open(file_path, "rt") as open_file:
        file_lines = open_file.readlines()
        pattern = re.compile("Reads Used:")
        for line in file_lines:
            line = line.strip()
            if pattern.search(line) != None:
                temp = [i.strip() for i in line.split("\t")][1]
                megahit_map.append(float(temp))

        pattern = re.compile("mapped:")
        for line in file_lines:
            line = line.strip()
            if pattern.search(line) != None:
                temp = [i.strip() for i in line.split("\t")][1:3]
                temp[0] = temp[0][:-1]
                megahit_map.extend([float(i) for i in temp])
    keys = [
        "mega_total_reads",
        "mega_percent_read1_map",
        "mega_read1_map",
        "mega_percent_read2_map",
        "mega_read2_map",
    ]
    return dict(zip(keys, megahit_map))


def parse_megahit_2500(file_name):
    """
    This function reads in assembly mapping results pruned megahit contigs of >2.5kbp. Specifically, it pulls out "reads used" and "reads map" information.

    Args:
        file_name (string): Name of the sample

    Returns:
        dict: A dict of mapped values, keys are column names, values are float
    """
    megahit_map = []
    file_path = "mapped/" + file_name + "_megahit_2500_output.txt"
    with open(file_path, "rt") as open_file:
        file_lines = open_file.readlines()
        pattern = re.compile("Reads Used:")
        for line in file_lines:
            line = line.strip()
            if pattern.search(line) != None:
                temp = [i.strip() for i in line.split("\t")][1]
                megahit_map.append(float(temp))

        pattern = re.compile("mapped:")
        for line in file_lines:
            line = line.strip()
            if pattern.search(line) != None:
                temp = [i.strip() for i in line.split("\t")][1:3]
                temp[0] = temp[0][:-1]
                megahit_map.extend([float(i) for i in temp])
    keys = [
        "mega_2500_total_reads",
        "mega_2500_percent_read1_map",
        "mega_2500_read1_map",
        "mega_2500_percent_read2_map",
        "mega_2500_read2_map",
    ]
    return dict(zip(keys, megahit_map))


def mapped_compare(sample_id):
    """
    This function reads in both JGI and megahit pipline and complies them together into one object.

    Args:
        sample_id (string): sample name used to find identify which files to read in

    Returns:
        dict: A dictionary with both spades and megahit mapping information.
    """

    megahit_map = parse_megahit(sample_id)
    megahit_2500_map = parse_megahit_2500(sample_id)
    return {**megahit_map, **megahit_2500_map}


## Calls mapping compare and creates a nested dict through dict comprehension. It then pass the nested dict to pandas which parses the outer dict as rows and the inner as columns using the orient = "index" option
mapped_df = pd.DataFrame.from_dict(
    {key: mapped_compare(key) for key in samples}, orient="index"
)
mapped_df = mapped_df.assign(
    mega_reads=lambda x: x[["mega_read1_map", "mega_read2_map"]].mean(axis=1),
    mega_percent=lambda x: x[["mega_percent_read1_map", "mega_percent_read2_map"]].mean(
        axis=1
    ),
    mega_2500_reads=lambda x: x[["mega_2500_read1_map", "mega_2500_read2_map"]].mean(
        axis=1
    ),
    mega_2500_percent=lambda x: x[
        ["mega_2500_percent_read1_map", "mega_2500_percent_read2_map"]
    ].mean(axis=1),
)

mapped_df.to_csv(
    "mapped/mapped_megahit_values_compare.csv", index=True, index_label="sample_id"
)
