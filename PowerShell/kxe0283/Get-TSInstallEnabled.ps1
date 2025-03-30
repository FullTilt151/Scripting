# Site configuration
$SiteCode = "WP1" # Site code 
$ProviderMachineName = "LOUAPPWPS1658.rsc.humad.com" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams
function Get-TSInstallEnabled ()
{

    Function Get-PackageTSInfo()
    {
    $Progs = @() 
    foreach ($Prog in Get-CMProgram)
        {
        $PackageID = $Prog.PackageID   
        $ProgName = $Prog.ProgramName
        $PackageName = $prog.PackageName
        $AllowTs = $Prog.ProgramFlags -band [math]::pow(0,0)
        #$RunModeAdmin = $Prog.ProgramFlags -band [math]::pow(#,#)
        #$RunModeLogin = $Prog.ProgramFlags -band [math]::pow(#,#)
        #$RunSilent = $Prog.ProgramFlags -band [math]::pow(#,#)
        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name "Package" -Value $PackageID
        $object | Add-Member -MemberType NoteProperty -Name "Program Name" -Value $ProgName
        $object | Add-Member -MemberType NoteProperty -Name "Package Name" -value $Packagename

        if ($AllowTs -ne "1") {$AllowTs = "false"} Else {$AllowTs = "true"}
        #if ($RunModeAdmin -ne "#") {$RunModeAdmin = "false"} Else {$RunModeAdmin = "true"}
        #if ($RunModeLogin -ne "#") {$RunModeLogin = "false"} Else {$RunModeLogin = "true"}
        #if ($RunSilent -ne "#") {$RunSilent = "false"} Else {$RunSilent = "true"}

        $object | Add-Member -MemberType NoteProperty -Name "Allowed TS Install" -Value $AllowTs
        #$object | Add-Member -MemberType NoteProperty -Name "Run Mode Admin Enabled" -Value $RunModeAdmin
        #$object | Add-Member -MemberType NoteProperty -Name "Run Mode Any Login" -Value $RunModeLogin
        #$object | Add-Member -MemberType NoteProperty -Name "Rub Mode Silent" -Value $RunSilent

        
        $Progs += $object
     }
     $progs 
}

Get-PackageTSInfo
Pop-Location
}

Get-TSInstallEnabled | Export-Csv -Path C:\temp\TSEnable.csv