# %%

import os, re, tarfile, glob

if os.getcwd() != "/home/roots/burgesch/dirt":
    os.chdir("/home/roots/burgesch/dirt")


# %%

files_to_extract = glob.glob("raw/*/IMG_Data/*.tar.gz")

for item in files_to_extract:
    my_tar = tarfile.open(item)
    my_tar.extractall(re.sub("/\d+.tar.gz", "", item))
    my_tar.close()
