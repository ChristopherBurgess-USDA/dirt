"""
This script parses the raw bg and cbh data into activity
"""
#%%
import pandas as pd
import os
# import numpy as np

data_path = "../../Thesis/dirt/enzyme/"

if os.getcwd() != '/home/tunasteak/box/projects/dirt':
    os.chdir('/home/tunasteak/box/projects/dirt')

import_sw = pd.read_csv(data_path + "soil_water_content.csv")


# %%

soil_water_data = import_sw \
  .assign(
    soil_percent = lambda x: (x['tin_dry_soil']-x['tin'])/(x['tin_wet_soil']-x['tin']),
    soil_bg_cbh_mass = lambda x: x.soil_percent * x.soil_bg_cbh_take2,
    soil_perox_phenol_mass = lambda x: x.soil_percent * x.soil_perox_phenol
  ) \
  .set_index('sample') \
  .filter(['soil_percent', 'soil_bg_cbh_mass'])

# %%

def bg_cbh_parse(file_path):
  """
  This function reads in the flourences values for a given plate and calculates activity.

  Args:
      file_path (string): file path the raw enzyme plate readings

  Returns:
      pd.Series: Average enzyme activity
  """
  import_data = pd.read_csv(file_path).mean()
  
  std_buffer = import_data.loc['buff_std']
  sub_control = import_data.loc['buff_sub']
  emission = import_data.loc['buff_std']/.5
  
  temp = import_data.iloc[3:]
  temp_index = [i.split("_") for i in list(temp.index)]
  index = pd.MultiIndex.from_tuples(temp_index)
  
  
  avg_data = pd.Series(list(temp), index = index) \
    .unstack() \
    .join(soil_water_data) \
    .assign(
      q = lambda x: x['std']/std_buffer, 
      activity = lambda x: ((((x['sub']-x['buff'])/x['q'])-sub_control)/(emission*4*x['soil_bg_cbh_mass']*.2))*100
    ) \
    .filter(['activity'])
    
  return avg_data

# %%
treatments = ["co", "dl", "dw", "ni", "nl", "nr"]
bg_files = ["bg/bg_" + i + "_take2.csv" for i in treatments]
cbh_files = ["cbh/cbh_" + i + "_take2.csv" for i in treatments]

bg_list= [bg_cbh_parse(data_path + i) for i in bg_files]
cbh_list = [bg_cbh_parse(data_path + i) for i in cbh_files]

# %%
bg_data = pd.concat(bg_list) \
  .rename(columns = {"activity": "bg_activity_take2"})
  
complete_data = pd.concat(cbh_list) \
  .rename(columns = {"activity": "cbh_activity_take2"}) \
  .join(bg_data)
# %%
complete_data.to_csv("data/enzyme/bg_cbh_activity_take2.csv", index = True)
# %%
