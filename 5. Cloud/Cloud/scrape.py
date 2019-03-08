import pymssql

from days import *
from directory import *
from get_file import *
from get_sites import *
from get_links import *

from midas import *
from ptd import *
from travel_time import *
from events import *

#start = new_year()
#end = today()
#end = day(2016,1,2)

dates = [day(2016,3,1)]

#dates = get_dates(start, end)

con1 = pymssql.connect(server='thales-mathsys1.database.windows.net', user='ayman-admin@thales-mathsys1', password='fb1123581321&', database='thales')

with con1:
    m25_sites = get_m25_sites(con1)
    m6_sites = get_m6_sites(con1)
    m11_sites = get_m11_sites(con1)

    m25_links = get_m25_links(con1)
    m6_links = get_m6_links(con1)
    m11_links = get_m11_links(con1)

for date in dates:
    con = pymssql.connect(server='thales-mathsys1.database.windows.net', user='ayman-admin@thales-mathsys1', password='fb1123581321&', database='thales')
#    download_day(date)
    with con:
        # filename = 'NTISDATD-MIDAS-{}-Day1.dat'.format(date)
        # extract_file(filename, 'temp.zip')
        # insert_midas(con, filename, 'm6_midas', m6_sites)
        # print "M6 MIDAS done!"
        # insert_midas(con, filename, 'm11_midas', m11_sites)
        # print "M11 MIDAS done!"
        # delete_file(filename)

        filename = 'NTISDATD-PTD-{}-Day1.dat'.format(date)
        extract_file(filename, 'temp.zip')
        insert_ptd(con, filename, 'm6_ptd', m6_links)
        print "M6 PTD done!"
        insert_ptd(con, filename, 'm11_ptd', m11_links)
        print "M11 PTD done!"
        insert_travel_times(con, filename, 'm6_travel_time', m6_links)
        print "M6 TM done!"
        insert_travel_times(con, filename, 'm11_travel_time', m11_links)
        print "M11 TM done!"
        delete_file(filename)

        filename = 'NTISDATD-Events-{}-Day1.dat'.format(date)
        extract_file(filename, 'temp.zip')
        insert_events(con, filename, 'm6_events', m6_links)
        print "M6 Events done!"
        insert_events(con, filename, 'm11_events', m11_links)
        print "M11 Events done!"
        delete_file(filename)

    delete_file('temp.zip')

