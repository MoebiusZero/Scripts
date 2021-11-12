
#import libraries
import urllib2
import json

#Call domoticz function
def calldomoticz(url):
 reqdom = urllib2.Request(domoticzurl)
 resdom = urllib2.urlopen(domoticzurl)

#Roomba devices
devices = ["http://192.168.1.1:3001/api/local/info/state","http://192.168.1.1:3000/api/local/info/state","http://192.168.1.1:3002/api/local/info/state"]

for device in devices:
    #Get status from each Roomba and put the values in Domoticz
    response = urllib2.urlopen(device)
    data_json = json.loads(response.read())
    name = (data_json['name'])
    status = (data_json['cleanMissionStatus']['phase'])

    if name == "Downstairs":
       domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=RoombaDownstairsStatus&vtype=string&vvalue=" + status
       calldomoticz(domoticzurl)

    if name == "Upstairs":
       domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=RoombaUpstairsStatus&vtype=string&vvalue=" + status
       calldomoticz(domoticzurl)
	   
    if name == "Downstairs Mop":
       domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=RoombaDownstairsMopStatus&vtype=string&vvalue=" + status
       calldomoticz(domoticzurl)
	   
