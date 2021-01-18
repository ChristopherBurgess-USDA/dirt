#%%
import altair as alt
import numpy as np
import pandas as pd
import os

data_path = "../../Thesis/dirt/enzyme/"

if os.getcwd() != '/home/tunasteak/box/projects/dirt':
    os.chdir('/home/tunasteak/box/projects/dirt')

import_sw = pd.read_csv(data_path + "soil_water_content.csv")


# %%
soil_water_data = import_sw \
  .assign(
    soil_percent = lambda x: (x['tin_dry_soil']-x['tin'])/(x['tin_wet_soil']-x['tin']),
    soil_mass = lambda x: x.soil_percent * x['soil_perox_phenol_take2'],
    water_mass = lambda x: (1 - x['soil_percent']) * x['soil_perox_phenol_take2']
  ) \
  .set_index('sample') \
  .filter(['soil_percent', 'soil_mass', 'water_mass'])

# %%

def oxidative_parse(file_path):
  """
  This function reads in the absorbance values for a given plate and calculates activity.

  Args:
      file_path (string): file path the raw enzyme plate readings

  Returns:
      pd.Series: Average enzyme activity
  """
  import_data = pd.read_csv(file_path).mean()
  
  control = import_data.loc['std_std']

  
  temp = import_data.iloc[2:]
  temp_index = [i.split("_") for i in list(temp.index)]
  index = pd.MultiIndex.from_tuples(temp_index)
  
  
  avg_data = pd.Series(list(temp), index = index) \
    .unstack() \
    .join(soil_water_data) \
    .assign(
      activity = lambda x: (((100 + x['water_mass']) * (x['std'] - control - x['buff']))/(7.9 * 24 * .2 * x['soil_mass'])) * 1000
    ) \
    .filter(['activity'])
    
  return avg_data

# %%
treatments = ["co", "dl", "dw", "ni", "nl", "nr"]
perox_files = ["oxidative/perox_" + i + ".csv" for i in treatments]
phenol_files = ["oxidative/phenol_" + i + ".csv" for i in treatments]

perox_list= [oxidative_parse(data_path + i) for i in perox_files]
phenol_list = [oxidative_parse(data_path + i) for i in phenol_files]

# %%
perox_data = pd.concat(perox_list) \
  .rename(columns = {"activity": "perox_activity"})
  
complete_data = pd.concat(phenol_list) \
  .rename(columns = {"activity": "phenol_activity"}) \
  .join(perox_data)
# %%
complete_data.to_csv("data/enzyme/oxidative_activity.csv", index = True)
# %%
