param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("install", "uninstall")]
    [string]$Installmode
)

Clear-Host
Write-Host "Setting Arguments"
$StartDTM = (Get-Date)

$Vendor    = "<vendorname>"
$Package   = "<package name>"
$Version   = "<versionnumber>"
$LogPS     = "$($env:TEMP)\$($Vendor) $($Package) $($Version) PS Wrapper.log"
$LogApp    = "$($env:TEMP)\$($Vendor) $($Package) $($Version) Installer.log"
# msi arguments
$Arguments = "/i installer.msi /qn /norestart"
$ProgressPreference = 'Continue'
$pathFolder = "C:\ProgramData\<logfoldername>\"	

Start-Transcript $LogPS | Out-Null

Write-Host "Showing all environment variables"
Get-ChildItem env:* | Sort-Object Name

Write-Host "Pre-requisites"

Write-Host "Starting Installation of $($Vendor) $($Package) $($Version)"

function Install-Application {
    Write-Host "Starting Installation of $($Vendor) $($Package) $($Version)"
    (Start-Process "msiexec.exe" $Arguments -Wait -Passthru).ExitCode

    # Create log folder
    if(Test-Path -Path $pathFolder){
          Write-Host "Folder already exists."
    }
    else{
          New-Item -Path $pathFolder -ItemType Directory 
          Write-Host "Folder created successfully."
    }

    Remove-Item -Path "$($env:ProgramData)\BBA\$($Vendor) $($Package) v*.txt" -Force
    "$($Vendor) $($Package) installed" | Out-File -FilePath "$($env:ProgramData)\BBA\$($Vendor) $($Package) v$($Version).txt"
}

function Uninstall-Application {
    Remove-Item -Path "$($env:ProgramData)\BBA\$($Vendor) $($Package) v*.txt" -Force
    $appcheck = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -like "*$package*" } | Select-Object -Property DisplayName,UninstallString
    $uninst = $appcheck.UninstallString
    $uninst = (($uninst -split ' ')[1] -replace '/I','/X') + ' /q'
    (Start-Process "msiexec.exe" -Argumentlist $uninst -wait -PassThru).ExitCode
}

if ($Installmode -eq "install") {
    Install-Application
} elseif ($Installmode -eq "uninstall") {
    Uninstall-Application
} else {
    Write-Host "Invalid action. Use -Installmode install or -Installmode uninstall."
}

Write-Host "Stop logging"
$EndDTM = (Get-Date)
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript