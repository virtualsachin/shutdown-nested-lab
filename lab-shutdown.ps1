#################################################################################
# Shutdown VMs and Hosts, if you are a nested LAB, it can be very helpful while 
# shutdown the lab VMs gracefully.
#
# This script will loop through a list of ESXi hosts and initiate shutdown
# commands to the vm's residing on them. If VMware Tools is installed, the
# script will attempt to do a graceful shutdown. If VMware tools is not
# installed a hard power off will be issued. One note, if you have any VMs that
# you would like to remain on until the end of the process be sure to put their
# names in the $vmstoleaveon variable and also be sure they reside on the last
# host listed in the $hoststoprocess variable.
#
# i.e If I wanted to have VM1 and VM2 stay on till the end I would have to be
# sure that they reside on esxi-03 and my variables would be setup as follows
#
# $vmstoleaveon = "VM1 VM2"
# $listofhosts = "esxi-01 esxi-02 esxi-03"
#
# Created By: Sachin Kumar Sharma
#
#################################################################################
Connect-VIServer 'vCenter hostname/IP' -user root -password "Your Password"
Connect-VIServer 'ESXi Host IP/hostname' -user root -password "Your Password"
# list of hosts to process
$listofhosts = "esxi-01", "esxi-02"

#list of vm's to 'go down with the ship' - vms must reside on last host in above list.
$vmstoleave = "VM1", "VM2"

#loop through each host
Foreach ($esxhost in $listofhosts)
{
$currentesxhost = get-vmhost $esxhost
Write-Host "Processing $currentesxhost"

#loop through each vm on host
Foreach ($VM in ($currentesxhost | Get-VM | where { $_.PowerState -eq "PoweredOn" }))
{
Write-Host "===================================================================="
Write-Host "Processing $vm"

# if this is a vm that is supposed to go down with the ship.
if ($vmstoleave -contains $vm)
{
Write-Host "I am $vm - I will go down with the ship"
}
else
{
Write-Host "Checking VMware Tools...."
$vminfo = get-view -Id $vm.ID
# If we have VMware tools installed
if ($vminfo.config.Tools.ToolsVersion -eq 0)
{
Write-Host "$vm doesn't have vmware tools installed, hard power this one"
# Hard Power Off
Stop-VM $vm -confirm:$false

}
else
{
write-host "I will attempt to shutdown $vm"
# Power off gracefully
$vmshutdown = $vm | shutdown-VMGuest -Confirm:$false
}
}
Write-Host "===================================================================="
}
    Write-Host "Initiating host shutdown in 40 seconds"
    Start-Sleep -s 40
    #look for other vm's still powered on.

    Foreach ($VM in ($currentesxhost | Get-VM | where { $_.PowerState -eq "PoweredOn" }))
    {
        Write-Host "===================================================================="
        Write-Host "Processing $vm"
        Stop-VM $vm -confirm:$false
        Write-Host "===================================================================="
    }

    #Shut down the host
    Start-Sleep -s 20

    Set-VMhost -VMhost $currentesxHost -State Maintenance
    Start-Sleep -s 15

    Set-VMhost -VMhost $currentesxHost -State Connected
    Start-Sleep -s 60

    $currentesxhost | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)}

Disconnect-VIServer -Server $global:DefaultVIServers -Force -Confirm:$false

}
Write-Host "Shutdown Complete"
