from helpers import *
import xml.etree.cElementTree as ET

def deal_with_none(val):
    if val == None:
        return 'NULL'
    else:
        return val

def insert_midas(con, filename, table_name, needed_sites, test = False):
    cur = con.cursor()
    with open(filename, "r") as f:
        for xml in f:
            tree = ET.ElementTree(ET.fromstring(xml))
            root = tree.getroot()
            measurements = root[1][5]
            site_id = measurements[0].attrib["id"]
            if site_id in needed_sites:
                m_time = measurements[1].text
                m_date = m_time[:10]
                m_abs_time = int(m_time[11:13])*60 + int(m_time[14:16])
                for measure in measurements[2:]:
                    m_index = measure.attrib["index"]
                    basic_data = measure[0][0]
                    m_type = basic_data.attrib[xsi_tag("type")][5:]
                    m_error = basic_data[0][0].text
                    m_value = basic_data[0][1].text
                    if test:
                        print (site_id, m_index, m_date, m_abs_time, m_type, to_bool(m_error), m_value)
                    else:
                        query = "INSERT INTO {} VALUES('{}', {}, '{}', {}, '{}', {}, {})".format(table_name, site_id, m_index, m_date, m_abs_time, m_type, to_bool(m_error), deal_with_none(m_value))
                        #print query
                        cur.execute(query)
                        #cur.execute("INSERT INTO %s VALUES(%s, %s, %s, %s, %s, %s, %s)", (table_name, site_id, m_index, m_date, m_abs_time, m_type, to_bool(m_error), m_value))
                        con.commit()
