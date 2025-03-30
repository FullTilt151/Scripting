<# May be able to automate this in the future, currently broken though
$url = "http://support.microsoft.com/kb/2894518"
$i=1 
$result = Invoke-WebRequest $url -Credential daniel.ratliff@gmail.com
$elements = $result.AllElements | Where Class -eq "plink" 

foreach ($link in $elements.innertext) {
    $pos = $link.indexof('/kb/') + 3 
    if ($pos -gt 3) {
        #Move the starting position to the start of the KB number and capture all char's to end
        $sOutput = $link.Substring($pos,$link.Length-$pos)
        #Replace '/' and ')' with nothing
        $ExcludeKB = $sOutput.Replace('/','').Replace(')','').Trim()
        #KB Number is stored in $ExcludeKB
        Write-Host $ExcludeKB
    }
    $i++  
}
#>

# Current known patches from KB2894518
$updates = '3126446','3096053','3075222','3067904','3069762','3003729','3035017','3039976','3036493','3003743','2984976','2981685','2966034','2965788','2920189','2862330','2871777','2871690','2821895','2771431','2545698','2529073'

# OSD-DoubleReboots SUG for tracking
$SUGID = 16871884

Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
Set-Location wp1:

foreach ($update in $updates) {
    # Gather each update by KB number
    Get-CMSoftwareUpdate -Name "*$update*" -Fast | ForEach-Object {
        # Display the KB name
        $psitem.LocalizedDisplayName
        # Add the KB to the SUG
        Add-CMSoftwareUpdateToGroup -SoftwareUpdateName $psitem.LocalizedDisplayName -SoftwareUpdateGroupId $SUGID
    }
}