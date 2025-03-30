'WKMJ003JNA',
'WKMJ031U61' | 
ForEach-Object {
    if (!(Test-WSMan -ComputerName $_ -ErrorAction SilentlyContinue)) {
        \\lounaswps08\pdrive\Dept907.CIT\Windows\Scripts\Enable-PSRemoting.ps1 -wkid $_
    }
    Invoke-Command -ComputerName $_ -ScriptBlock {
        & MsiExec.exe /x '{0C1DE303-E41B-44BA-8ABA-B7F09D857001}' /qn /norestart /l*v c:\temp\VirtualBox_unin.log
    }
}


'WKPB0XLAN' | 
ForEach-Object {
    if (!(Test-WSMan -ComputerName $_ -ErrorAction SilentlyContinue)) {
        \\lounaswps08\pdrive\Dept907.CIT\Windows\Scripts\Enable-PSRemoting.ps1 -wkid $_
    }
    Invoke-Command -ComputerName $_ -ScriptBlock {
        & MsiExec.exe /x '{5FB568DF-207C-4B21-AC57-FC0CC2A0B113}' /qn /norestart /l*v c:\temp\VirtualBox_unin.log    
    }
}

'WKMJ003JP7' |
ForEach-Object {
    if (!(Test-WSMan -ComputerName $_ -ErrorAction SilentlyContinue)) {
        \\lounaswps08\pdrive\Dept907.CIT\Windows\Scripts\Enable-PSRemoting.ps1 -wkid $_
    }
    Invoke-Command -ComputerName $_ -ScriptBlock {
        & MsiExec.exe /x '{82022940-639B-48A3-86D9-B139864105F7}' /qn /norestart /l*v c:\temp\VirtualBox_unin.log
    }
}

'WKR90J8LY4' |
ForEach-Object {
    if (!(Test-WSMan -ComputerName $_ -ErrorAction SilentlyContinue)) {
        \\lounaswps08\pdrive\Dept907.CIT\Windows\Scripts\Enable-PSRemoting.ps1 -wkid $_
    }
    Invoke-Command -ComputerName $_ -ScriptBlock {
        & MsiExec.exe /x '{6AE61854-0F78-49E3-ABCC-586FB43CE709}' /qn /norestart /l*v c:\temp\VirtualBox_unin.log
    }
}

'SIMXDWDEVC3248' |
ForEach-Object {
    if (!(Test-WSMan -ComputerName $_ -ErrorAction SilentlyContinue)) {
        \\lounaswps08\pdrive\Dept907.CIT\Windows\Scripts\Enable-PSRemoting.ps1 -wkid $_
    }
    Invoke-Command -ComputerName $_ -ScriptBlock {
        & MsiExec.exe /x '{833806DB-0F3D-466E-8353-07283FFBC957}' /qn /norestart /l*v c:\temp\VirtualBox_unin1.log
    }
}

'WKMJ032SVR' |
ForEach-Object {
    if (!(Test-WSMan -ComputerName $_ -ErrorAction SilentlyContinue)) {
        \\lounaswps08\pdrive\Dept907.CIT\Windows\Scripts\Enable-PSRemoting.ps1 -wkid $_
    }
    Invoke-Command -ComputerName $_ -ScriptBlock {
        & MsiExec.exe /x '{8D5E4D4D-5E0C-4448-B018-5DDEF1E208D9}' /qn /norestart /l*v c:\temp\VirtualBox_unin.log
    }
}

'WKMJ05JWJR',
'WKMJ05JWK8',
'WKMJ05JWKA' | 
ForEach-Object {
    if (!(Test-WSMan -ComputerName $_ -ErrorAction SilentlyContinue)) {
        \\lounaswps08\pdrive\Dept907.CIT\Windows\Scripts\Enable-PSRemoting.ps1 -wkid $_
    }
    Invoke-Command -ComputerName $_ -ScriptBlock {
        & MsiExec.exe /x '{1E6A323C-1BE9-49B6-8FDC-107307DBC6CE}' /qn /norestart /l*v c:\temp\VirtualBox_unin.log
    }
}