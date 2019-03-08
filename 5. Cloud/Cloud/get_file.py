import urllib2
import base64

def download_day(date):
    username = 'colmc2'
    password = '6zwnSa4B'

    url = 'https://trafficengland.info/app/datd/service/{}/1'.format(date)

    encoded_auth = base64.b64encode("{}:{}".format(username, password))

    headers = {
    "Host": "trafficengland.info",
    "User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0",
    "Accept": "*/*",
    "Authorization": "Basic {}".format(encoded_auth)
    }

    req = urllib2.Request(url, headers = headers)
    response = urllib2.urlopen(req)

    print response.info()

    print "Downloading..."

    with open("temp.zip", "wb") as f:
        f.write(response.read())
