import urllib.request
import re

url = "https://www.nvidia.com/download/driverResults.aspx/222350/en-us/"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    links = re.findall(r'href=["\'](.*?\.exe)["\']', html)
    print("Found links:")
    for link in links:
        if link.startswith('//'):
            link = 'https:' + link
        print(link)
except Exception as e:
    print(f"Error: {e}")
