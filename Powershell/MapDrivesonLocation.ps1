#console title
$host.ui.RawUI.WindowTitle = "Map Network Drives - Version 1.1"

#Get current logged in username and set to variable
$loginname = $env:username

Write-Host "Determining your Personal and PST Archive location..." -ForegroundColor Green
#Get users from each location
dsget group "(LDAP PATH HERE)" -members -expand | dsget user -samid > .\group1.txt
dsget group "(LDAP PATH HERE)"  -members -expand | dsget user -samid > .\group2.txt
dsget group "(LDAP PATH HERE)"  -members -expand | dsget user -samid > .\group3.txt

#Start determining where user is stationed
$group1user = Select-string -path .\group1.txt -pattern $loginname -AllMatches 
If ($group1user -Match $loginname) {
                                      #Check for existing drives and delete them
									  $group1P = Test-Path P:
									  If ($group1P -eq "True") { net use P: /delete > $null }
									  $group1M = Test-Path M:
									  If ($group1M -eq "True") { net use M: /delete > $null }
									  $MandatoryG = Test-Path G:
									  If ($MandatoryG -eq "True") { net use G: /delete > $null }
									  $MandatoryI = Test-Path I:
									  If ($MandatoryI -eq "True") { net use I: /delete > $null }
									  $MandatoryV = Test-Path V:
									  If ($MandatoryV -eq "True") { net use V: /delete > $null }
									                                      
                                      #Start mapping user home & PST
									  Write-Host "You are stationed in Metropolis, Mapping drives..." -ForegroundColor Yellow
                                      net use P: \\server\user_home\$loginname  > $null
                                      net use M: \\server\pst_files\$loginname  > $null
                                    }

$group2user = Select-string -path .\group2.txt -pattern $loginname -AllMatches
If ($group2user -match $loginname) {
									  #Check for existing drives and delete them
                                      $group2P = Test-Path P:
									  If ($group2P -eq "True") { net use P: /delete > $null }
									  $group2M = Test-Path M:
									  If ($group2M -eq "True") { net use M: /delete > $null }
									  $MandatoryG = Test-Path G:
									  If ($MandatoryG -eq "True") { net use G: /delete > $null }
									  $MandatoryI = Test-Path I:
									  If ($MandatoryI -eq "True") { net use I: /delete > $null }
									  $MandatoryV = Test-Path V:
									  If ($MandatoryV -eq "True") { net use V: /delete > $null }

                                      #Start mapping user home & PST
									  Write-Host "You are stationed in Gotham, Mapping drives..." -ForegroundColor Yellow
                                      net use P: \\server\shares\user_home\$loginname > $null
                                      net use M: \\server\shares\pst_files\$loginname > $null
                                    }

$group3user = Select-string -path .\group3.txt -pattern $loginname -AllMatches
If ($group3user -match $loginname) {
                                      #Check for existing drives and delete them
									  $group3P = Test-Path P:
									  If ($group3P -eq "True") { net use P: /delete > $null }
									  $group3M = Test-Path M:
									  If ($group3M -eq "True") { net use M: /delete > $null }
									  $MandatoryG = Test-Path G:
									  If ($MandatoryG -eq "True") { net use G: /delete > $null }
									  $MandatoryI = Test-Path I:
									  If ($MandatoryI -eq "True") { net use I: /delete > $null }
									  $MandatoryV = Test-Path V:
									  If ($MandatoryV -eq "True") { net use V: /delete > $null }

                                      #Start mapping user home & PST
									  Write-Host "You are stationed in Central City, Mapping drives..." -ForegroundColor Yellow
                                      net use P: \\server\user_home\$loginname  > $null
                                      net use M: \\server\PST_FILES\$loginname  > $null
                                    }
                                    
#Default drives to be mapped to everyone
Write-Host "Adding remaining Data drives..." -ForegroundColor Yellow
net use G: \\server\data  > $null
net use I: \\server\data  > $null
net use V: \\server\shares\data  > $null

#Clean up
Remove-item .\group1.txt
Remove-item .\group2.txt
Remove-item .\group3.txt

Write-Host "_______________________________________________________________________"
Write-Host "All Drives have been mapped, if this is not the case, contact Local IT" -ForegroundColor Green
Write-Host "This will screen will automatically close in 5 seconds" -ForegroundColor Green
Sleep 5
stop-process -Id $PID 
