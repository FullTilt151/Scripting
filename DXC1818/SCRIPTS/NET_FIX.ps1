$WKIDName = Get-Content "c:\Temp\NETFix\Computers.txt"  
  
foreach ($WKID in $WKIDName) {  
  
        IF (Test-Connection -ComputerName $WKID -Count 2 -Quiet ) {   
          
            "$WKID is Pinging "#, ($s = New-PSSession -ComputerName $WKID)
            #Enter-PSSession -Session $s
            $WKID | Out-File -Append -NoClobber -FilePath filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\NETFix\NETResult.log
            $NETVersion = Get-ItemProperty filesystem::\\$WKID\C$\windows\Microsoft.NET\Framework\v2.0.50727\System.Management.dll | Select-Object -ExpandProperty VersionInfo | Select -ExpandProperty productversion
                IF ($NETVersion -eq $null) {$WKID | Out-File -Append -NoClobber -FilePath filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\NETFix\NETNOTInstalled.log}
                #Enable-windowsoptionalfeature -featurename NetFx3 -Online -NoRestart -LimitAccess -All -Source \\LOUNASWPS08\Pdrive\Dept907.CIT\ -LogLevel WarningsInfo -ErrorAction Continue  
                    IF ($NETVersion -eq '2.0.50727.8670') {$WKID | Out-File -Append -NoClobber -FilePath filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\NETFix\NETUninstall.log}
                        IF ($NETVersion -gt '2.0.50727.8670') {$WKID | Out-File -Append -NoClobber -FilePath filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\NETFix\NETGood.log}
                    #Disable-WindowsOptionalFeature -online -FeatureName NetFx3 –NoRestart
                    #shutdown /c "The computer will restart in ten minutes to resolve security vulnerabilities" /r /t 600 /f

            $NETVersion | Out-File -Append -NoClobber -FilePath filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\NETFix\NETResult.log
            #Exit-PSSession
                     
         } ELSE {
            "$WKID not pinging"  
            $WKID | Out-File -Append -NoClobber -FilePath filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\NETFix\NETOffline.log}         
} 
