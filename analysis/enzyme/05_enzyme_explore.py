# %%
import altair as alt
import numpy as np
import pandas as pd
import os

data_path = "../../Thesis/dirt/enzyme/"

if os.getcwd() != '/home/tunasteak/box/projects/dirt':
    os.chdir('/home/tunasteak/box/projects/dirt')


# %%
def read_enzyme(file_name):
  df = pd.read_csv("data/enzyme/" + file_name) \
    .assign(
      treatment = lambda x: x['sample_id'].str[0:2],
      plot = lambda x: x['sample_id'].str[-2:]
    )
  col_names = df.columns.tolist()
  col_names = col_names[-2:] + col_names[:-2]
  df = df[col_names]
  return df

data_files = {
  "bg_cbh": "bg_cbh_activity.csv",
  "bg_cbh_t2": "bg_cbh_activity_take2.csv",
  "oxidative": "oxidative_activity.csv",
  "pep": "peptidase_activity.csv"
}

enzyme_data = {i: read_enzyme(j) for (i,j) in data_files.items()}
# %%

## oxidative data explore

data = enzyme_data.get('oxidative')

alt.Chart(data).mark_point().encode(
  x = "treatment",
  y = 'phenol_activity',
  tooltip = ['sample_id']
).interactive()

# %%

temp = enzyme_data.get('bg_cbh_t2') \
  .assign(take = 'take 2')

temp_2 = enzyme_data.get('bg_cbh') \
  .assign(take = 'take 1')

c_hydro = pd.concat([temp_2, temp])

del temp, temp_2

alt.Chart(c_hydro).mark_point().encode(
  x = "treatment",
  y = 'bg_activity',
  color = 'take',
  tooltip = ['sample_id']
).interactive()

alt.Chart(c_hydro).mark_point().encode(
  x = "treatment",
  y = 'cbh_activity',
  color = 'take',
  tooltip = ['sample_id']
).interactive()
# %%
c_keep = [
  'treatment',
  'plot',
  'sample_id',
  'activity_0h',
  'activity_24h',
  'activity_48h'
]
n_enzyme = enzyme_data.get('pep') \
  .filter(c_keep) \
  .groupby(by = ['treatment', 'plot', "sample_id"]) \
  .agg(
    activity_0h = ('activity_0h', np.mean),
    activity_24h = ('activity_24h', np.mean),
    activity_48h = ('activity_48h', np.mean)
  ) \
  .reset_index() \
  .assign(
    activity_24h = lambda x: x['activity_24h'] - x['activity_0h'],
    activity_48h = lambda x: x['activity_48h'] - x['activity_0h']
  ) \
  .drop(columns = ['activity_0h']) \
  .pipe(
    pd.melt,
    id_vars = ['treatment', 'plot', "sample_id"],
    value_vars = ['activity_24h', 'activity_48h']
  )

alt.Chart(n_enzyme).mark_point().encode(
  x = "treatment",
  y = 'value:Q',
  column = 'variable:N',
  tooltip = ['sample_id']
).interactive()
# %%

# %%
