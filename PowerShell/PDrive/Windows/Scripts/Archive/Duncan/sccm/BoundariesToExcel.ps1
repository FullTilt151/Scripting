#Requires -version 2
# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2009
# 
# NAME:      Export-SCCMBoundaries v1.0
# 
# AUTHOR:    YellowOnline
# DATE  :    09/05/2011
# 
# COMMENT:    
#             
# ==============================================================================================

# #region VARIABLES
#General
$ScriptVersion = "1.0"
$ScriptPath = Split-Path -Parent $myInvocation.MyCommand.Definition 
$ScriptName = Split-Path -Leaf $myInvocation.MyCommand.Definition

#SCCM
$PrimarySiteServer = "LOUAPPWPS875"
$SiteCode = "CAS"

#Output
#$OutputFileName = ""
# #endregion

Function Using-Culture (
                        [System.Globalization.CultureInfo]$culture = (Throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"),
                        [ScriptBlock]$script= (Throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"))
    {
    $OldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture
    Trap 
        {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
        }
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
    Invoke-Command $script
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
    # Excel bug workaround by Jeffrey P. Snover [MSFT]
    }
    
Function Get-Boundaries()
    {
    # Pro info:
    # BoundaryType 0 = IP subnet
    # BoundaryType 1 = Active Directory site
    # BoundaryType 2 = IPv6 prefix
    # BoundaryType 3 = IP address range
    # BoundaryFlags 0 = Fast
    # BoundaryFlags 1 = Slow
    $WMIQuery = New-Object System.Management.ObjectQuery
    Write-Host "Site Code: $SiteCode"
    Write-Host "Preparing query for WMI"
    $WMIQuery.QueryString = "SELECT * FROM SMS_Boundary"
    $WMISearcher = New-Object System.Management.ManagementObjectSearcher($WMIQuery)
    Write-Host "Connecting to SMS Provider at: $PrimarySiteServer"
    $WMISearcher.Scope.Path = "\\$PrimarySiteServer\root\SMS\Site_$SiteCode"
    Write-Host "Querying WMI for $SiteCode Boundaries"
    $script:OutputData = $WMISearcher.Get() | Select-Object Value, DefaultSitecode, DisplayName, BoundaryFlags
    $OutputData
    }

Function Write-Excel()
    {
    # Pro info:
    # BoundaryType 0 = IP subnet
    # BoundaryType 1 = Active Directory site
    # BoundaryType 2 = IPv6 prefix
    # BoundaryType 3 = IP address range
    # BoundaryFlags 0 = Fast
    # BoundaryFlags 1 = Slow
    $Row = 1    
    Write-Host "Creating Excel object"
    $Excel = New-Object -COMObject Excel.Application
    Write-Host "Opening Excel application"
    $Excel.Visible = $True
    Write-Host "Adding Excel workbook"
    $Workbook = $Excel.Workbooks.Add()
    Write-Host "Adding Excel worksheet"
    $Worksheet = $Workbook.Worksheets.Item(1)
    Write-Host "Writing Excel output"
    $Worksheet.Cells.Item($Row,1) = "Boundary"
    $Worksheet.Cells.Item($Row,2) = "SiteCode"
    $Worksheet.Cells.Item($Row,3) = "Description"
    $Worksheet.Cells.Item($Row,4) = "Value"
    $Worksheet.Cells.Item($Row,5) = "Connection"
    ForEach ($objOutputData in $OutputData)
        {
        $Row++
        $Worksheet.Cells.Item($Row,1) = $objOutputData.Value
        $Worksheet.Cells.Item($Row,2) = [string]$objOutputData.DefaultSiteCode
        $Worksheet.Cells.Item($Row,3) = $objOutputData.DisplayName
        $Worksheet.Cells.Item($Row,4) = $objOutputData.Value

        If ($objOutputData.BoundaryFlags -EQ 0)
            {$Worksheet.Cells.Item($Row,5) = "Fast"}
        Else
            {$Worksheet.Cells.Item($Row,5) = "Slow"}            
        }
    #Write-Host "Saving Excel file "
    #$Workbook.SaveAs("$OutputFileName")
    #Write-Host "Quitting Excel application"
    #$Excel.Quit()
    Write-Host "Done!"
    }

# #region MAIN
Write-Host "============================================================"
Write-Host "$env:userdomain\$env:username logged on from $env:computername."
Write-Host "Running $ScriptName v$ScriptVersion from $ScriptPath"
Write-Host ""
Using-Culture en-US {Get-Boundaries;Write-Excel}
Write-Host ""
Write-Host "============================================================"
Write-Host ""
# #endregion