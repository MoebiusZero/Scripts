$content = @' 
$loggedonuser = Get-WMIObject -class Win32_ComputerSystem | Select-Object -ExpandProperty username 
Add-LocalGroupMember -Group 'Network Configuration Operators' -Member $loggedonuser 
'@ 

# create custom folder and write PS script 
$path = $(Join-Path $env:ProgramData \Scripts) 
if (!(Test-Path $path)) 
{ 
New-Item -Path $path -ItemType Directory -Force -Confirm:$false 
} 
Out-File -FilePath $(Join-Path $env:ProgramData \Scripts\addtogroup.ps1) -Encoding unicode -Force -InputObject $content -Confirm:$false 
  
# register script as scheduled task 
$loggedonuser = Get-WMIObject -class Win32_ComputerSystem | Select-Object -ExpandProperty username 
$Time = New-ScheduledTaskTrigger -AtLogOn 
$User = $loggedonuser 
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ex bypass -file `"C:\ProgramData\Scripts\addtogroup.ps1`"" 
Register-ScheduledTask -TaskName "AddUserToNetworkOperatorGroup" -Trigger $Time -User $User -Action $Action -Force 