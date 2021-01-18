import pandas as pd
import numpy as np
import re

re_remove = re.compile(r'-a')
samples = [
  "CO-08-A", "CO-12-A", "CO-14-A",\
  "DL-02-A", "DL-13-A", "DL-17-A",\
  "DW-05-A", "DW-10-A", "DW-16-A",\
  "NI-19-A", "N I-49-A", "NI-69-A",\
  "NL-03-A", "NL-07-A", "NL-11-A",\
  "NR-01-A", "NR-04-A", "NR-06-A"\
]

samples= [item.lower() for item in samples]

samples = [re_remove.sub('', item) for item in samples]

times = ["_0h", "_24h", "_48h"]

samples = [item + i for item in samples for i in times]

reps = ["_rep1", "_rep2", "_rep3"]

samples = [item + i for item in samples for i in reps]

df = pd.DataFrame(samples, columns = ['sample_id'])

df[['sample', 'incubation_time', 'rep']] = df.sample_id.str.split("_", expand = True)

df = df[['sample', 'incubation_time', 'rep']]

df.to_csv("data/protein_assay_data_sheet.csv", index = False)
