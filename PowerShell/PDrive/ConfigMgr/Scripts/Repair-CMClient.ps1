$comps = get-content c:\temp\wkids.txt

foreach ($wkid in $comps) {
    if (Test-Connection $wkid -Count 1 -ErrorAction SilentlyContinue) {
        Write-Host "`n$wkid is online"
        
        Write-Output 'Verifying CCMexec service...'
        $ccmexec = Get-Service ccmexec -ComputerName $wkid -ErrorAction SilentlyContinue

        if ($ccmexec -ne $null) {
            # Get provisioning mode keys
            $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $wkid)
            $ref = $regKey.OpenSubKey("SOFTWARE\Microsoft\CCM\CcmExec",$true)
            $Prov = $ref.GetValue("ProvisioningMode")
            $Tasks = $ref.GetValue('SystemTaskExcludes')

            if ($Prov -eq $true -or $Tasks -ne "") {
                Write-Output "!! Provisioning mode is on !!"
                Write-Output "Turning off provisioning mode..."
                # Fix provisioning mode
                $ref.SetValue("ProvisioningMode","false")
                $ref.SetValue('SystemTaskExcludes','')
                Write-Output "Verifying keys..."
                Write-Output 'ProvisioningMode: '$ref.GetValue("ProvisioningMode")
                Write-Output 'SystemTaskExcludes: '$ref.GetValue('SystemTaskExcludes')
            } else {
                Write-Output 'Provisioning mode is not set!'
            }

            # Reset machine policy
            Write-Output 'Resetting machine policy...'
            Invoke-WmiMethod -ComputerName $wkid -Namespace root\ccm -Class sms_client -Name ResetPolicy -ArgumentList 0 | Out-Null

            # Restart service
            Write-Output 'Restarting CCMexec...'
            Get-Service CcmExec -ComputerName $wkid | Restart-Service -Force
            Start-Sleep -Seconds 30

            # Invoke DDR cycle
            Write-Output 'Invoking Data Discovery cycle...'
            Invoke-WmiMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule -ComputerName $wkid -ArgumentList "{00000000-0000-0000-0000-000000000003}" | Out-Null
        } else {
            Write-Output 'No CCMexec service, please check client install logs!'
        }
    } else {
        write-host "`n$wkid is offline"
    }
}