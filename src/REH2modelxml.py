# https://www.google.com/maps/d/u/0/kml?mid=1EK7NRsdgmItcUqYpzhK64Ke0QW0&lid=zyQ9TAMFMqLU.kFJmOoRJqOXM&forcekml=1
# https://www.google.com/maps/d/embed?mid=1EK7NRsdgmItcUqYpzhK64Ke0QW0&hl=en_US

import lxml.etree as etree
from unicodedata import normalize
import urllib.request
import json

user_agent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7'
headers={'User-Agent':user_agent,}
google_elevation_url = "https://maps.googleapis.com/maps/api/elevation/json?key=AIzaSyCWUmhSRBfvPMZeSz6qlO4HD3YkO8RHFSU&locations={},{}"

tree = etree.parse('REFERÊNCIAS VISUAIS.kml').findall('.//{http://www.opengis.net/kml/2.2}Placemark')
tree2 = etree.parse('REFERÊNCIAS VISUAIS.kml').findall('.//{http://www.opengis.net/kml/2.2}coordinates')

names = []
coords = []

for t in tree :
    names.append(normalize('NFKD', t[0].text).encode('ASCII','ignore').decode('ASCII'))

for t in tree2 :
    coords.append(t.text.strip().split(','))

import os

xml = open('checkpoint.xml').read()
os.makedirs(os.path.dirname('output/'), exist_ok=True)
stg = open('output/models.stg', 'w')

for x in range(0, len(names)):
	request=urllib.request.Request(google_elevation_url.format(coords[x][1], coords[x][0]),None,headers) 
	response = urllib.request.urlopen(request)
	data = response.read()
	js = json.loads(data.decode('utf8'))
	elev = js['results'][0]['elevation']
	print(js)
	print(elev)

	filename = "output/{}.xml".format(names[x])
	file = open(filename, 'w')
	file.write(xml.format(names[x]))
	stg.write("{},{},{},{},{};\n".format(filename.split('/')[1],names[x],coords[x][0], coords[x][1], elev + 100.0))
	file.close()
stg.close()
'''	
rehfile = open('exported/model','w')
rehfile.write(header)
for x in range(0, len(names)):
    rehfile.write(template.format(x,names[x],coords[x][0],coords[x][1]))
rehfile.write(footer)
rehfile.close()
'''
input('Convertido para a pasta Output. Pressione ENTER para sair.')