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
            while row:
                row = [str(r) for r in row]
                entry = ", ".join(row)+"\n"
                f.write(entry)
                row = cur.fetchone()

def main():
    execute_to_csv("SELECT * FROM m11_events", "test.csv")

if __name__ == '__main__':
        main()
