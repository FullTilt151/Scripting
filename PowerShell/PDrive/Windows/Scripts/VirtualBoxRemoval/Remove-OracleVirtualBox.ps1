'{0C1DE303-E41B-44BA-8ABA-B7F09D857001}',
'{5632714F-6A48-4BF2-89E0-F8B6CE9FE6D1}',
'{B5121457-0126-4E62-BCBF-6DC7C73D9E4A}',
'{DD8F7A7A-852F-4648-8A73-B8FC1DF5F082}',
'{E8BB81BC-E67C-4750-84EE-128DA5A7ADA5}',
'{5FB568DF-207C-4B21-AC57-FC0CC2A0B113}',
'{F2E958A1-9215-4C7D-9A2E-F0740B8CA5B7}',
'{6CB00039-29CC-42A1-8ED2-820821DA2B8A}',
'{8209969B-9A31-4021-B0D8-E6F719F7F995}',
'{BA15D402-19CA-493E-958B-170A0C446F25}',
'{65402252-5DA1-4360-A144-E09BB16AC7A9}' | 
ForEach-Object {
    $GUID = $_
    (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq $GUID} | ForEach-Object {
        Write-Output "Found $GUID x64"
        & MsiExec.exe /x $GUID /qn /norestart /l*v c:\temp\OracleVirtualBoxUninstall.log
    }

    (Get-ChildItem -Path HKLM:\SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq $_} | ForEach-Object {
        Write-Output "Found $GUID x86"
        & MsiExec.exe /x $GUID /qn /norestart /l*v c:\temp\OracleVirtualBoxUninstall.log
    }
}