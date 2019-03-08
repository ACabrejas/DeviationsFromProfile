from helpers import *
import xml.etree.cElementTree as ET

def attribute_handler(obj):
    if obj is None:
        return None
    else:
        return obj.text

def insert_events(con, filename, table_name, needed_links, test = False):
    #Init cursor
    cur = con.cursor()
    with open(filename, "r") as f:
        for xml in f:
            try:
                tree = ET.ElementTree(ET.fromstring(xml))
                root = tree.getroot()
                situation = root[1].find(d2lm_tag("situation"))
                #Event ID
                event_id = situation.attrib["id"]

                situation_record = situation.find(d2lm_tag("situationRecord"))
                #Event Type
                event_type = situation_record.attrib[xsi_tag("type")][5:]
                #Start and End Time
                validity = situation_record.find(d2lm_tag("validity"))
                overall_start = validity[1].find(d2lm_tag("overallStartTime"))
                overall_end = validity[1].find(d2lm_tag("overallEndTime"))
                event_start = attribute_handler(overall_start)
                event_end = attribute_handler(overall_end)
                #Link Location
                location_groups = situation_record.find(d2lm_tag("groupOfLocations"))
                for location in location_groups.findall(d2lm_tag("locationContainedInGroup")):
                    try:
                        predefined_location = location.find(d2lm_tag("predefinedLocationReference"))
                        link_id = predefined_location.attrib["id"]
                        if int(link_id) in needed_links:
                            if test:
                                print event_id, event_type, event_start, event_end, link_id
                            else:
                                query = "INSERT INTO {} VALUES({}, {}, '{}', '{}', '{}')".format(table_name, event_id, link_id, event_type, event_start, event_end)
                                #print query
                                #cur.execute("INSERT INTO %s VALUES(%s, %s, %s, %s, %s)", (table_name, event_id, event_type, event_start, event_end, link_id))
                                cur.execute(query)
                                con.commit()
                    except AttributeError:
                        continue
            except ET.ParseError:
                continue
