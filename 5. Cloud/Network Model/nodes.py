from tags import *
import xml.etree.cElementTree as ET

def get_nodes(date, version):
    filename = "NTISModel-PredefinedLocations-{}-v{}.xml".format(date, version)
    tree = ET.parse(filename)
    root = tree.getroot()

    for network_node in tree.iter(tag=d2lm_tag("predefinedLocationContainer")):
        if network_node.attrib["id"] == "NTIS_Network_Nodes":
            for node in network_node:
                node_id = node.attrib["id"]
                location = node.find(d2lm_tag("location"))
                latitude = location[0][0][0].text
                longitude = location[0][0][1].text

                yield (node_id, latitude, longitude)
