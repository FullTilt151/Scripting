#Load Required Assemblies
#[System.Reflection.Assembly]::LoadFrom( "C:\windows\system32\inetsrv\Microsoft.Web.Administration.dll" )
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration") | Out-Null
If ($PSVersionTable.PSVersion.Major -ge 2) {
    Import-Module WebAdministration
}
Else {
    Add-PSSnapin WebAdministration
}


#Log File
#$logFile = "F:\temp\IIS-App-Pools-SCCM-WMI.log"
$logFile = "$env:TEMP\IIS-App-Pools-SCCM-WMI.log"


#Delete previous log file
if((Test-Path -Path $logFile) -eq $true) {Remove-Item $logFile -Force}

#Get OS
Try {$OS = (Get-WmiObject -class Win32_OperatingSystem).Caption} Catch {$OS = "Unknown"}

#Grab timestamp
$dtStarted = [DateTime]::Now

## Define new class name and date
$NewClassName = 'Win32_IISAppPools_Custom'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
#AppPool - Basic Info
$newClass.Properties.Add("poolname", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("managedruntimeversion", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("managedpipelinemode", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("enable32bitapponwin64", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("queuelength", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("autostart", [System.Management.CimType]::String, $false)
#AppPool - Process Model Info
$newClass.Properties.Add("processmodelidentitytype", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("processmodelusername", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("processmodelidletimeout", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("processmodelloaduserprofile", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("processmodelmaxprocesses", [System.Management.CimType]::String, $false)
#AppPool - Recycle Info
$newClass.Properties.Add("recyclingmemory", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("recyclingprivatememory", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("recyclingrequests", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("recyclingtime", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("recyclingschedule", [System.Management.CimType]::String, $false)
#Apps
$newClass.Properties.Add("applist", [System.Management.CimType]::String, $false)
#Misc
$newClass.Properties.Add("os", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("notes", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)

$newClass.Properties["poolname"].Qualifiers.Add("Key", $true)
$newClass.Properties["recyclingtime"].Qualifiers.Add("Key", $true)
$newClass.Properties["recyclingschedule"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null


Try
{
    $ServerManager = New-Object Microsoft.Web.Administration.ServerManager
    if ($ServerManager.ApplicationPools.Count -gt 0)
    {
        #Compile dictionary key/value list of apps in each app pool
        $PoolsXSitesDict = @{}
        foreach ($Site in $ServerManager.Sites)
        {
            foreach ($App in $Site.Applications)
            {
                Try
                {
                    if ($PoolsXSitesDict.Contains($App.ApplicationPoolName))
                    {
                        $PoolsXSitesDict[$App.ApplicationPoolName] += "," + $Site.Name + $App.Path
                    }
                    Else
                    {
                        $PoolsXSitesDict.Add($App.ApplicationPoolName, $Site.Name + $App.Path)
                    }
                }
                Catch{}
            }
        }

        #Get information for each app pool
        foreach ($Pool in $ServerManager.ApplicationPools)
        {
            Try
            {
                #Enumerate static recycle schedules
                $RecyclingSchedule = ""
                if ($Pool.Recycling.PeriodicRestart.Schedule -ne $null)
                {
                    foreach ($Sched in $Pool.Recycling.PeriodicRestart.Schedule)
                    {
                        $RecyclingSchedule += $Sched.Time.ToString() + ","
                    }
                }
                $RecyclingSchedule = $RecyclingSchedule.TrimEnd(",")

                #Apps
                if ($PoolsXSitesDict.Contains($Pool.Name)) {$AppList = $PoolsXSitesDict[$Pool.Name]} else {$AppList = ""}

                #Insert to WMI
                Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
                    #AppPool - Basic Info
                    poolname = $Pool.Name;
                    managedruntimeversion = $Pool.ManagedRuntimeVersion.ToString();
                    managedpipelinemode = $Pool.ManagedPipelineMode.ToString();
                    enable32bitapponwin64 = $Pool.Enable32BitAppOnWin64.ToString();
                    queuelength = $Pool.QueueLength.ToString();
                    autostart = $Pool.AutoStart.ToString();

                    #AppPool - Process Model Info
                    processmodelidentitytype = $Pool.ProcessModel.IdentityType.ToString();
                    processmodelusername = $Pool.ProcessModel.UserName.ToString();
                    processmodelidletimeout = $Pool.ProcessModel.IdleTimeout.ToString();
                    processmodelloaduserprofile = $Pool.ProcessModel.LoadUserProfile.ToString();
                    processmodelmaxprocesses = $Pool.ProcessModel.MaxProcesses.ToString();

                    #AppPool - Recycle Info
                    recyclingmemory = $Pool.Recycling.PeriodicRestart.Memory.ToString();
                    recyclingprivatememory = $Pool.Recycling.PeriodicRestart.PrivateMemory.ToString();
                    recyclingrequests = $Pool.Recycling.PeriodicRestart.Requests.ToString();
                    recyclingtime = $Pool.Recycling.PeriodicRestart.Time.ToString();
                    recyclingschedule = $RecyclingSchedule;

                    #Apps
                    applist = $AppList;

                    #Misc
                    os = $OS;
                    notes = "";
                    ScriptLastRan = $Date

                 } | Out-Null

                 Add-Content $logFile "$((get-date).ToString("MM-dd-yyyy HH:mm:ss")) - Inserted: $($Pool.Name)"
            }
            Catch{}
        }
    }
    else
    {
        #Insert to WMI
        Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
            #AppPool - Basic Info
            poolname = "";
            managedruntimeversion = "";
            managedpipelinemode = "";
            enable32bitapponwin64 = "";
            queuelength = "";
            autostart = "";

            #AppPool - Process Model Info
            processmodelidentitytype = "";
            processmodelusername = "";
            processmodelidletimeout = "";
            processmodelloaduserprofile = "";
            processmodelmaxprocesses = "";

            #AppPool - Recycle Info
            recyclingmemory = "";
            recyclingprivatememory = "";
            recyclingrequests = "";
            recyclingtime = "";
            recyclingschedule = "";

            #Apps
            applist = "";

            #Misc
            os = $OS;
            notes = "No app pools found";
            ScriptLastRan = $Date
        } | Out-Null
    }

    $ServerManager.Dispose()
    $ServerManager = $null

}
Catch [System.Exception]
{             
    Try
    {
        #Write-Host "$((get-date).ToString("MM-dd-yyyy HH:mm:ss")) - $($_.Exception.Message.Trim())"
        #Write-Host "$((get-date).ToString("MM-dd-yyyy HH:mm:ss")) - $($_.Exception.ToString())"

        Add-Content $logFile "$((get-date).ToString("MM-dd-yyyy HH:mm:ss")) - $($_.Exception.Message.Trim())"
        Add-Content $logFile "$((get-date).ToString("MM-dd-yyyy HH:mm:ss")) - $($_.Exception.ToString())"
    }
    Catch{}
}
Finally
{
    # be sure to clean up after ourselves
    if ($ServerManager -ne $null) {$ServerManager.Dispose(); $ServerManager = $null}
    if ($SitesDict -ne $null) {$SitesDict.Clear(); $SitesDict = $null}
    if ($PoolsXSitesDict -ne $null) {$PoolsXSitesDict.Clear(); $PoolsXSitesDict = $null}
    Write-Output 'Complete'
}

<#
Write-Host "Time took: $(([DateTime]::Now - $dtStarted).TotalMinutes) minutes"

Add-Content $logFile "--------------------------------"
Add-Content $logFile "Time took: $(([DateTime]::Now - $dtStarted).TotalMinutes) minutes"

Write-Host "Log can be found at: $logFile"
#>

#-----------------------------------------------------------------------------------------------------------------------
#- Notes
#-----------------------------------------------------------------------------------------------------------------------

# This hung once:
#    Get-WmiObject -List Win32*
# when it got to:
#    Win32_LogicalShareAccess
#    Win32_IISAppPools_Custom


# To fix, remove class
#    $NewClassName = 'Win32_IISAppPools_Custom'
#    Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# To view:
#   Get-WmiObject -Class Win32_IISAppPools_Custom -Namespace root/cimv2
