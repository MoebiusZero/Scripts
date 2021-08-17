#Create log file
$datetoday = (Get-Date).ToString("dd-MM-yyyy")
$logfile = "C:\Users\$env:username\Desktop\MassUserAdd_Secgroups-$datetoday.txt"
$testlogfile = Test-Path $logfile
if ($testlogfile -eq $false) { 
    New-item "C:\Users\$env:username\Desktop\MassUserAdd_Secgroups-$datetoday.txt" -ItemType "File" 
} 

#Import the AD module
Import-Module ActiveDirectory

#Get a list of all existing groups in AD and ask user which group the users need to be added to
cls
Write-Host "Fetching list of all exiting Security Groups..." -BackgroundColor Black -ForegroundColor Green
$groups = Get-ADGroup -Filter{GroupCategory -eq "Security"}
$groups.name 
Write-Host "Take note of the exact name of the group you want the users to be added to" -BackgroundColor Black -ForegroundColor Green
$groupname = Read-Host "Now enter the name of the group you want the users to be added to" 

#Import the list with users, ask the user where the file is
try {
    $file = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
    $null = $file.ShowDialog()
} catch { 
    $datetimetoday = (Get-Date).ToString("dd-MM-yyyy hh:mm:ss")
    "$datetimetoday : User Canceled Operation" >> $logfile
} 
$users = Get-Content $file.Filename 

#Add each user in the list to a group
try {
    foreach ($user in $users) { 
        Add-ADGroupMember -Identity $groupname -Members $user 
        $datetimetoday = (Get-Date).ToString("dd-MM-yyyy hh:mm:ss")
        "$datetimetoday : $user added to $groupname" >> $logfile
    } 
} catch {
    $datetimetoday = (Get-Date).ToString("dd-MM-yyyy hh:mm:ss")
    "$datetimetoday : Unable to add $user to $groupname" >> $logfile
    "$datetimetoday : $error[0].Exception.Message" >> $logfile 
} 

#Get Up-to-Date list of the members of the group
Write-Host "These are now the members of $groupname" 
(Get-ADGroupMember $groupname).name