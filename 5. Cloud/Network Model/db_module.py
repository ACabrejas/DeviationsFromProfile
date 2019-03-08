import MySQLdb as mdb
import links
import measurements
import nodes
import sites

def insert_links(date, version, con):
    #Insert links into DB
    with con:
        links_cur = con.cursor()
        links_gen = links.get_links(date, version)
        for link in links_gen:
            links_cur.execute("INSERT INTO links VALUES(%s, %s, %s, %s, %s, %s, %s)", link)

def insert_nodes(date, version, con):
    #Insert nodes into DB
    with con:
        nodes_cur = con.cursor()
        nodes_gen = nodes.get_nodes(date, version)
        for node in nodes_gen:
            nodes_cur.execute("INSERT INTO nodes VALUES(%s, %s, %s)", node)

def insert_measurements(date, version, con):
    #Insert measurements in DB
    with con:
        measurements_cur = con.cursor()
        measurements_gen = measurements.get_measurements(date, version)
        for measurement in measurements_gen:
            measurements_cur.execute("INSERT INTO measurements VALUES(%s, %s, %s, %s, %s, %s)", measurement)

def insert_sites(data, version, con):
    #Insert sites in DB
    with con:
        sites_cur = con.cursor()
        sites_gen = sites.get_sites(date, version)
        for site in sites_gen:
            sites_cur.execute("INSERT INTO sites VALUES(%s, %s, %s, %s, %s, %s, %s)", site)

