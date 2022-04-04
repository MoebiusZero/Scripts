from ring_doorbell import Ring, Auth
from time import sleep
from oauthlib.oauth2 import MissingTokenError
from pathlib import Path
import os
import urllib.request as urllib2
import json

from datetime import datetime

username='ringusername'
password='ringpassword'
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

#Ring API variables
myring = Ring(auth)
myring.update_data()
devices = myring.devices()
doorbell = devices['doorbots'][0]

while(1):
	sleep(10)

	#Stop processing if there are no doorbell dings to process
	if not doorbell.history(limit=2,kind='ding'):
		print('EMPTY')

	else:
		#Time/date variables
		now = datetime.now()
		today = now.strftime("%d-%m-%y")
		timestamp = now.strftime("%d-%m-%Y %H:%M:%S")

		#Video storage variables
		storagepath = '/mnt/RingSecurity/Ding/'
		videolocation = storagepath + today + '/'
		videofile = videolocation + 'lastding_' + timestamp + '.mp4'

		#Check if the location contains a folder with the date of today else create one
		checkfolder = os.path.exists(storagepath + today)
		if not checkfolder:
			os.makedirs(storagepath + today)

		#file containing the video ID
			fileid = "/home/username/ringdoorbell_ID"
			for doorbell in devices['doorbots']:
				for event in doorbell.history(limit=2, kind='ding'):
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

				#Download the video
				doorbell.recording_download(
				doorbell.history(limit=100, kind='ding')[0]['id'],
					filename=videofile,
					override=True)
else:
	sleep(5)
