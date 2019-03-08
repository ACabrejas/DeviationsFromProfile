from helpers import *
import xml.etree.cElementTree as ET

def insert_travel_times(con, filename, table_name, needed_links, test = False):
    #Init cursor
    cur = con.cursor()
    with open(filename, "r") as f:
        for xml in f:
            tree = ET.ElementTree(ET.fromstring(xml))
            root = tree.getroot()
            data_type = root[1].find(d2lm_tag("feedType"))
            #Extract sensor only data
            if data_type.text == "Fused Sensor-only PTD":
                time = root[1].find(d2lm_tag("timeDefault"))
                #Measurement Time
                default_time = time.text
                date = default_time[:10]
                abs_time = int(default_time[11:13])*60 + int(default_time[14:16])
                elaborated = root[1].findall(d2lm_tag("elaboratedData"))
                for data_point in elaborated:
                    link_id = data_point[0][0][0].attrib["id"]
                    #Only use needed links
                    if int(link_id) in needed_links:
                        xsi_type = data_point[0].attrib[xsi_tag("type")]
                        if xsi_type == "d2lm:TravelTimeData":
                            travel_time_elem = data_point[0].find(
                                d2lm_tag("travelTime"))
                            #Current Travel Time
                            travel_time = travel_time_elem[0].text
                            #Free Flow Travel Time
                            free_flow_elem = data_point[0].find(
                                d2lm_tag("freeFlowTravelTime"))
                            free_flow = free_flow_elem[0].text
                            #Profile Travel Time
                            profile_elem = data_point[0].find(
                                d2lm_tag("normallyExpectedTravelTime"))
                            profile = profile_elem[0].text
                            #For testing
                            if test:
                                print link_id, date, abs_time, travel_time, free_flow, profile
                            else:
                                query = "INSERT INTO {} VALUES({}, '{}', {}, {}, {}, {})".format(table_name, link_id, date, abs_time, travel_time, free_flow, profile)
                                #print query
                                #cur.execute("INSERT INTO %s VALUES(NULL, %s, %s, %s, %s, %s, %s)", (table_name, link_id, date, abs_time, travel_time, free_flow, profile))
                                cur.execute(query)
                                con.commit()
