#Get ContainerNodeID from WMI
#WQ1
Get-wmiObject -computername louappwqs1151 -Namespace root\SMS\site_WQ1  -Query "Select name,containernodeid from SMS_ObjectContainerNode Where Name='Deployment Collections - Do Not Modify'"

#WP1
Get-wmiObject -computername louappwps1658 -Namespace root\SMS\site_WP1  -Query "Select name,containernodeid from SMS_ObjectContainerNode Where Name='Deployment Collections - Do Not Modify'"