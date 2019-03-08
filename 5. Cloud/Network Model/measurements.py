from tags import *
import xml.etree.cElementTree as ET

def get_measurements(date, version):
    filename = "NTISModel-MeasurementSites-{}-v{}.xml".format(date, version)
    tree = ET.parse(filename)
    root = tree.getroot()

    for site in tree.iter(tag=d2lm_tag("measurementSiteRecord")):
        equip = site.find(d2lm_tag("measurementEquipmentTypeUsed"))
        if equip[0][0].text == "loop":
            site_id = site.attrib["id"]
        else:
            continue

        measures = site.findall(d2lm_tag("measurementSpecificCharacteristics"))
        for measurement in measures:
            m_index = measurement.attrib["index"]
            m_lane = measurement[0][0].text
            m_type = measurement[0][1].text
            l_len = None
            u_len = None
            try:
                vehicle_characteristics = measurement[0][2]
                for vehicle in vehicle_characteristics.iter(
                                      d2lm_tag("lengthCharacteristic")
                                                           ):
                    if vehicle[0].text[:4] == "less":
                        u_len = vehicle[1].text
                    else:
                        l_len = vehicle[1].text
            except IndexError:
                pass

            yield (site_id, m_index, m_lane, m_type, l_len, u_len)
