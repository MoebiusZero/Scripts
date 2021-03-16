from ring_doorbell import Ring, Auth
from time import sleep
from oauthlib.oauth2 import MissingTokenError
from pathlib import Path
import os
import urllib.request as urllib2
import json

from datetime import datetime

username='ringaccount'
password='passwordring'
cache_file = Path('token.cache')

def token_updated(token):
    f=open('token.cache', "w")
    f.write(json.dumps(token))
    f.close()

def otp_callback():
    auth_code = '2facodehere'
    return auth_code


if cache_file.is_file():
    f=open('token.cache', "r")
    auth = Auth("DomoticzDoorbell/1.0", json.loads(f.read()), token_updated)
    f.close()
else:
    auth = Auth("DomoticzDoorbell/1.0", None, token_updated)
    try:
        auth.fetch_token(username, password)
    except MissingTokenError:
        auth.fetch_token(username, password, otp_callback())

myring = Ring(auth)
myring.update_data()
devices = myring.devices()
doorbells = devices['doorbots']
doorbell = doorbells[0]

def domoticzrequest (url):
  request = urllib2.Request(url)
  response = urllib2.urlopen(request)
  return response.read()

# Now loop infinitely
while(1):
 myring.update_dings()
 if myring.active_alerts() != []:
   print(myring.active_alerts())

   #Download last ding video
   now = datetime.now()
   today = now.strftime("%d-%m-%y")
   timestamp = now.strftime("%d-%m-%Y %H:%M:%S")
   storagepath = '/mnt/RingSecurity/Ding/'
   videolocation = storagepath + today + '/'
   videofile = videolocation + 'lastding_' + timestamp + '.mp4'
   checkfolder = os.path.exists(storagepath + today)

   if not checkfolder:
      os.makedirs(storagepath + today)

   sleep(80)
   doorbell.recording_download(
   doorbell.history(limit=1, kind='ding')[0]['id'],
                       filename=videofile,
                       override=False)

 # Loop around
 sleep(4)

