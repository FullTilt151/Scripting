$service = get-service smstsmgr
 
if (($service.ServicesDependedOn).name -notcontains "ccmexec") 
{ 
 start-process sc.exe -ArgumentList "config smstsmgr depend= winmgmt/ccmexec" -wait 
} 