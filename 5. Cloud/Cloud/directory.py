import os
import zipfile

def extract_file(filename, zipname):
    with zipfile.ZipFile(zipname, 'r') as z:
        z.extract(filename)

def delete_file(filename):
    os.remove(filename)

