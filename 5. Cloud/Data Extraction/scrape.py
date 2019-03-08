from days import *
from directory import *
from get_file import *
from get_sites import *
from get_links import *

from midas import *
from ptd import *
from travel_time import *
from events import *

con = mdb.connect('localhost', 'ayman', '1123581321', 'thales')

start = new_year()
#end = today()
end = day(2016,1,2)

#dates = [day(2011,1,1), day(2012,1,1)]

dates = get_dates(start, end)

m25_sites = get_m25_sites(con)
m6_sites = get_m6_sites(con)
m11_sites = get_m11_sites(con)

m25_links = get_m25_links(con)
m6_links = get_m6_links(con)
m11_links = get_m11_links(con)

for date in dates:
    download_day(date)
    filename = 'NTISDATD-MIDAS-{}-Day1.dat'.format(date)
    extract_file(filename, 'temp.zip')
    insert_midas(con, filename, 'm25_midas', m25_sites)
    insert_midas(con, filename, 'm6_midas', m6_sites)
    insert_midas(con, filename, 'm11_midas', m11_sites)
    delete_file(filename)

    filename = 'NTISDATD-PTD-{}-Day1.dat'.format(date)
    extract_file(filename, 'temp.zip')
    insert_ptd(con, filename, 'm25_ptd', m25_links)
    insert_ptd(con, filename, 'm6_ptd', m6_links)
    insert_ptd(con, filename, 'm11_ptd', m11_links)
    insert_travel_times(con, filename, 'm25_travel_time', m25_links)
    insert_travel_times(con, filename, 'm6_travel_time', m6_links)
    insert_travel_times(con, filename, 'm11_travel_time', m11_links)
    delete_file(filename)

    filename = 'NTISDATD-Events-{}-Day1.dat'.format(date)
    extract_file(filename, 'temp.zip')
    insert_events(con, filename, 'm25_events', m25_links)
    insert_events(con, filename, 'm6_events', m6_links)
    insert_events(con, filename, 'm11_events', m11_links)
    delete_file(filename)

    delete_file('temp.zip')

