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
            f.write("link_id, m_date, absolute_time, travel_time, free_flow, profile_time, traffic_concentration, traffic_speed, traffic_flow, traffic_headway, congestion_event, poor_event, other_event\n")
            while row:
                row = [str(r) for r in row]
                entry = ", ".join(row)+"\n"
                f.write(entry)
                row = cur.fetchone()

def main():
    table = "m11"
    print_query = "SELECT link_id, REPLACE(CAST(m_date AS NVARCHAR(255)),'-',''), absolute_time, travel_time, free_flow, profile_time, traffic_concentration, traffic_speed, traffic_flow, traffic_headway, congestion_event, poor_event, other_event FROM"
    print_query = print_query + " " + table + "_data ORDER BY link_id, m_date, absolute_time;"
    
    execute_to_csv(print_query, table + "_3_data.csv")

if __name__ == '__main__':
        main()
