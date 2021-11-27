# shutdown-nested-lab


 Shutdown VMs and Hosts, if you are a nested LAB, it can be very helpful while 
 shutdown the lab VMs gracefully.

 This script will loop through a list of ESXi hosts and initiate shutdown
 commands to the vm's residing on them. If VMware Tools is installed, the
 script will attempt to do a graceful shutdown. If VMware tools is not
 installed, a hard power off will be issued. One note, if you have any VMs that
 you would like to remain on until the end of the process be sure to put their
 names in the $vmstoleaveon variable and also be sure they reside on the last
 host listed in the $hoststoprocess variable.

 i.e If I wanted to have VM1 and VM2 stay on till the end I would have to be
 sure that they reside on esxi-03 and my variables would be setup as follows

 $vmstoleaveon = "VM1 VM2"
 $listofhosts = "esxi-01 esxi-02 esxi-03"

I am using this script with a cron job scheduling to automatically schedule a shutdown at night, when I am not needed by the lab.
