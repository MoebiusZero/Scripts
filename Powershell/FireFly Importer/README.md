# FireFly Auto Importer
Uses Invoke-WebRequest to send a POST request to the FireFly Auto importer so you can schedule the automatic imports of your transactions.
This is assuming you either configured your importer to use Nordigen or Spectre. I use Nordigen myself, but the steps should be the same for Spectre.

Made this in Powershell because I already have a server dedicated to automation based on Windows and didn't want to have scripts lying around everywhere.
The examples provided by the FireFly documentation uses curl, but Invoke-WebRequest is pretty much it's equivilent for Windows.

## Requires Powershell 7!
You need to download Powershell 7 and install it before this script can be used. This is because the -Form parameter doesn't exist in the previous versions. 
Don't worry, Powershell 7 and 5 can co-exist. 

## Create a configuration file for use
It's easier to have a JSON file generated by the importer for the first time so you can don't have to do a whole bunch of manual work.
Simply go to http://<importerIP:port> and import with your provider. At the end download the configuration file. 

## Create the Docker Container
You will also need to configure your importer with a secret and allow POST requests to it. I've made a simple .env and docker-compose.yml file for this you can download and use. 
You need to add a few values in the .env file to make it work
- **FIREFLY_III_URL:** Enter the URL of your Firefly instance with portnumber if needed
- **FIREFLY_III_ACCESS_TOKEN:** You can generate this in FireFly under Options > Profile > OAuth tab and create a new token under Personal Access Tokens. Copy the token here
- **NORDIGEN_ID and NORDIGEN_KEY / SPECTRE_APP_ID and SPECTRE_SECRET:** These are gotten from their respective providers you can copy the values here
- **AUTO_IMPORT_SECRET:** Make up your own secret, could be a password or something randomly generated, you need this so the POST request can authenticate
- **CAN_POST_AUTOIMPORT:** This needs to be set to True, otherwise you will get an error during POST that autoimport through POST is disabled
- **CAN_POST_FILES:** Needs to be set to True as well, for the same reason as above

To make the container, create a new folder in your docker server, copy the .env and docker-compose.yml files into it and navigate to the folder. Then run **sudo docker-compose up -d** to create it. 

## Configure the Script
There are only a few changes you need to make. The locations for the JSON file and the temporary file with the output from the POST request. 

If you want e-mail you can configure the $mailmessage values as well. If not you can completely remove the Send E-mail report block. 

I'm fully aware Send-Mailmessage is deprecated, but I personally use this internally with so I'm pretty much ok with using it. 

## Automation
You basically create a task scheduler for this in Windows. Because Powershell 7 is required, you will need to the scheduler to look for the Powershell 7 executable, using simply powershell defaults it to version 5. 
Simply enter this: "C:\Program Files\PowerShell\7\pwsh.exe" as the program path, assuming you used the default installation settings.
The parameters you use are identical -file "C:\scripts\myscript.ps1" for example

You can run this every minute, hour, days. But keep in mind the API limitations of Nordigen or Spectre. Last thing you want is hitting it. Personally I run it every 6 hours. I don't need my bookkeeping updated in real time.