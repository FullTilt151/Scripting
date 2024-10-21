Function Get-CMNUpdates {
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$SUG,

        [Parameter(Mandatory = $true)]
        [String]$PackageSourcePath,

        [Parameter(Mandatory = $true)]
        [String]$DPGroupName,

        [Parameter(Mandatory = $true)]
        [String[]]$UpdateList
    )

    begin {
        #Test for PackageSourcePath
        if (-not (Test-Path $PackageSourcePath)) {
            Throw "Unknown Path - $PackageSourcePath"
        }

        #Test for DP Group
        $DPGroup = Get-WmiObject -Class SMS_DistributionPointGroup -Filter "name = '$DPGroupName'" @WMIQueryParameters
        if (-not $DPGroup) {
            Throw "Unknown Distribution Point Group - $DPGroup"
        }
    }

    process {
        #       Function Set-CMNUpdateDeploymentPackage{
        # This function creates and distributes the Deployment Package 
        $PKGPath = "$PackageSourcePath$SUG"
        $DeployPackage = ([WMIClass]"\\$($SccmConnectInfo.ComputerName)\$($SccmConnectInfo.NameSpace):SMS_SoftwareUpdatesPackage").CreateInstance()
        $DeployPackage.Name = $SUG
        $DeployPackage.SourceSite = $SccmConnectInfo.SiteCode
        $DeployPackage.PkgSourcePath = $PKGPath
        $DeployPackage.Description = "$SUG"
        $DeployPackage.PkgSourceFlag = [int32]2 #Value of 2 -->Stores Software Updates

        $DeployPackage.put()

        $DeployPackage.get()
        $contentsourcepath = Get-ChildItem  -path $PKGPath | select -ExpandProperty Fullname
        $allContentIDs = $contentsourcepath | foreach {Split-Path  -Path $_ -Leaf}
        $DeployPackage.AddUpdateContent($allContentIDs, $contentsourcepath, $true)
        $DPGroup = Get-WmiObject -Class SMS_DistributionPointGroup -Filter "name = '$DPGroupName'" @WMIQueryParameters
        $DPGroup.AddPackages($DeployPackage.PackageID)
        #    } #End Set-CMNUpdateDeploymentPackage

        #Create a new PSDrive where the Patches will be downloaded
        if (-not $PackageSourcePath -match '\\$') {$PackageSourcePath = "$PackageSourcePath\"}
        New-PSDrive -Name M -PSProvider FileSystem -Root "$PackageSourcePath" | Out-Null
        $DownloadPath = "M:\$SUG"
        if (-not (Test-Path M:\$SUG)) {
            New-Item -Path "M:\$SUG" -ItemType directory
        }

        $DownloadInfo = foreach ($CI_ID in $UpdateList) {
            $contentID = Get-WmiObject -Query "Select ContentID,ContentUniqueID,ContentLocales from SMS_CITOContent Where CI_ID='$CI_ID'"  @WMIQueryParameters
            #Filter out the English Local and ContentID's not targeted to a particular Language
            $contentID = $contentID  | Where {($_.ContentLocales -eq "Locale:9") -or ($_.ContentLocales -eq "Locale:0") }

            foreach ($id in $contentID) {
                $contentFile = Get-WmiObject -Query "Select FileName,SourceURL from SMS_CIContentfiles WHERE ContentID='$($ID.ContentID)'" @WMIQueryParameters
                [pscustomobject]@{Source = $contentFile.SourceURL ;
                    Destination = "$DownloadPath\$($id.ContentID)\$($contentFile.FileName)";
                }
            }
        }

        $DownloadInfo.destination |
            ForEach-Object -process {
            If (! (test-path -Path "filesystem::$(Split-Path -Path $_)")) {
                New-Item -ItemType directory -Path "$(Split-Path -Path $_)"
            }
        }
        $DownloadInfo | Start-BitsTransfer

        Set-CMNUpdateDeploymentPackage $SUG $UpdateList
        $DownloadInfo.destination |`
            ForEach-Object -Process `
        {
            if (Test-Path (Split-Path -path $_)) {Remove-Item -Path (split-path -path $_) -Recurse -verbose}
        }
    }

    end {}
} #End Get-CMNUpdates
