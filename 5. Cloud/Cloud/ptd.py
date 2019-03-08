from helpers import *
import xml.etree.cElementTree as ET

def insert_ptd(con, filename, table_name, needed_links, test = False):
    types = ["d2lm:TrafficFlow", "d2lm:TrafficConcentration", "d2lm:TrafficSpeed", "d2lm:TrafficHeadway"]
    #Init cursor
    cur = con.cursor()
    with open(filename, "r") as f:
        for xml in f:
            tree = ET.ElementTree(ET.fromstring(xml))
            root = tree.getroot()
            data_type = root[1].find(d2lm_tag("feedType"))
            #Extract sensor data only
            if data_type.text == "Fused Sensor-only PTD":
                time = root[1].find(d2lm_tag("timeDefault"))
                #Measurement Time
                default_time = time.text
                date = default_time[:10]
                abs_time = int(default_time[11:13])*60 + int(default_time[14:16])
                elaborated = root[1].findall(d2lm_tag("elaboratedData"))
                for data_point in elaborated:
                    #Link ID
                    link_id = data_point[0][0][0].attrib["id"]
                    #Only use the needed links
                    if int(link_id) in needed_links:
                        xsi_type = data_point[0].attrib[xsi_tag("type")]
                        #Extract the needed types only
                        if xsi_type in types:
                            #Measurement Type
                            ptd_type = xsi_type[5:]
                            #Measurement Value
                            ptd_value = data_point[0][1][0].text
                            #For testing
                            if test:
                                print link_id, date, abs_time, ptd_type, ptd_value
                            else:
                                query = "INSERT INTO {} VALUES({}, '{}', {}, '{}', {})".format(table_name, link_id, date, abs_time, ptd_type, ptd_value)
                                #print query
                                #cur.execute("INSERT INTO %s VALUES(NULL, %s, %s, %s, %s, %s)", (table_name, link_id, date, abs_time, ptd_type, ptd_value))
                                cur.execute(query)
                                con.commit()
