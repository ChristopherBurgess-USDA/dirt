import re

re_remove = re.compile(r'_filtered')
files = list()
filename = "files_to_assemble"
with open(filename) as file_obj:
  for line in file_obj:
    line_strip = line.strip()
    files.append(line_strip)

files = [re_remove.sub('', f) for f in files]

def megahit_output_command(job_id):
  return "megahit --12 /dfs/ROOTS/Myrold_Lab/Chris/dirt/filtered/" + job_id +"_filtered.fastq.gz --presets meta-large --min-contig-len 1000 --tmp-dir /home/roots/burgesch/temp/ -o /dfs/ROOTS/Myrold_Lab/Chris/dirt/assembled/" + job_id + "; mv /dfs/ROOTS/Myrold_Lab/Chris/dirt/assembled/"+ job_id + "/final.contigs.fa /dfs/ROOTS/Myrold_Lab/Chris/dirt/assembled/" + job_id+ "_contigs.fa\n"


with open("array_dirt_megahit_assembly.txt", 'w') as file_obj:
  for i in files:
    file_obj.write(megahit_output_command(i))