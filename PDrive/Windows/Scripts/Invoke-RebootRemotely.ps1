Import-Module 'C:\Program Files (x86)\ConfigMgr10\bin\ConfigurationManager.psd1'
Push-Location WP1:

Get-CMCollectionMember -CollectionId WP1071F7 | Select-Object -ExpandProperty Name | ForEach-Object {
    if (Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue) {
        Pop-Location
        [int]$Time = ((Get-Date -Date 8/26/2020 -Hour 2) - (Get-Date)).Totalseconds

        & shutdown.exe -r -f -m $_ -t $Time -c "Your workstation is required to restart for important security updates!"
    }
}