#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Setup
DOMOTICZ_SERVER="serverip:portnumber"	# IPAddress:Port of Domoticz Server

# No need to edit below here.
echo "Start running backup script."

TIMESTAMP=`/bin/date +%d-%m-%Y`

# Create temp-directory if it does not already exists.
TEMP_DIR="/home/pi/temp"

if [ -d $TEMP_DIR ] ; then
    echo "- Temp-directory already exists, no need to create it."
else
    echo "- Temp-directory does not exists, creating it now."
    /bin/mkdir $TEMP_DIR
fi

# Create backup file for database.
echo "- Creating backup file for database."
BACKUP_DB=$TIMESTAMP"_db.db"
BACKUP_DB_GZ=$BACKUP_DB".gz"
/usr/bin/curl -s http://$DOMOTICZ_SERVER/backupdatabase.php > $TEMP_DIR/$BACKUP_DB

gzip -9 $TEMP_DIR/$BACKUP_DB

# Create backup file for scripts directory.
echo "- Creating backup file for scripts directory."
BACKUP_SCRIPTS=$TIMESTAMP"_scripts.tar.gz"
tar -zcf $TEMP_DIR/$BACKUP_SCRIPTS /home/pi/domoticz/scripts/

# Create backup file for crontab.
echo "- Creating backup file for crontab."
BACKUP_CRONTAB=$TIMESTAMP"_crontab.txt"
crontab -l > $TEMP_DIR/$BACKUP_CRONTAB

# Send backup files to FTP or SFTP location.
	echo "Sending backup files to Backup server..."
	mkdir /mnt/Backup/$TIMESTAMP
	cp $TEMP_DIR/* /mnt/Backup/$TIMESTAMP

# Remove temp backup file
#echo "- Removing temp files."
/bin/rm $TEMP_DIR/$BACKUP_DB_GZ
/bin/rm $TEMP_DIR/$BACKUP_SCRIPTS
/bin/rm $TEMP_DIR/$BACKUP_CRONTAB
