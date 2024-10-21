$ModulePath = "$($env:ProgramFiles)\WindowsPowerShell\Modules\CMNSCCMTools"
$ModuleSource = "$PSScriptRoot\Files"
$pkgSource = '\\lounaswps01\pdrive\Dept907.CIT\ConfigMgr\Packages\Humana\CMNSCCMTools\Files'
$kyleSource = '\\lounaswps01\k2scdd\CMNSccmTools\'

Get-Module | Where-Object {$_.Name -eq 'CMNSCCMTools'} | Remove-Module

Copy-Item -Path "$ModuleSource\CMNSCCMTools.PSD1" -Destination $ModulePath -Force
Copy-Item -Path "$ModuleSource\CMNSCCMTools.PSM1" -Destination $ModulePath -Force
Copy-Item -Path "$ModuleSource\CMNSCCMTools.PSD1" -Destination $pkgSource -Force
Copy-Item -Path "$ModuleSource\CMNSCCMTools.PSM1" -Destination $pkgSource -Force
Copy-Item -Path "$ModuleSource\CMNSCCMTools.PSD1" -Destination $kyleSource -Force
Copy-Item -Path "$ModuleSource\CMNSCCMTools.PSM1" -Destination $kyleSource -Force