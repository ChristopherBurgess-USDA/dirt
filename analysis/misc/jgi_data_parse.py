import shutil, os, re

file_list = os.listdir(".")

id_search = re.compile(r'\w{2}-\w{2}-\w')

file_renames = {i:id_search.search(i).group() for i in file_list}

for key, value in file_renames.items():
  shutil.move(key, value)