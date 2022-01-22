from pylgtv import WebOsClient
import urllib.request

#Call Domoticz function
def calldomoticz(url):
    reqdom = urllib.request.Request(domoticzurl)
    resdom = urllib.request.urlopen(domoticzurl)

#Try to connect to the TV
try:
    webos_client = WebOsClient('MY TV IP ADDRESS')
except:
    domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=lgtvstatus&vtype=string&vvalue=Off"
    calldomoticz(domoticzurl)

#Get the status of the tv and push to Domoticz
try:
    tvstatus = webos_client.get_current_app()

    if tvstatus == "netflix":
       domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=lgtvstatus&vtype=string&vvalue=On"
       calldomoticz(domoticzurl)
    elif tvstatus == "cdp-30":
       domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=lgtvstatus&vtype=string&vvalue=Plex"
       calldomoticz(domoticzurl)
    else:
       domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=lgtvstatus&vtype=string&vvalue=On"
       calldomoticz(domoticzurl)
except: 
    domoticzurl = "http://127.0.0.1:8080/json.htm?type=command&param=updateuservariable&vname=lgtvstatus&vtype=string&vvalue=Off"
    calldomoticz(domoticzurl)

