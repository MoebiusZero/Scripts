###################
Write-Host "This tool will change the default KMS server (Microsoft) to a private hosted one with set keys to always activate your system"
Write-Host "This does not disable the ability to use legal keys in the future"

#Get Windows Version that is installed
$installedwindows = (Get-CimInstance Win32_OperatingSystem).Caption
Write-Host "Getting installed Windows edition..."
Write-Host "Found: $installedwindows"

#Serial keys
#Windows Server 2019
$server2019DC = "WMDGN-G9PQG-XVVXX-R3X43-63DFG"
$server2019std = "N69G4-B89J2-4G8F4-WWYCC-J464C"
$server2019ess = "WVDHN-86M7X-466P6-VHXV7-YY726"

#Windows Server 2016
$server2016DC = "CB7KF-BWN84-R7R2Y-793K2-8XDDG"
$server2016std = "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY"
$server2016ess = "JCKRF-N37P4-C2D82-9YXRT-4M63B"

#Windows Server 2012 R2
$server2012r2DC = "W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9"
$server2012r2std = "D2N9P-3P6X9-2R39C-7RTCD-MDVJX"
$server2012r2ess = "KNC87-3J2TX-XB4WP-VCPJV-M4FWM"


#Windows 10 2019
$10pro = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
$10proN = "MH37W-N47XK-V7XM9-C7227-GCQG9"
$10edu = "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"
$10ent = "NPPR9-FWDCX-D2C8J-H872K-2YT43"


#Select proper key
switch ($installedwindows)
    { 
        "Microsoft Windows 10 Enterprise" { $serialkey = $10ent } 
        "Microsoft Windows 10 Pro" { $serialkey = $10pro } 
        "Microsoft Windows 10 Pro N" { $serialkey = $10proN } 
        "Microsoft Windows 10 Pro Education" { $serialkey = $10edu }
        "Microsoft Windows Server 2012 R2 Standard" { $serialkey = $server2012r2std } 
        "Microsoft Windows Server 2012 R2 Datacenter" { $serialkey = $server2012r2DC} 
        "Microsoft Windows Server 2012 R2 Essentials" { $serialkey = $server2012r2ess} 
        "Microsoft Windows Server 2016 Standard" { $serialkey = $server2016std } 
        "Microsoft Windows Server 2016 Essentials" { $serialkey = $server2016ess} 
        "Microsoft Windows Server 2016 Datacenter" { $serialkey = $server2016DC} 
        default {"Current OS: $installedwindows, is sadly not supported in this tool. Please contact the developer"; break} 
    } 

if ( $serialkey -ne $null ) { 
#Activate Windows
slmgr.vbs -ipk  $serialkey
slmgr.vbs -skms kms.srv.crsoo.com
slmgr.vbs -ato
Write-Host -NoNewLine 'Windows has been succesfully activated! Press any key to exit...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
cmd /c 
} 
else {
Write-Host -NoNewLine 'Press any key to exit...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

#Activate Windows
slmgr.vbs -ipk  $serialkey
slmgr.vbs -skms kms.srv.crsoo.com
slmgr.vbs -ato