Import-Module WebAdministration
$RequiredExtensions = @('.cs','.config','.exe')
$RequestFiltering = Get-WebConfiguration -filter '/system.webserver/security/requestFiltering'
foreach($Extension in $RequestFiltering.FileExtensions.Collection)
{
    foreach($RequiredExtension in $RequiredExtensions)
    {
        if($Extension.FileExtension -eq $RequiredExtension)
        {
            if(-not $Extension.Allowed)
            {
                $Extension.Allowed = $true
            }
        }
    }
}

Write-Host $Compliant