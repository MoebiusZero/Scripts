$VM = Read-Host "Enter the Name of the VM to remove the GPU from"

#Removes the GPU from the VM 
$unassignedGPU = Get-PnpDevice -PresentOnly | Where-Object {$_.Class -eq “System” -AND $_.FriendlyName -like “PCI Express Graphics Processing Unit – Dismounted”} 

$LocationunassignedGPU = ($unassignedGPU[0] | Get-PnpDeviceProperty DEVPKEY_Device_LocationPaths).data[0] 

Remove-VMAssignableDevice -LocationPath $LocationPathOfDismountedDA -VMName $VM

Do { 
    $backtohost = Read-Host "Do you want ot assign the GPU back to the Hyper-V Host? If you want to re-assign the GPU to another VM, please select N (y/n)"
    switch ($backtohost) { 
        "y" {
                Write-Host "Assigning GPU back to Host..."
                Mount-VmHostAssignableDevice -locationpath $LocationunassignedGPU 
                $myGPU = Get-PnpDevice -PresentOnly| Where-Object {$_.Class -eq “Display”} | Where-Object {$_.status -eq "Error"} 
                Enable-PnpDevice -InstanceId $myGPU[0].InstanceId -Confirm:$false 
                Set-VM $VM -GuestControlledCacheTypes $False -LowMemoryMappedIoSpace 256MB -HighMemoryMappedIoSpace 512MB 
        }
        "n" {   
                Set-VM $VM -GuestControlledCacheTypes $False -LowMemoryMappedIoSpace 256MB -HighMemoryMappedIoSpace 512MB 
                Write-Host "GPU has been unassigned from $VM, you are free to assign it to another VM now"}
        } 
} 
While ($backtohost -ne "y" -or "n")