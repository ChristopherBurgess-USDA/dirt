# %%
import os
import altair as alt
import numpy as np
import pandas as pd
import statsmodels.api as sm
from sklearn.linear_model import LinearRegression

data_path = "../../Thesis/dirt/enzyme/"

if os.getcwd() != '/home/tunasteak/box/projects/dirt':
  os.chdir('/home/tunasteak/box/projects/dirt')

soil_water_data = pd.read_csv(data_path + "soil_water_content.csv") \
  .assign(
    soil_percent = lambda x: (x['tin_dry_soil']-x['tin'])/(x['tin_wet_soil']-x['tin'])
  ) \
  .filter(['sample', 'soil_percent'])

import_weights = pd.read_csv(data_path + "peptidase/tube_weights.csv") \
  .pipe(pd.merge, soil_water_data, on = "sample", how = "left") \
  .assign(
    slurry = lambda x: x['tube_soil'] - x['tube'],
    soil_ratio = lambda x: 33/(x['soil_percent']*3),
    soil_mass = lambda x: x['slurry']/x['soil_ratio']*1000
  ) \
  .filter(['sample', 'incubation_time', 'rep', 'soil_mass'])

casin_constant = pd.read_csv(data_path + "peptidase/casin_blank.csv") \
  .mean() \
  .to_dict()



# %%

def peptidase_file_parse(treatments, inc_time):
  """
  For a given treatment pair and incubation time it reads in the correct csv file. Then calculates the standard curve calls activity_calc to do the conversions.

  Args:
      treatments (string): a treatment pair for file name to read in
      inc_time (string): incubation time for file name

  Returns:
      pd.Dataframe: Dataframe with the calculated absorbance values
      float64: R squared value for standard curve results
  """

  file_path = data_path + 'peptidase/peptidase_' + treatments + "_" + inc_time + ".csv"
  import_data = pd.read_csv(file_path) \
    .pipe(pd.melt, id_vars = ['sample', 'rep_std'])

  std_data = import_data \
    .query('sample == "std"') \
    .filter(['rep_std', 'value']) \
    .astype('float64') \
    .query('rep_std <= 250')

  #  Water blank value to add back to calculations
  std_0 = std_data.query('rep_std == 0') \
  .value \
  .mean()

  raw_data = import_data \
    .query('sample != "std"') \
    .rename(columns = {'rep_std': 'rep'}) \
    .assign(incubation_time = inc_time)
  
  # Calculates standard curve
  std_x = sm.add_constant(std_data[['value']])
  std_curve = sm.OLS(std_data['rep_std'], std_x).fit()

  activity_data = raw_data \
    .assign(
      value = lambda x: x['value'] - casin_constant[inc_time] + std_0,
      pred = lambda x: std_curve.predict(sm.add_constant(x['value']))
    ) \
    .drop(columns = ['variable']) \
    .groupby(['incubation_time', 'sample', 'rep']) \
    .agg(
      pred = ('pred', np.mean),
      absorbance = ('value', np.mean)
    ) \
    .reset_index() \
    .pipe(
      pd.merge,
      import_weights,
      on = ['incubation_time', "sample", 'rep'],
      how = "left"
      ) \
    .assign(activity = lambda x: x['pred']*4.65/x['soil_mass']) \
    .filter(['sample', 'rep', 'absorbance', 'pred','activity']) \
    .rename(columns = {
      'activity': 'activity_' + inc_time,
      'pred': 'pred_' + inc_time,
      'absorbance': 'absorbance_' + inc_time
    })

  return activity_data, std_curve.rsquared


def peptidase_parser(treatment_header):
  """
  This function reads in all peptidase files, calls functions to calculate umol of tyrosine from absorbance values and merges the data from different incubation times into 1 dataframe

  Args:
      treatment_header (string): treatment pair for file import

  Returns:
      pd.Dataframe: the parsed data for all incubation times for the treatment pair
      pd.Dataframe: the Rsquared values for all the standard curves of the treatment pair.
  """

  times = ['0h', '24h', '48h']
  
  pre_data, std_r2 = zip(*(peptidase_file_parse(treatment_header, i) for i in times))

  parsed_r2 = pd.DataFrame(
    [std_r2],
    index = [treatment_header],
    columns = times
    )

  parsed_data = pre_data[0] \
    .pipe(
      pd.merge,
      pre_data[1],
      how = 'left',
      on = ['sample', 'rep']
    ) \
    .pipe(
      pd.merge,
      pre_data[2],
      how = 'left',
      on = ['sample', 'rep']
    )

  column_header = ['absorbance_', 'pred_', 'activity_']
  column_reorder = [x + y for x in column_header for y in times]
  column_reorder = ['sample', 'rep',*column_reorder]
  parsed_data = parsed_data[column_reorder]

  return parsed_data, parsed_r2

column_header = ['absorbance_', 'pred_', 'activity_']

column_reorder = [item1 + item2 for item1 in column_header for item2 in ['0h', '24h', '48h']]

# %%
treatments = ['co_dl', 'dw_ni', 'nl_nr']

pep_data, std_r2 = zip(*(peptidase_parser(i) for i in treatments))

pep_data = pd.concat(pep_data) \
  .rename(columns = {'sample': 'sample_id'})

std_r2 = pd.concat(std_r2)

pep_data.to_csv("data/enzyme/peptidase_activity.csv")

# %%

test = pd.read_csv(data_path + "peptidase/peptidase_co_dl_0h.csv") \
  .pipe(pd.melt, id_vars = ['sample', 'rep_std'])


standard = LinearRegression(fit_intercept=True)

test_std = test \
  .query('sample == "std"') \
  .filter(['rep_std', 'value']) \
  .astype('float64') \
  .query('rep_std <= 250')

## Remove 0 from standard calc

test_data = test \
  .query('sample != "std"') \
  .filter(['rep_std', 'value'])

test_0 = test_std.query('rep_std == 0') \
  .value \
  .mean()

test_std['value'] = np.where(test_std['rep_std'] == 0, 0, test_std['value'] - test_0)

# %%
standard.fit(test_std[['value']], test_std[['rep_std']])

x = sm.add_constant(test_std[['value']])

model = sm.OLS(test_std['rep_std'], x).fit()
print(model.summary())

test_data = test \
  .query('sample != "std"') \
  .assign(
    pred = lambda x: model.predict(sm.add_constant(x['value']))
  ) \
  .drop(columns = ['variable', 'value']) \
  .groupby(['sample', 'rep_std']) \
  .agg(['mean'])

#plt.scatter(test_std2[['rep_std']], test_std2[['value']]);

# sns.regplot(x = 'value', y= 'rep_std', data = test_std2)

chart = alt.Chart(test_std).mark_circle().encode(
  x = 'value',
  y = 'rep_std'
)

chart + chart.transform_regression('value', 'rep_std').mark_line()
# %%
