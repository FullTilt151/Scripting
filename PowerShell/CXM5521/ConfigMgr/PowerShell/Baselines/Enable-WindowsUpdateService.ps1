$Remediate = $false

try {
    $Service = Get-WmiObject -Query "SELECT * FROM Win32_Service WHERE Name = 'wuauserv'" -ErrorAction Stop
    switch ($Service.StartMode) {
        'Auto' {
            $PSItem
        }
        default {
            switch ($Remediate) {
                $true {
                    try {
                        $null = $Service.ChangeStartMode('Automatic')
                        return 'Auto'
                    }
                    catch {
                        return 'Failed to remediate'
                    }
                }
                $false {
                    $Service.StartMode
                }
            }
        }
    }
}
catch {
    return 'Failed to query service startmode'
}