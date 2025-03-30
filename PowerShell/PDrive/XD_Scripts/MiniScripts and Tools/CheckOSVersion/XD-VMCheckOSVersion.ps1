$VMNamePrefix ="louxdwstdb"
$StartNum = 1665
$EndNum = 1665


$VMs = @()

for ($i=$StartNum; $i -le $EndNum; $i++) 
{
    $VMsObj = New-Object System.Object
    $VMName = $VMNamePrefix + $i.ToString()
    Write-host $VMName
    $version = Invoke-Command -ComputerName $VMName -ScriptBlock { (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId }
    Write-host $version
    Write-host `n
    $VMsObj | Add-Member -type NoteProperty -name Name -Value $VMName
    if ($version -ne $null)
        {
        $VMsObj | Add-Member -type NoteProperty -name Version -Value $version
        }
    else
        {
        $VMsObj | Add-Member -type NoteProperty -name Version -Value "No Response"
        }
    $VMs += $VMsObj
    Remove-Variable VMsObj
}
$VMs | Export-Csv -Path "VM_OS_Versions.csv"