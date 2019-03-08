import MySQLdb as mdb

con = mdb.connect('localhost', 'ayman', '1123581321', 'thales')

with con:
    cur = con.cursor()
    cur.execute("SELECT link_id FROM links WHERE (link_location LIKE 'M11')")

print [int(link[0]) for link in cur.fetchall()]
