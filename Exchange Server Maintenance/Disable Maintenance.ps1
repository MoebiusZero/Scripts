###Disable maintenance mode on Exchange servers after successfully updating
###Only applicable to DAG environments!

#Add the Exchange server powershell Module
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Snapin

#Ask for the server which is being serviced
$servicedserver = Read-Host -Prompt 'Input the servername that was serviced'

#Ask for the server which will take over the transport roles
$takeoverserver = Read-Host -Prompt 'Input the servername that took over'

Write-Host 'Disabling Maintenance Mode on' $servicedserver'...'

#Activate the server
""
Write-Host 'Activating server...'
Set-ServerComponentState $servicedserver -Component ServerWideOffline -State Active -Requester Maintenance

#Unsuspend the Server
""
Write-Host 'Unsuspending the server...'
Resume-ClusterNode -Name "$servicedserver"

#Set Auto Activation policy back to Unrestricted
""
Write-Host 'Unrestricting Auto Activation Policy...'
Set-MailboxServer $servicedserver -DatabaseCopyAutoActivationPolicy Unrestricted

#Enable Database Copy Protection
""
Write-Host 'Enabling Database Copy Protection...'
Set-MailboxServer $servicedserver -DatabaseCopyActivationDisabledAndMoveNow $false

#Restore Hubtransporter
""
Write-Host 'Restoring Hub Transporter...'
Set-ServerComponentState $servicedserver -Component HubTransport -State Active -Requester Maintenance
""
Write-Host 'Procedure completed!'
Write-Host 'Start testing all Exchange Servers if all functionality is restored!'
cmd /c pause