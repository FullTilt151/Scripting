Import-Module 'C:\Program Files (x86)\ConfigMgr10\bin\ConfigurationManager.psd1'
Set-Location WP1:

$Rule = Get-CMSupportedPlatform -Name 'All Windows 10 (64-bit) Client' -Fast

'MT1', 'WQ1','WP1','SQ1','SP1' | ForEach-Object {
    New-CMProgram -CommandLine "Deploy-Application.exe -DeployMode Silent -Site $_" -DiskSpaceRequirement 140 -Duration 15 -PackageId WP10078C -RunType Hidden -StandardProgramName "Install $_" -RunMode RunWithAdministrativeRights -DiskSpaceUnit MB -ProgramRunType WhetherOrNotUserIsLoggedOn -AddSupportedOperatingSystemPlatform $Rule
}

New-CMProgram -CommandLine 'Deploy-Application.exe -DeployMode Silent -DeploymentType Uninstall' -DiskSpaceRequirement 140 -Duration 15 -PackageId WP10078C -RunType Hidden -StandardProgramName "Uninstall" -RunMode RunWithAdministrativeRights -DiskSpaceUnit MB -ProgramRunType WhetherOrNotUserIsLoggedOn -AddSupportedOperatingSystemPlatform $Rule

#TODO Add all CM sites
#TODO Automate creating source folder
#TODO Automate creating package
#TODO Automate grabbing package size
#TODO Parameterize PackageID
#TODO Param for 1E Client