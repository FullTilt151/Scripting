# Put code here to determine if item is compliant 

foreach ($line in (Get-Content -Path C:\humscript\action.ini)) {
    if ($line -ne 'setting=logoff') {
        if ($line -ne '[action]') {
            if ($line -eq 'setting=reboot') {
                
            }
            $compliant = $false
        }
        
    }
    elseif ($line -eq 'setting=logoff') {
        $compliant = $true   
    }
}
Write-Output $compliant

