from tags import *
import xml.etree.cElementTree as ET

def get_links(date, version):
    filename = "NTISModel-PredefinedLocations-{}-v{}.xml".format(date, version)
    tree = ET.parse(filename)
    root = tree.getroot()

    for network_link in tree.iter(tag=d2lm_tag("predefinedLocationContainer")):
        if network_link.attrib["id"] == "NTIS_Network_Links":
            for link in network_link:
                link_id = link.attrib["id"]
                location = link.find(d2lm_tag("location"))
                loc_info = location[0].find(d2lm_tag("affectedCarriagewayAndLanes"))
                link_type = loc_info[0].text
                link_length = loc_info[2].text

                lw_lin_element = location.find(
                    d2lm_tag("linearWithinLinearElement"))

                link_direction = lw_lin_element[0].text
                road_number = lw_lin_element[1][0].text
                from_point = lw_lin_element[2][1][0].text
                to_point = lw_lin_element[3][1][0].text

                yield (link_id, link_type, link_length, link_direction, road_number, from_point, to_point)
