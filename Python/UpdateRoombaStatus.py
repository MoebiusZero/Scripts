#import libraries
import urllib
import urllib2
import json

#Call domoticz function
def calldomoticz(url):
 reqdom = urllib2.Request(domoticzurl)
 resdom = urllib2.urlopen(domoticzurl)

#Call the Pushsafer API to push a notification
def pushmessageroomba(title,message):
 url = 'https://www.pushsafer.com/api'
 post_fields = {
        "t" : 'Roomba: ' + title,
        "m" :  message ,
        "s" : '',
        "v" : '',
        "i" : '',
        "d" : 'a',
        "k" : 'fafeKkl8RySWvc2P8Qjm',
        }

 request = urllib2.Request(url, urllib.urlencode(post_fields).encode())
 json = urllib2.urlopen(request).read().decode()

#Function to call up the variable in Domoticz
def domoticzroombavar(idx):
 response = urllib2.urlopen("http://127.0.0.1:8080/json.htm?type=command&param=getuservariable&idx=" + idx)
 data_json = json.loads(response.read())
 variable = (data_json['result'][0]['Value'])
 return variable

#Roomba devices
devices = ["http://10.10.0.19:3001/api/local/info/state","http://10.10.0.19:3000/api/local/info/state","http://10.10.0.19:3002/api/local/info/state"]

for device in devices:
    #Get status from each Roomba and put the values in Domoticz
    response = urllib2.urlopen(device)
    data_json = json.loads(response.read())
    name = (data_json['name'])
    status = (data_json['cleanMissionStatus']['phase'])

    if name == "Downstairs":
        variable = domoticzroombavar('6')
        domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=RoombaDownstairsStatus&vtype=string&vvalue=" + status       
        calldomoticz(domoticzurl)

        if status == "charge" and status != variable:
           domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=switchlight&idx=803&switchcmd=Set%20Level&level=0"		
           calldomoticz(domoticzurl)
           pushmessageroomba(name,"Roomba is now charging")
        elif status == "run" and status != variable:
           domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=switchlight&idx=803&switchcmd=Set%20Level&level=10"
           calldomoticz(domoticzurl)
           pushmessageroomba(name,"Roomba is now cleaning")
        elif status == "stop" and status != variable: 
           domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=switchlight&idx=803&switchcmd=Set%20Level&level=30"
           calldomoticz(domoticzurl)
           pushmessageroomba(name,"Roomba has stopped for a unknown reason, please check up on the Roomba Downstairs")

    if name == "Upstairs":
        variable = domoticzroombavar('5')
        domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=RoombaUpstairsStatus&vtype=string&vvalue=" + status
        calldomoticz(domoticzurl)
        
        if status == "charge" and status != variable:
           domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=switchlight&idx=802&switchcmd=Set%20Level&level=0"
           calldomoticz(domoticzurl)
           pushmessageroomba(name,"Roomba is now charging")
        elif status == "run" and status != variable:
           domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=switchlight&idx=802&switchcmd=Set%20Level&level=10"
           calldomoticz(domoticzurl)
           pushmessageroomba(name,"Roomba is now cleaning")
        elif status == "stop" and status != variable:
           domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=switchlight&idx=802&switchcmd=Set%20Level&level=30"
           calldomoticz(domoticzurl)
           pushmessageroomba(name,"Roomba has stopped for a unknown reason, please check up on the Roomba Upstairs")

    if name == "Downstairs Mop":
        variable = domoticzroombavar('7')
        domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=RoombaDownstairsMopStatus&vtype=string&vvalue=" + status
        calldomoticz(domoticzurl)
	   
        if status == "charge" and status != variable:
           domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=switchlight&idx=804&switchcmd=Set%20Level&level=0"
           calldomoticz(domoticzurl)
           pushmessageroomba(name,"Roomba is now charging")
        elif status == "run" and status != variable:
           domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=switchlight&idx=804&switchcmd=Set%20Level&level=10"
           calldomoticz(domoticzurl)
           pushmessageroomba(name,"Roomba is now cleaning")
        elif status == "stop" and status != variable:
           domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=switchlight&idx=804&switchcmd=Set%20Level&level=30"
           calldomoticz(domoticzurl)
           pushmessageroomba(name,"Roomba has stopped for a unknown reason, please check up on the Roomba Mop Downstairs")

