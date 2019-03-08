from tags import *
import xml.etree.cElementTree as ET

def get_sites(date, version):
    filename = "NTISModel-MeasurementSites-{}-v{}.xml".format(date, version)
    tree = ET.parse(filename)
    root = tree.getroot()

    for site in tree.iter(tag=d2lm_tag("measurementSiteRecord")):
        equip = site.find(d2lm_tag("measurementEquipmentTypeUsed"))
        if equip[0][0].text == "loop":
            site_id = site.attrib["id"]
        else:
            continue

        reference = site.find(d2lm_tag("measurementSiteIdentification"))
        site_reference = reference.text

        loc = site.find(d2lm_tag("measurementSiteLocation"))
        site_lat  = loc[0][0].text
        site_lon = loc[0][1].text

        link = loc[1][0].find(d2lm_tag("linearElementIdentifier"))
        link_id = link.text

        along = loc[1][1].find(d2lm_tag("distanceAlong"))
        distance_along_link =  along.text.split()[0]

        measures = site.findall(d2lm_tag("measurementSpecificCharacteristics"))
        site_nmeasures = len(measures)

        yield (site_id, site_reference, link_id, distance_along_link, site_lat, site_lon, site_nmeasures)
