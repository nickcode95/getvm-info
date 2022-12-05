$report = @()
 $subs = Get-AzSubscription 
 Foreach ($sub in $subs)
     {
     select-AzSubscription $sub 
     $subName = $sub.Name
        
     $vms = Get-AzVM -Status 
     $tags = Get-AzVM | Select Tags
     $publicIps = Get-AzPublicIpAddress 
     $nics = Get-AzNetworkInterface | ?{ $_.VirtualMachine -NE $null} 
     foreach ($nic in $nics) { 
         $info = "" | Select VmId, VmName, ResourceGroupName, VmSize, PowerState, OsType, PublicIPAddress, Tags
         $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id 
         foreach($publicIp in $publicIps) { 
             if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
                 $info.PublicIPAddress = $publicIp.ipaddress
                 } 
             }
             foreach($tag in $tags) {
                $info.tags = $tag
                }

             $info.VmId = $vm.vmid
             $os = $vm.StorageProfile.ImageReference.Offer
             $osDiskName = $vm.StorageProfile.OsDisk.Name
             $info.VMName = $vm.Name 
             $info.OsType = $os 
             $info.PowerState = $vm.powerstate
             $info.ResourceGroupName = $vm.ResourceGroupName 
             $info.VmSize = $vm.HardwareProfile.VmSize
             $osDisk = Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $osDiskName
             $report+=$info
             } 
     }
 $report | ft VmId, VmName, ResourceGroupName, VmSize, PowerState, OsType, PublicIPAddress, Tags
  $report | Export-csv .\AzureVms.csv -NoTypeInformation