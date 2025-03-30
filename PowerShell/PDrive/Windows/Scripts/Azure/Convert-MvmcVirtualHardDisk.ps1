Import-Module 'C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1'

ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath "E:\AzurePOC\AzureDev\SIMXDWDEVP1700\SIMXDWDEVP1700_disk0.vmdk" -VhdType FixedHardDisk -VhdFormat vhdx -DestinationLiteralPath "E:\AzurePOC\AzureDev\SIMXDWDEVP1700"