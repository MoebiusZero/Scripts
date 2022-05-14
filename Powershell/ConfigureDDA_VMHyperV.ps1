#Dismount GPU for use with VM Passthrough
Get-VM | Select-Object Name, Status
$VM = Read-Host "Enter the Name of VM to assign the GPU to"
Write-Host "How much memory does the GPU support? Entering wrong values will still probally make the passthrough work, but you might encounter performance issues"
$GPUmem = Read-Host "Enter the amount in MBs (ex. 2000, 3000, 4096)"
$minGPUmem = $GPUmem / 2

#Configure the VM to prepare for GPU Passthrough
Write-Host "Configuring $VM for GPU Passthrough..."
$stopaction = Get-VM $vm | Select-Object AutomaticStopAction -ErrorAction Stop

if ($stopaction.AutomaticStopAction -ne "TurnOff") { 
    Write-Host "$VM Automatic Stop Action is set incorrectly, changing this now..."
    Set-VM $VM -AutomaticStopAction TurnOff
} else { 
    Write-Host "$VM Automatic Stop Action is set correctly, no changes needed"
} 

Set-VM -GuestControlledCacheTypes $true -VMName $VM -ErrorAction Stop
Set-VM -LowMemoryMappedIoSpace "$minGPUmem" + "MB"  -VMName $VM -ErrorAction Stop
Set-VM -HighMemoryMappedIoSpace "$GPUmem" + "MB" -VMName $VM -ErrorAction Stop

Write-Host "Configuration VM Completed"
Write-Host "Starting configuring GPU..."

#Configure the GPU for Passthrough
Write-Host "Listing installed GPU's..."
$MyDisplays = Get-PnpDevice -PresentOnly | Where-Object {$_.Class -eq “Display”}
$MyDisplays | ft -AutoSize

$GPUname = Read-Host "What is the Friendly Name of the GPU you want to use?"

$myGPU = Get-PnpDevice -PresentOnly| Where-Object {$_.Class -eq “Display”} | Where-Object {$_.FriendlyName -eq $GPUname}

Write-Host "Unassigning GPU from Host, your screen might flicker, don't worry!"
Disable-PnpDevice -InstanceId $myGPU[0].InstanceId -Confirm:$false -ErrorAction Stop

Write-Host "Grabbing GPU Data..."
$unassignedGPU = Get-PnpDeviceProperty DEVPKEY_Device_LocationPaths -InstanceId $myGPU[0].InstanceId
$locationpath = ($unassignedGPU).data[0]

Write-Host "Dismounting GPU from Host..."
Dismount-VmHostAssignableDevice -locationpath $locationpath -force -ErrorAction Stop

#Assign the GPU to the VM
Add-VMAssignableDevice -LocationPath $locationpath -VMName $VM -ErrorAction Stop

Write-Warning "Configuration completed, the $GPUname has been assigned to $VM. To use it, please log in to the VM and install the drivers for the GPU"
Write-Warning "Using a Server Core installation? Download ProcessExplorer from SysInternals to monitor if your GPU is actually being utilized"