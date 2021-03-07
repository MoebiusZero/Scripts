#console title
$host.ui.RawUI.WindowTitle = "PST Backup to Server - Version 1.1"

#a few variables
$user = $env:username

#Determine user location and take appropiate action
Clear
$GetIP = Get-WmiObject win32_networkadapterconfiguration | where { $_.ipaddress -like "1*" } | select -ExpandProperty ipaddress | select -First 1

                              
If ($GetIP -match "10.66.11") { [System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”) > $null
                                [System.Windows.Forms.MessageBox]::Show("The system has detected that you're currently connected through a wireless connection to the Main network. Due to the volatile nature of .PST files, we cannot condone making backups through such connections. If you are certain that you're on a wired connection, turn off Wireless and try again.", "Wireless Connection Detected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::WARNING)
                                stop-process -Id $PID
                              }
							  
If ($GetIP -match "10.23")    { [System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”) > $null 
                                [System.Windows.Forms.MessageBox]::Show("The system has detected that you're currently connected by VPN. Due to the volatile nature of .PST files and extremely slow upload speeds on consumer lines, we cannot condone making backups through such connections.", "VPN Connection Detected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::WARNING)
                                stop-process -Id $PID
                              }
							  
If ($GetIP -match "192") { [System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”) > $null
											                                    [System.Windows.Forms.MessageBox]::Show("The system has detected that you have no connection to the Main network. You're most likely on a network not managed by us, for example: Your home", "No connection to Main network", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::WARNING) 
											                                    stop-process -Id $PID
											                                  }
If ($GetIP -match "10.64.15") {
                                $Zutuser = Test-Path "\\fileserver\pst_files\$user"
                                If ($Zutuser -eq 'True') {
															$title = "PST Backup"
							                                $message = "Would you like to begin backing up your PST file?"
							                                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
							                                        "By selecting yes, the script will proceed as planned."
							                                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
							                                        "By selecting no, no backups will be made."

							                                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
							                                $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

							                                switch ($result)
							                                    {
							                                        0 {
							                                           Clear
							                                           Write-Host "Detecting LAN connection speed..." -Foregroundcolor Green
							                                           Write-Host ""
							                                           $Linkspeed = Get-WmiObject -Class Win32_NetworkAdapter | `Where {$_.Speed -eq '1000000000'}
							                                           Write-Host "Link Speed:" -Foregroundcolor Yellow
							                                           If ($Linkspeed -ne $null) { Write-host "Gigabit Link detected (1 Gb/s)"}
							                                           Else { Write-Host "Megabit link detected (100 Mb/s)" }
							                                           Write-Host ""
							                                           
							                                           Write-Host "Starting Slow Link Detection..." -Foregroundcolor Yellow
							                                           $Avg = 0
							                                           $Server = "servername"
							                                           $PingServer = Test-Connection -count 3 $Server
							                                           $Avg = ($PingServer | Measure-Object ResponseTime -average)
							                                           $avgping = [System.Math]::Round($Avg.average)
							                                           If ($avgping -ge '50') { Write-Warning "Slow Link detected, file transfer will not be optimal, transfer times will be increased" }
							                                           Else { "Network conditions are optimal, proceeding as planned" }

							                                                                      Write-Host ""
							                                                                      Write-host "Gathering all PST files on your system..." -Foregroundcolor Green
																								  Write-Host "This might take a minute or two..." -ForegroundColor Yellow
							                                                                          Get-ChildItem C:\users\$user *.pst -recurse -force 2>$NULL | Select-Object Name, @{Name="Megabyte";Expression={ "{0:N2}" -f ($_.Length / 1MB) }} 
							                                                                          $pstsize = "{0:N2}MB" -f ((gci -path c:\users\$user *.pst | Measure-Object length -Sum).Sum/ 1mb)
							                                                                                                                                                                                                                            
							                                                                                                 #Convert file size in bits
							                                                                                                 $pstdir = Get-ChildItem C:\users\$user *.pst -Recurse -force 2>$null  
							                                                                                                 $totalSize = ($pstdir| Measure-Object -Sum Length).Sum
							                                                                                                 $sizeinbits = $totalsize * 8
							                                                                                                 
							                                                                                                 #Convert network speed in BPS and add overhead
							                                                                                                 If ($linkspeed -ne $null) { $gigabit = 1000 * 1000 * 1000 }
							                                                                                                 Else { $megabit = 100 * 1000 * 1000 }
							                                                                                                 #Calculate overhead
							                                                                                                 If ($avgping -ge '50') { $gigaoverhead = $gigabit * 0.90
							                                                                                                                          $megaoverhead = $megabit * 0.90
							                                                                                                                          $totalgigaoverhead = $gigabit - $gigaoverhead
							                                                                                                                          $totalmegaoverhead = $megabit - $megaoverhead
							                                                                                                                        }
							                                                                                                 Else { $gigaoverhead = $gigabit * 0.80
							                                                                                                        $megaoverhead = $megabit * 0.80
							                                                                                                        $totalgigaoverhead = $gigabit - $gigaoverhead
							                                                                                                        $totalmegaoverhead = $megabit - $megaoverhead
							                                                                                                      }
							                                      
							                                                                                                 #With a bit of flour and a pinch of salt and add it to the mix
							                                                                                                 If ($Linkspeed -ne $null) { $timeinseconds = $sizeinbits / $totalgigaoverhead }
							                                                                                                 Else {  $timeinseconds = $sizeinbits / $totalmegaoverhead }
							                                                                                                 #Convert seconds to h:m:s
							                                                                                                 $mixed = New-TimeSpan -Seconds $timeinseconds
							                                                                                                 $ETA = '{0:00} Hours: {1:00} Minutes: {2:00} Seconds' -f $mixed.Hours,$mixed.Minutes,$mixed.Seconds
													                                                          				
																															 Write-Host ""
																															 Write-Host "Total Size: $pstsize"
																					  
							                                                           #Confirm Backup
							                                                           $title = "Estimated time determined, Continue?"
							                                                           $message = "Estimated time for transfer: $ETA"                                                                    
							                                                           $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `                                                                         
							                                                           $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `                                                                       
							                                                                 
							                                                           $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)                                                                     
							                                                           $zutbackup = $host.ui.PromptForChoice($title, $message, $options, 0)                                                                    
							                                                             
							                                                             switch ($backup)
							                                                                                                                               
							                                                                  {                                                                  
							                                                                     0 {                                                                   
							                                                                         Write-Host ""
																									 Write-Host "Starting backup of PST Files..." -ForegroundColor Green                                                                  
							                                                                         Robocopy C:\users\$user\ M:\ *.pst /xo /xf "$exclusion" | %{$data = $_.Split([char]9); if("$($data[4])" -ne "") { $file = "$($data[4])"} ;Write-Progress "Percentage $($data[0])" -Activity "Robocopy" -CurrentOperation "$($file)" -ErrorAction SilentlyContinue }                                                                    
							                                                                         Write-Host "Backup completed"
							                                                                         cmd /c pause                                                                   
							                                                                         stop-process -Id $PID                                                                   
							                                                                       }                                                                   
							                                                                     1 {                                                                  
							                                                                        Clear                                                                    
							                                                                        Write-Host "Ok, Will not be making backups today"                                                                    
							                                                                        Write-host "Have a nice day!"                                                                    
							                                                                        Write-Host "This Script close itself in..."                                                                    
							                                                                        Write-host "3" -Foregroundcolor Red                                                                    
							                                                                        Sleep 1                                                                    
							                                                                        Write-Host "2" -Foregroundcolor Red                                                                    
							                                                                        Sleep 1                                                                    
							                                                                        Write-Host "1" -Foregroundcolor Red                                                                    
							                                                                        Sleep 1                                                                    
							                                                                        stop-process -Id $PID                                                                    
							                                                                       }                                                                    
                                                                  							 }
																	 }                                                            
                                          1{
                                            Clear
                                            Write-Host "Ok, Will not be making backups today"
                                            Write-host "Have a nice day!"
                                            Write-Host "This Script close itself in..."
                                            Write-host "3" -Foregroundcolor Red
                                            Sleep 1
                                            Write-Host "2" -Foregroundcolor Red
                                            Sleep 1
                                            Write-Host "1" -Foregroundcolor Red
                                            Sleep 1
                                            stop-process -Id $PID
                                           }
										}
									}
                                Else {
                                [System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”) > $null
                                [System.Windows.Forms.MessageBox]::Show("The system has detected that you're currently in Gotham, but not stationed there. Due to the volatile nature of .PST files, we cannot condone making backups through great distances", "Gotham Network Detected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::WARNING)
                                stop-process -Id $PID
								     }}
									 
If ($GetIP -match "10.67.94") {
                                $Mostauser = Test-Path "\\otherfileserver\pst_files\$user"
                                If ($Mostauser -eq 'True') {
															$title = "PST Backup"
							                                $message = "Would you like to begin backing up your PST file?"
							                                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
							                                        "By selecting yes, the script will proceed as planned."
							                                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
							                                        "By selecting no, no backups will be made."

							                                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
							                                $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

							                                switch ($result)
							                                    {
							                                        0 {
							                                           Clear
							                                           Write-Host "Detecting LAN connection speed..." -Foregroundcolor Green
							                                           Write-Host ""
							                                           $Linkspeed = Get-WmiObject -Class Win32_NetworkAdapter | `Where {$_.Speed -eq '1000000000'}
							                                           Write-Host "Link Speed:" -Foregroundcolor Yellow
							                                           If ($Linkspeed -ne $null) { Write-host "Gigabit Link detected (1 Gb/s)"}
							                                           Else { Write-Host "Megabit link detected (100 Mb/s)" }
							                                           Write-Host ""
							                                           
							                                           Write-Host "Starting Slow Link Detection..." -Foregroundcolor Yellow
							                                           $Avg = 0
							                                           $Server = "servername"
							                                           $PingServer = Test-Connection -count 3 $Server
							                                           $Avg = ($PingServer | Measure-Object ResponseTime -average)
							                                           $avgping = [System.Math]::Round($Avg.average)
							                                           If ($avgping -ge '50') { Write-Warning "Slow Link detected, file transfer will not be optimal, transfer times will be increased" }
							                                           Else { "Network conditions are optimal, proceeding as planned" }

							                                                                      Write-Host ""
							                                                                      Write-host "Gathering all PST files on your system..." -Foregroundcolor Green
																								  Write-Host "This might take a minute or two..." -ForegroundColor Yellow
							                                                                          Get-ChildItem C:\users\$user *.pst -recurse -force 2>$NULL | Select-Object Name, @{Name="Megabyte";Expression={ "{0:N2}" -f ($_.Length / 1MB) }} 
							                                                                          $pstsize = "{0:N2}MB" -f ((gci -path c:\users\$user *.pst | Measure-Object length -Sum).Sum/ 1mb)
							                                                                                                                                                                                                                            
							                                                                                                 #Convert file size in bits
							                                                                                                 $pstdir = Get-ChildItem C:\users\$user *.pst -Recurse -force 2>$null  
							                                                                                                 $totalSize = ($pstdir| Measure-Object -Sum Length).Sum
							                                                                                                 $sizeinbits = $totalsize * 8
							                                                                                                 
							                                                                                                 #Convert network speed in BPS and add overhead
							                                                                                                 If ($linkspeed -ne $null) { $gigabit = 1000 * 1000 * 1000 }
							                                                                                                 Else { $megabit = 100 * 1000 * 1000 }
							                                                                                                 #Calculate overhead
							                                                                                                 If ($avgping -ge '50') { $gigaoverhead = $gigabit * 0.90
							                                                                                                                          $megaoverhead = $megabit * 0.90
							                                                                                                                          $totalgigaoverhead = $gigabit - $gigaoverhead
							                                                                                                                          $totalmegaoverhead = $megabit - $megaoverhead
							                                                                                                                        }
							                                                                                                 Else { $gigaoverhead = $gigabit * 0.80
							                                                                                                        $megaoverhead = $megabit * 0.80
							                                                                                                        $totalgigaoverhead = $gigabit - $gigaoverhead
							                                                                                                        $totalmegaoverhead = $megabit - $megaoverhead
							                                                                                                      }
							                                      
							                                                                                                 #With a bit of flour and a pinch of salt and add it to the mix
							                                                                                                 If ($Linkspeed -ne $null) { $timeinseconds = $sizeinbits / $totalgigaoverhead }
							                                                                                                 Else {  $timeinseconds = $sizeinbits / $totalmegaoverhead }
							                                                                                                 #Convert seconds to h:m:s
							                                                                                                 $mixed = New-TimeSpan -Seconds $timeinseconds
							                                                                                                 $ETA = '{0:00} Hours: {1:00} Minutes: {2:00} Seconds' -f $mixed.Hours,$mixed.Minutes,$mixed.Seconds
													                                                          				
																															 Write-Host ""
																															 Write-Host "Total Size: $pstsize"
																					  
							                                                           #Confirm Backup
							                                                           $title = "Estimated time determined, Continue?"
							                                                           $message = "Estimated time for transfer: $ETA"                                                                    
							                                                           $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `                                                                         
							                                                           $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `                                                                       
							                                                                 
							                                                           $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)                                                                     
							                                                           $mosbackup = $host.ui.PromptForChoice($title, $message, $options, 0)                                                                    
							                                                             
							                                                             switch ($backup)
							                                                                                                                               
							                                                                  {                                                                  
							                                                                     0 {                                                                   
							                                                                         Write-Host ""
																									 Write-Host "Starting backup of PST Files..." -ForegroundColor Green                                                                  
							                                                                         Robocopy C:\users\$user\ M:\ *.pst /xo /xf "$exclusion" | %{$data = $_.Split([char]9); if("$($data[4])" -ne "") { $file = "$($data[4])"} ;Write-Progress "Percentage $($data[0])" -Activity "Robocopy" -CurrentOperation "$($file)" -ErrorAction SilentlyContinue }                                                                    
							                                                                         Write-Host "Backup completed"
							                                                                         cmd /c pause                                                                   
							                                                                         stop-process -Id $PID                                                                   
							                                                                       }                                                                   
							                                                                     1 {                                                                  
							                                                                        Clear                                                                    
							                                                                        Write-Host "Ok, Will not be making backups today"                                                                    
							                                                                        Write-host "Have a nice day!"                                                                    
							                                                                        Write-Host "This Script close itself in..."                                                                    
							                                                                        Write-host "3" -Foregroundcolor Red                                                                    
							                                                                        Sleep 1                                                                    
							                                                                        Write-Host "2" -Foregroundcolor Red                                                                    
							                                                                        Sleep 1                                                                    
							                                                                        Write-Host "1" -Foregroundcolor Red                                                                    
							                                                                        Sleep 1                                                                    
							                                                                        stop-process -Id $PID                                                                    
							                                                                       }                                                                    
                                                                  							 }
																	 }                                                            
                                          1{ 
                                            Clear
                                            Write-Host "Ok, Will not be making backups today"
                                            Write-host "Have a nice day!"
                                            Write-Host "This Script close itself in..."
                                            Write-host "3" -Foregroundcolor Red
                                            Sleep 1
                                            Write-Host "2" -Foregroundcolor Red
                                            Sleep 1
                                            Write-Host "1" -Foregroundcolor Red
                                            Sleep 1
                                            stop-process -Id $PID
                                           }
										}
									}
                                Else {
                                [System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”) > $null
                                [System.Windows.Forms.MessageBox]::Show("The system has detected that you're currently in Central City, but not stationed there. Due to the volatile nature of .PST files, we cannot condone making backups through great distances", "Central City Network Detected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::WARNING)
                                stop-process -Id $PID
								     }}
									 
If ($GetIP -match "10.67.10") {
                                $Varsseuser = Test-Path "\\anotherone\pst_files\$user"
                                If ($Varsseuser -eq 'True') {
															$title = "PST Backup"
							                                $message = "Would you like to begin backing up your PST file?"
							                                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
							                                        "By selecting yes, the script will proceed as planned."
							                                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
							                                        "By selecting no, no backups will be made."

							                                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
							                                $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

							                                switch ($result)
							                                    {
							                                        0 {
							                                           Clear
							                                           Write-Host "Detecting LAN connection speed..." -Foregroundcolor Green
							                                           Write-Host ""
							                                           $Linkspeed = Get-WmiObject -Class Win32_NetworkAdapter | `Where {$_.Speed -eq '1000000000'}
							                                           Write-Host "Link Speed:" -Foregroundcolor Yellow
							                                           If ($Linkspeed -ne $null) { Write-host "Gigabit Link detected (1 Gb/s)"}
							                                           Else { Write-Host "Megabit link detected (100 Mb/s)" }
							                                           Write-Host ""
							                                           
							                                           Write-Host "Starting Slow Link Detection..." -Foregroundcolor Yellow
							                                           $Avg = 0
							                                           $Server = "servername"
							                                           $PingServer = Test-Connection -count 3 $Server
							                                           $Avg = ($PingServer | Measure-Object ResponseTime -average)
							                                           $avgping = [System.Math]::Round($Avg.average)
							                                           If ($avgping -ge '50') { Write-Warning "Slow Link detected, file transfer will not be optimal, transfer times will be increased" }
							                                           Else { "Network conditions are optimal, proceeding as planned" }

							                                                                      Write-Host ""
							                                                                      Write-host "Gathering all PST files on your system..." -Foregroundcolor Green
																								  Write-Host "This might take a minute or two..." -ForegroundColor Yellow
							                                                                          Get-ChildItem C:\users\$user *.pst -recurse -force 2>$NULL | Select-Object Name, @{Name="Megabyte";Expression={ "{0:N2}" -f ($_.Length / 1MB) }} 
							                                                                          $pstsize = "{0:N2}MB" -f ((gci -path c:\users\$user *.pst | Measure-Object length -Sum).Sum/ 1mb)
							                                                                                                                                                                                                                            
							                                                                                                 #Convert file size in bits
							                                                                                                 $pstdir = Get-ChildItem C:\users\$user *.pst -Recurse -force 2>$null  
							                                                                                                 $totalSize = ($pstdir| Measure-Object -Sum Length).Sum
							                                                                                                 $sizeinbits = $totalsize * 8
							                                                                                                 
							                                                                                                 #Convert network speed in BPS and add overhead
							                                                                                                 If ($linkspeed -ne $null) { $gigabit = 1000 * 1000 * 1000 }
							                                                                                                 Else { $megabit = 100 * 1000 * 1000 }
							                                                                                                 #Calculate overhead
							                                                                                                 If ($avgping -ge '50') { $gigaoverhead = $gigabit * 0.90
							                                                                                                                          $megaoverhead = $megabit * 0.90
							                                                                                                                          $totalgigaoverhead = $gigabit - $gigaoverhead
							                                                                                                                          $totalmegaoverhead = $megabit - $megaoverhead
							                                                                                                                        }
							                                                                                                 Else { $gigaoverhead = $gigabit * 0.80
							                                                                                                        $megaoverhead = $megabit * 0.80
							                                                                                                        $totalgigaoverhead = $gigabit - $gigaoverhead
							                                                                                                        $totalmegaoverhead = $megabit - $megaoverhead
							                                                                                                      }
							                                      
							                                                                                                 #With a bit of flour and a pinch of salt and add it to the mix
							                                                                                                 If ($Linkspeed -ne $null) { $timeinseconds = $sizeinbits / $totalgigaoverhead }
							                                                                                                 Else {  $timeinseconds = $sizeinbits / $totalmegaoverhead }
							                                                                                                 #Convert seconds to h:m:s
							                                                                                                 $mixed = New-TimeSpan -Seconds $timeinseconds
							                                                                                                 $ETA = '{0:00} Hours: {1:00} Minutes: {2:00} Seconds' -f $mixed.Hours,$mixed.Minutes,$mixed.Seconds
													                                                          				
																															 Write-Host ""
																															 Write-Host "Total Size: $pstsize"
																					  
							                                                           #Confirm Backup
							                                                           $title = "Estimated time determined, Continue?"
							                                                           $message = "Estimated time for transfer: $ETA"                                                                    
							                                                           $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `                                                                         
							                                                           $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `                                                                       
							                                                                 
							                                                           $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)                                                                     
							                                                           $varbackup = $host.ui.PromptForChoice($title, $message, $options, 0)                                                                    
							                                                             
							                                                             switch ($backup)
							                                                                                                                               
							                                                                  {                                                                  
							                                                                     0 {                                                                   
							                                                                         Write-Host ""
																									 Write-Host "Starting backup of PST Files..." -ForegroundColor Green                                                                  
							                                                                         Robocopy C:\users\$user\ M:\ *.pst /xo /xf "$exclusion" | %{$data = $_.Split([char]9); if("$($data[4])" -ne "") { $file = "$($data[4])"} ;Write-Progress "Percentage $($data[0])" -Activity "Robocopy" -CurrentOperation "$($file)" -ErrorAction SilentlyContinue }                                                                    
							                                                                         Write-Host "Backup completed"
							                                                                         cmd /c pause                                                                   
							                                                                         stop-process -Id $PID                                                                   
							                                                                       }                                                                   
							                                                                     1 {                                                                  
							                                                                        Clear                                                                    
							                                                                        Write-Host "Ok, Will not be making backups today"                                                                    
							                                                                        Write-host "Have a nice day!"                                                                    
							                                                                        Write-Host "This Script close itself in..."                                                                    
							                                                                        Write-host "3" -Foregroundcolor Red                                                                    
							                                                                        Sleep 1                                                                    
							                                                                        Write-Host "2" -Foregroundcolor Red                                                                    
							                                                                        Sleep 1                                                                    
							                                                                        Write-Host "1" -Foregroundcolor Red                                                                    
							                                                                        Sleep 1                                                                    
							                                                                        stop-process -Id $PID                                                                    
							                                                                       }                                                                    
                                                                  							 }
																	 }                                                            
                                          1{ 
                                            Clear
                                            Write-Host "Ok, Will not be making backups today"
                                            Write-host "Have a nice day!"
                                            Write-Host "This Script close itself in..."
                                            Write-host "3" -Foregroundcolor Red
                                            Sleep 1
                                            Write-Host "2" -Foregroundcolor Red
                                            Sleep 1
                                            Write-Host "1" -Foregroundcolor Red
                                            Sleep 1
                                            stop-process -Id $PID
                                           }
										}
									}
                                Else {
                                [System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”) > $null
                                [System.Windows.Forms.MessageBox]::Show("The system has detected that you're currently in Metropolis, but not stationed there. Due to the volatile nature of .PST files, we cannot condone making backups through great distances", "Metropolis Network Detected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::WARNING)
                                stop-process -Id $PID
								     } }