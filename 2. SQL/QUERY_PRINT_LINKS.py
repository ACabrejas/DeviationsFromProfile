import pymssql

"""Instructions: In a new python script write the following at the top:

from query import *

And the use the execute_to_csv function like you normally do.
"""

def execute_to_csv(query, filename):
    con = pymssql.connect(server='thales-mathsys1.database.windows.net', user='ayman-admin@thales-mathsys1', password='fb1123581321&', database='thales')
    with con:
        cur = con.cursor()
        cur.execute(query)
        row = cur.fetchone()
        with open(filename, 'w') as f:
            f.write("link_id, link_type, link_length, link_direction, link_location, from_node, to_node, from_lat, from_lon, to_lat, to_lon\n")
            while row:
                row = [str(r) for r in row]
                entry = ", ".join(row)+"\n"
                f.write(entry)
                row = cur.fetchone()

def main():
    qry = "SELECT L.*, NF.node_lat AS from_lat, NF.node_lon AS from_lon, NT.node_lat AS to_lat, NT.node_lon AS to_lon FROM"
    qry = qry + " (SELECT * FROM links WHERE link_id IN (SELECT DISTINCT link_id FROM m11_travel_time)) AS L "
    qry = qry + " LEFT JOIN (SELECT * FROM nodes) AS NF"
    qry = qry + " ON L.from_node = NF.node_id"
    qry = qry + " LEFT JOIN (SELECT * FROM nodes) AS NT"
    qry = qry + " ON L.to_node = NT.node_id"
    execute_to_csv(qry, "m11_links.csv")

if __name__ == '__main__':
        main()
