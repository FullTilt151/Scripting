#https://1eportal.force.com/s/article/KB000001621
<# 
Resolution


Carry out the following steps in order. Please make sure you have a recent backup of the ActiveEfficiency database before continuing, or take a new one.

On the Nomad client experiencing the issues as detailed in symptoms:  1.Backup the registry before continuing.
2.Stop the Nomad Service and set to disabled.
3.Make sure the HKEY_LOCAL_MACHINE\Software\1E\NomadBranch\PrecachePollMinutes registry key value is the default of 1440. Make a note of any custom value.. 
4.Delete all subkeys of HKEY_LOCAL_MACHINE\Software\1E\NomadBranch\PkgStatus.


In the ActiveEfficiency SQL Database:

Identify the DeviceId by using the following SQL statement.  The DeviceId will be used to run the next SQL statement to clear the entries in the ContentDeliveries table for the specific system.
  Select * from [dbo].[Devices] Where HostName = 'computer name' -- Computer name is the NETBIOS name of system. 


Delete all existing entries from ActiveEfficiency database ContentDeliveries table for the Nomad client that has not registered some of the content. This way we do not end up with duplicates when we continue. You would need to run the following SQL statement against the ContentDeliveries table

  delete from ContentDeliveries where DeviceId='deviceid of device'  --Replace DeviceId with the DeviceId returned on the SQL statement above.

On the Nomad client we were working on previously:1.Restart the Nomad service on the Nomad client and change the Startup type back to Automatic (Delayed start). This will cause a re-check of all the packages in the Nomad cache and packages that are complete 100% will have the status posted to ActiveEfficiency database ContentDeliveries table. This could take some time to complete but will be quicker than using CacheCleaner.exe –DeleteAll and re-download all the content. If the re-check doesn’t start after 5-10 minutes or so of restarting the service (you can see the jobs being processed and posted to ActiveEfficiency in the Nomad Branch log) open an elevated Command Prompt, browse to <ProgramFiles>\1E\NomadBranch and run the following command: NomadBranch.exe –ActivateAll.
2.Once you have confirmed in the Nomad Branch log that no more packages status are being processed and posted to ActiveEfficiency, you can query the ContentDeliveries table in the ActiveEfficiency database for that device and confirm the number of records match the number of pre-cached items.
3.Once the above is confirmed if you have a custom PrecachePollMinutes value set previously in the Nomad registry, you can change it back to your preferred setting.
4.If you change the PrecachePollMinutes value in the Nomad registry, you will need to restart the 1E Nomad Service or wait for a client reboot.
 #>