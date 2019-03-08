from db_module import *
import MySQLdb as mdb

#Change this
con = mdb.connect('localhost', 'ayman', '1123581321', 'thales')
date = "2016-03-29"
version = "4.1"

insert_links(date, version, con)
insert_nodes(date, version, con)
insert_measurements(date, version, con)
insert_sites(date, version, con)
