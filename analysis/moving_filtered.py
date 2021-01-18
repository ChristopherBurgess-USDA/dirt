import shutil, os, glob

# This list all the files and what they will re renamed to
file_list = os.listdir(".")

# This finds the names of all the filtered fastq.gz files
filtered_fq = glob.glob('./*/QC_Filtered_Raw_Data/*.fastq.gz')

# Combines these two list of files into a dictionary
test = dict(zip(file_list, filtered_fq))


for key, value in test.items():
  key = "../filtered/" + key + "_filtered.fastq.gz"
  shutil.copy(value, key)