####Notification script for when new users have been assigned a new device####
##############################################################################

#Check if the necessary tools have been installed
$checkinstall = Get-Module -ListAvailable -name Microsoft.Graph.Intune

if ($checkinstall -ne $null) {
    Write-Host "Module found, proceeding..."
}
elseif ($checkinstall -eq $null) {
    Write-Host "Module not found, installing..."
    Install-module -name Microsoft.Graph.Intune
}

#Prepare credentials
    #Intune management
    $username = "admin"
    $password = Get-Content 'C:\Scripts\EnrolledDeviceNotification\root' | ConvertTo-SecureString
    $credentials = New-Object System.Management.Automation.PsCredential($username, $password)

#Connect to the MSGraph Service
Connect-MSGraph -Credential $credentials

#Get a list of all devices that have been enrolled today
$devices = Get-IntuneManageddevice | Select-Object userDisplayname,deviceName,Serialnumber,operatingSystem,model,manufacturer,phoneNumber,subscriberCarrier,imei,emailAddress

#Import the list of current owned devices
$currentdevices = Import-Csv C:\Scripts\EnrolledDeviceNotification\Data\currentlist.csv

#Create a new up to date list of current owned devices
$devices | Export-Csv C:\Scripts\EnrolledDeviceNotification\Data\updatedlist.csv -NoTypeInformation

#Import the up to date list
$newcurrentdevices = Import-Csv C:\Scripts\EnrolledDeviceNotification\Data\updatedlist.csv

#Compare the two lists and generate a list of which users to notify
$gennotificationlist = Compare-Object $newcurrentdevices $currentdevices -property userDisplayname,Serialnumber -Pass | Export-Csv "C:\Scripts\EnrolledDeviceNotification\Data\notificationlist.csv" -NoTypeInformation
$notifyusers = Import-Csv C:\Scripts\EnrolledDeviceNotification\Data\notificationlist.csv

ForEach ($user in $notifyusers) {
        #Generate a date
        $today = Get-Date -format dd-MM-yyyy

        #Fill in the data variables
        $serialnumber = $user.serialNumber
        $deviceowner = $user.userDisplayName
        $model = $user.model
        $carrier = $user.subscriberCarrier
        $phonenumber = $user.phoneNumber
        $imei = $user.imei
        $devicename = $user.deviceName
        $useremail = $user.emailAddress
        $os = $user.operatingSystem

        #Send an Email to the user to confirm assignment
        #Check for the type of device
        $windowmachine = $false
        $iOSmachine = $false

        if ($os -eq "Windows") {
            $windowsmachine = $true
            }

        if ($os -eq "iOS") {
            $iOSmachine = $true
        }

        #Generate the Subject
        if ($windowsmachine -eq $true) {
            $subject = "Er is een " + $user.model + " " + "assigned to " + $user.userDisplayName
        }
        elseif ($iOSmachine -eq $true) {
            $subject = "Er is een " + $user.model + " " + "assigned to " + $user.userDisplayName
        }      

       #Generate the body
        if ($windowsmachine -eq $true) {
            $body = "<h1>Welcome " + $deviceowner + "</h1>"
            $body += "You recieved a new device on<b>$today</b><br><br>"
            $body += "Please take good care of it"
            
        }
        
        if ($iOSmachine -eq $true) {
            $body = "<h1>Welcome " + $deviceowner + "</h1>"
            $body += "You received a new mobile phone on <b>$today</b><br><br>"            
            $body += "try not to drop it"
        }

        #Look for the user's signed agreement if there is one
        $name = $useremail.Split("@")[0]
        $convertname = $name.insert(2," ")
        $agreementlookup = Get-ChildItem -Path "(file location)" -Filter "(filename.pdf)" -Recurse -Force
        $agreementfile = $agreementlookup.fullname
        
        $mailParams = @{ 
            smtpserver       = "(SMTP Server)" 
            Port             = "25"
            UseSSL           = $true
            From             = "fromemail" 
            To               = $useremail    
            CC               = "CCemail" # Or @("ccemail1", "ccemail2") if you have more people that need to be notified
            Subject          = $subject
            Body             = $body  
            Attachments      = $agreementfile
            BodyAsHtml       = $true
        }

        #Remove the Attachment parameter if there is no attachment
        if ($agreementfile -eq $null) {
            $mailparams.Remove("Attachments")
        }

Send-MailMessage @mailParams
}

#Cleanup
Remove-Item C:\Scripts\EnrolledDeviceNotification\Data\updatedlist.csv
Remove-Item C:\Scripts\EnrolledDeviceNotification\Data\notificationlist.csv

#Update the user list
$devices | Export-Csv C:\Scripts\EnrolledDeviceNotification\Data\currentlist.csv -NoTypeInformation