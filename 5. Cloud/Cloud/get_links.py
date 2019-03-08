def get_m25_links(con):
    cur = con.cursor()
    cur.execute("SELECT link_id FROM links LEFT JOIN nodes ON links.from_node = nodes.node_id WHERE ((node_lon >  -0.55 AND node_lon < -0.35) AND (node_lat > 51.30 AND node_lat < 51.75) AND (link_location LIKE 'M25'))")
    needed_links = [int(link[0]) for link in cur.fetchall()]
    return needed_links

def get_m11_links(con):
    cur = con.cursor()
    cur.execute("SELECT link_id FROM links WHERE (link_location LIKE 'M11')")
    needed_links = [int(link[0]) for link in cur.fetchall()]
    return needed_links

def get_m6_links(con):
    cur = con.cursor()
    cur.execute("SELECT link_id FROM links LEFT JOIN nodes ON links.from_node = nodes.node_id WHERE ((node_lon > -2.707 AND node_lon < -2.625) AND (node_lat > 53.709 AND node_lat < 53.810) AND (link_location LIKE 'M6'))")
    needed_links = [int(link[0]) for link in cur.fetchall()]
    return needed_links
