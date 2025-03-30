param(
[Parameter(Mandatory=$True)]
[string]$REQCost,
[Parameter(Mandatory=$True)]
[string]$REQRole
)

#Parameter
$SiteURL = "https://inspirewellness.sharepoint.com/sites/PersonaTechnologyProfile"
$ListNameID = "Software Profile Identifier"
$ListNameContent = "Software Profile Content"

$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $username,($encpassword | ConvertTo-SecureString)

#Connect to PnP Online
#Connect-PnPOnline -Url $SiteURL -Interactive
Connect-PnPOnline -Url $SiteURL -Credentials $cred
 
#Get all list items from list in batches
#Get-PnPList
#Get-PnPField -List $ListName
$ListIDs = Get-PnPListItem -List $ListNameID -Query "<View><Query><Where><Eq><FieldRef Name='Role_x0020_Name'/><Value Type='Text'>$REQRole</Value></Eq></Where></Query></View>"
ForEach ($ListID in $ListIDs) {
    $ProfileID = $ListID.FieldValues.Title
    $Role = $ListID.FieldValues.Role_x0020_Name
    $Cost = $ListID.FieldValues.Cost_x0020_Center
    If ($Cost -eq $REQCost) {
        Write-Output "Cost - $Cost"
        #Build Tatoo Cost Center and Profile #'s
        $REQSwrPros += $ProfileID + ","#"`n"
        $REQSwrPros = $REQSwrPros.Split(",") | Sort-Object | Get-Unique
        #Get Software matched to Cost Center
        $ListCons = Get-PnPListItem -List $ListNameContent -Query "<View><Query><Where><Contains><FieldRef Name='Title'/><Value Type='Text'>$ProfileID</Value></Contains></Where></Query></View>"
        ForEach ($ListCon in $ListCons) {
            $ProfileCon = $ListCon.FieldValues.Title 
            $PkgID = $ListCon.FieldValues.Package_x0020_ID 
            $CRID = $ListCon.FieldValues.CRID
            $SwrTitle = $ListCon.FieldValues.Software_x0020_Name
            Write-Output "Cost Install $SwrTitle"
            #Get Program Name for Package
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue
            Push-Location WP1:
            $Package = Get-CMPackage -Id $PkgID -Fast | Get-CMProgram | Where-Object ( { $_.ProgramName -EQ 'HUMINST' })
            $PkgInst = $PkgID + ":" + $Package.ProgramName
            #Set variable for packages
            #Set-NextApplicationVariable -BaseVar 'MappedPackage' -Value $PkgInst
            Pop-Location
        }
    }
}

#Tatto to registry
IF (Test-Path -Path "HKLM:\SOFTWARE\humana\OSD\Software Profile") {
    Remove-Item -Path "HKLM:\SOFTWARE\humana\OSD\Software Profile" -Force
}
IF (!(Test-Path "HKLM:\SOFTWARE\humana\OSD\Software Profile")) {
    New-Item -Path "HKLM:\SOFTWARE\humana\OSD\Software Profile"
}
New-ItemProperty -Path "HKLM:\SOFTWARE\humana\OSD\Software Profile" -Name 'CostCenter' -PropertyType String -Value $REQCost -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\humana\OSD\Software Profile" -Name 'Role' -PropertyType String -Value $REQRole -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\humana\OSD\Software Profile" -Name 'Profile#' -PropertyType String -Value $REQSwrPros -ErrorAction SilentlyContinue

