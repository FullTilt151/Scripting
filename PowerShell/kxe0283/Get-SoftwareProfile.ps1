#Software Profiler Step in Software Profile Task Sequence
try {
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
    }
catch {
    Write-Output 'Failed to establish Microsoft.SMS.TSEnvironment ComObject'
    exit 1
      }   

#TS Values
$REQCost = $tsenv.Value("REQCost")
$REQRole = $tsenv.Value("REQRole")
$SiteURL = $tsenv.Value("SiteURL")
$ListNameID = $tsenv.Value("ListNameID")
$ListNameContent = $tsenv.Value("ListNameContent")
$user = $tsenv.Value("User")
$password = $tsenv.Value("password")

Write-Output "Cost Center = $REQCost"
Write-Output "Role = $REQRole"
Write-Output "SiteURL = $SiteURL"
Write-Output "ListNameID = $ListNameID"
Write-Output "ListNameContent = $ListNameContent"
Write-Output "User = $user"

Write-Output "[$TSVar = $Value]"
#$tsenv.Value($TSVar) = $Value
$tsenv.Value("REQCost") = $REQCost
$tsenv.Value("REQRole") = $REQRole

#SPO Authentication via StoredCredential
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList @("HUMAD\osdautomationprod", (ConvertTo-SecureString -String $password -AsPlainText -Force))
Add-PnPStoredCredential -Name $SiteURL -Username "$user" -Password (ConvertTo-SecureString -String "$password" -AsPlainText -Force)

#Connect to PnP Online
$SPConnect = Connect-PnPOnline -Url "$SiteURL" -Credential (Get-PnPStoredCredential -Name "$SiteURL") -ReturnConnection 

#Get Software Profile Number based on Cost Center and Role
$ListIDs = Get-PnPListItem -Connection $SPConnect -List $ListNameID -Query "<View><Query><Where><And><Eq><FieldRef Name='Role_x0020_Name'/><Value Type=Text>$REQRole</Value></Eq><Eq><FieldRef Name='Cost_x0020_Center'/><Value Type=Text>$REQCost</Value></Eq></And></Where></Query></View>"
ForEach ($ListID in $ListIDs) {
    $ProfileID = $ListID.FieldValues.Title
    $Role = $ListID.FieldValues.Role_x0020_Name
    $Cost = $ListID.FieldValues.Cost_x0020_Center
    If ($Cost -eq $REQCost -and $Role -eq $REQRole) {
        Write-Output "Cost - $Cost"
        #Build Tatoo Cost Center and Profile #'s
        $REQSwrPros += $ProfileID + ","#"`n"
        $REQSwrPros = $REQSwrPros.Split(",") | Sort-Object | Get-Unique
        #Get Software matched to Cost Center and Role (Software Profile)
        $ListCons = Get-PnPListItem -Connection $SPConnect -List $ListNameContent -Query "<View><Query><Where><Contains><FieldRef Name='Title'/><Value Type='Text'>$ProfileID</Value></Contains></Where></Query></View>"
        ForEach ($ListCon in $ListCons) {
            $ProfileCon = $ListCon.FieldValues.Title 
            $PkgID = $ListCon.FieldValues.Package_x0020_ID 
            $CRID = $ListCon.FieldValues.CRID
            $SwrTitle = $ListCon.FieldValues.Software_x0020_Name
            #Skip Software Installation if Software Profile has no additional applications beyond base image. Also Skips the Verint Playback and Screen Recording Client Phone System Selector PkgID.
            If ($PkgID -in 'WQ101218') {continue} {Write-Output "Skipping PkgID WQ101218"}
            If ($ProfileID -eq '10000') { Write-Output "Standard Software Profile Detected. No additional software will be installed." } 
            Else {
                Write-Output "Cost Install $SwrTitle"
                #Get Program Name for Package
                $Package = Invoke-RestMethod -Method 'Get' -Uri "https://CMWPPSS.HUMAD.COM/AdminService/wmi/SMS_Program" -Credential $Cred
                
                $ProgNameList = $Package | Select-Object -ExpandProperty value | Where-Object -Property "PackageID" -EQ "$PkgID"
                    
                $ProgramNames = @('Update-OSD', 'HUMinst-OSD', 'ATSInst-OSD', 'Huminst - OSD', 'HUMINST - Silent', 'SILENT-INSTALL', 'Install-Silent', 'Install Power BI Desktop', 'Install Azure Data Studio', 'Install Azure Data Studio')
                
                $ProgNameList | ForEach-Object {  
                                        if ($($_.ProgramName).tostring() -in $ProgramNames) 
                        { $ProgName = $_.ProgramName } 
                    elseif ($($_.ProgramName).tostring() -in 'HUMINST', 'ATSInst')
                        { $ProgName = $_.ProgramName }
                                                }
            $PkgInst = $PkgID + ":" + '''' + $ProgName + ''''
            #Set variable for packages
            $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment    
            $CountPkg = $CountPkg + 1
            $Id = "{0:D3}" -f $CountPkg
            $MappedPackage = "MappedPackage$Id"
            $tsenv.Value($MappedPackage) = $PkgInst
            Write-Output "PackageList = $MappedPackage $PkgInst"
                }
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
New-ItemProperty -Path "HKLM:\SOFTWARE\humana\OSD\Software Profile" -Name 'CostCenter' -PropertyType String -Value $Cost -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\humana\OSD\Software Profile" -Name 'Role' -PropertyType String -Value $Role -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\humana\OSD\Software Profile" -Name 'Profile #' -PropertyType String -Value $REQSwrPros -ErrorAction SilentlyContinue

Remove-PnPStoredCredential -Name $SiteURL -Force