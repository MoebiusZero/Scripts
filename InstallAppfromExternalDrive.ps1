#Find EXTERNALDISK drive and set variables
$Volumename = 'EXTERNALDISK'

$Connecteddrive = $null
get-wmiobject win32_logicaldisk | % {
    if ($_.VolumeName -eq $VolumeName) {
        $Connecteddrive = $_.DeviceID
    }
}
if ($Connecteddrive -eq $null) {
    throw "$VolumeName drive not found! Check if the drive is connected."
}

$localhost = $env:computername

Write-Host
Write-host "______________________________________________________________________________"
Write-Host "Starting installation of Trueview 2014"
$passy = convertto-securestring '(password)' -asplaintext -force
$creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $localhost\Ecosetup,$passy

#Detect Architecture and Install
$ARCH = $ENV:Processor_Architecture
IF ($ARCH -eq "x86") {
                      Write-Host "$localhost is a 32-bit computer, installing 32-bit version..."
                      $true86exit = (Start-Process -filepath "$connecteddrive\TOOLS\Autodesk Trueview 2014\x86\Combine with Remote Installer\setup.exe" -Argumentlist "/q /w" -Credential $creds -Wait -PassThru).ExitCode
                             IF ($true86exit -eq 0) {
                                                       Sleep 10 
                                                       Write-Host "Autodesk Trueview 2014 x86 installed succesfully"
                                                     }
                                                     Else
                                                    {
                                                     Sleep 10
                                                     Write-Host "Installation Failed, try installing it manually"
                                                    }
                                         
                          }
ELSE   {

                      Write-Host "$localhost is a 64-bit computer, installing 64-bit version..."
                      $true64exit = (Start-Process -filepath "$connecteddrive\TOOLS\Autodesk Trueview 2014\x64\setup.exe" -Argumentlist "/q /w" -Credential $creds -Wait -PassThru).ExitCode
                                IF ($true64exit -eq 0) {
                                                       Sleep 10 
                                                       Write-Host "Autodesk Trueview 2014 x64 installed succesfully"
                                                     }
                                                     Else
                                                    {
                                                     Sleep 10
                                                     Write-Host "Installation Failed, try installing it manually"
                                                    }
                                         
       }
 
 