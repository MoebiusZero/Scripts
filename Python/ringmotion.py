from ring_doorbell import Ring, Auth
from time import sleep
from oauthlib.oauth2 import MissingTokenError
from pathlib import Path
import os
import urllib.request as urllib2
import json
import shutil

from datetime import datetime

username='ringusername'
password='ringpassword!'
cache_file = Path('token.cache')

def token_updated(token):
    f=open('token.cache', "w")
    f.write(json.dumps(token))
    f.close()

def otp_callback():
    auth_code = '763502'
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

# Now loop infinitely
while(1):
	#Stop processing if there are no doorbell dings to process
	if not doorbell.history(limit=1,kind='motion'):
		print('EMPTY')

	else:
		for event in doorbell.history(limit=1, kind='motion'):
			now = datetime.now()
			today = now.strftime("%d-%m-%y")
			timestamp = now.strftime("%d-%m-%Y %H:%M:%S")
			storagepath = '/mnt/RingSecurity/Motion/'
			videolocation = storagepath + today + '/'
			videofile = videolocation + 'lastmotion_' + timestamp + '.mp4'
			checkfolder = os.path.exists(storagepath + today)

		if not checkfolder:
			os.makedirs(storagepath + today)

		#File containg the video ID
		fileid = "/home/username/ringmotion_ID"

		for doorbell in devices['doorbots']:
			for event in doorbell.history(limit=1, kind='motion'):
				rawid = event['id']
				id = (str(rawid))

		#Get the stored video file ID
		file = open(fileid, "r")
		storedid = (file.readline())
		#Compare the stored video file ID with the one from the API
		if id != storedid:
			file = open(fileid, "w")
			file.write(str(id))
			file.close()

			sleep(60)
			doorbell.recording_download(
			doorbell.history(limit=100, kind='motion')[0]['id'],
				filename=videofile,
				override=False)
else:
	sleep(5)
