import MySQLdb as mdb

def get_m25_sites(con):
    with con:
        cur = con.cursor()
        cur.execute("SELECT site_id FROM sites WHERE ((longitude >  -0.55 AND longitude < -0.35) AND (latitude > 51.30 AND latitude < 51.75) AND (site_reference LIKE 'M25%'))")
        needed_sites = [site[0] for site in cur.fetchall()]
    return needed_sites

def get_m11_sites(con):
    with con:
        cur = con.cursor()
        cur.execute("SELECT site_id FROM sites WHERE (site_reference LIKE 'M11%')")
        needed_sites = [site[0] for site in cur.fetchall()]
    return needed_sites

def get_m6_sites(con):
    with con:
        cur = con.cursor()
        cur.execute("SELECT site_id FROM sites WHERE ((longitude > -2.707 AND longitude < -2.625) AND (latitude > 53.709 AND latitude < 53.810) AND (site_reference LIKE 'M6%'))")
        needed_sites = [site[0] for site in cur.fetchall()]
    return needed_sites
