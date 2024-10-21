# minimum required DotNot version to ensure TLS1.2 compatability according to Microsoft Docs (https://docs.microsoft.com/en-us/sccm/core/plan-design/security/enable-tls-1-2)
[version]$Minimum_DotNet = '4.6.2'

$DotNetObjects = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse | Get-ItemProperty -name Version, Release -EA 0 
$DotNet = foreach ($One in $DotNetObjects) { 
    if ($One.PSChildName -match '^(?![SW])\p{L}') {
        $One | Select-Object PSChildName, Version, Release, @{
            name       = "Product"
            expression = {
                switch -regex ($_.Release) {
                    "378389" {
                        [Version]"4.5" 
                    }
                    "378675|378758" {
                        [Version]"4.5.1" 
                    }
                    "379893" {
                        [Version]"4.5.2" 
                    }
                    "393295|393297" {
                        [Version]"4.6" 
                    }
                    "394254|394271" {
                        [Version]"4.6.1" 
                    }
                    "394802|394806" {
                        [Version]"4.6.2" 
                    }
                    "460798|460805" {
                        [Version]"4.7" 
                    }
                    "461308|461310" {
                        [Version]"4.7.1" 
                    }
                    "461808|461814" {
                        [Version]"4.7.2" 
                    }
                    "528040|528049" {
                        [Version]"4.8" 
                    }
                    { $_ -gt 528049 } {
                        [Version]"Undocumented version (> 4.8), please update script" 
                    }
                }
            }
        }
    }
}

$Valid_DotNet = @{ }

#region loop through all DotNet products found and validate that at least one is -ge $Minimum_DotNet
foreach ($Version in ($DotNet | Where-Object { $_.Product } | Select-Object -ExpandProperty Product)) {
    try {
        if ($Version -ge $Minimum_DotNet) {
            $Valid_DotNet[$Version] = $true
            break;
        }
        else {
            $Valid_DotNet[$Version] = $false
        }
    }
    catch {
        $Valid_DotNet[$Version] = $false
    }
}
#endregion loop through all DotNet products found and validate that at least one is -ge $Minimum_DotNet

[bool]($Valid_DotNet.Values -contains $true)