param(# Parameter help description
[switch]$MoveOneNoteFiles
)

# This script will move out invalid file types/files and folders with invalid characters/names to a different folder
# in order to prepare the known folders for OneDrive Protection

# Setting up known folder variables
[string]$DesktopPath = ""
[string]$DocumentsPath = ""
[string]$PicturesPath = ""
[string]$TargetPath = ""
[string]$TargetPathEnd = "\AppData\Local\UnmovedFiles"
[string]$OneNoteNotebookFolder = "OneNote Notebooks"

$key1 = "HKU:\"
$key2 = "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
$cameraroll = "{AB5FB87B-7CE2-4F83-915D-550846C9537B}"
$screenshots = "{B7BEDE81-DF94-4682-A7D8-57A52620B86F}"
$camerarollbool = $false
$screenshotsbool = $false
$camera = ""
$screenshot = ""

# Setting up log file variables
[string]$LogFile = ""
[string]$ErrorLogFile = ""
[string]$IssueLogFile = ""

# Arrays of bad stuff
if ($MoveOneNoteFiles) {
    $extensionsArr = ".pst", ".one", ".onepkg", ".onetoc", ".onetoc2"
} else {
    $extensionsArr = ".pst"
}

$invalidCharsArr = '"', "*", ":", "<", ">", "?", "/", "\", "|" #, "#"
$invalidNames = ".lock", "CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9", "_vti_", "desktop.ini" #, "TEST"

# Function used to write to the log file
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $LogFile -value $logstring
}

# Function used to write to the error log file
Function ErrorLogWrite
{
   Param ([string]$logstring)

   Add-content $ErrorLogFile -value $logstring
}

# Function used to write to the issues log file
Function IssuesLogWrite
{
   Param ([string]$logstring)

   Add-content $IssueLogFile -value $logstring
}

# Function used to cycle through a folder and move items as needed
Function FolderCycler
{
   Param (
   [string]$TestPath,
   [bool]$DocsFolder)

   LogWrite("##############################")
   LogWrite("Processing folder " + $TestPath)
   if (Test-Path -path $TestPath) {        
        $outputFolder = Split-Path $TestPath -leaf
        $TargetFolder = Join-Path $TargetPath $outputFolder
        if (!(Test-Path -path $TargetFolder)) { New-Item -type directory -path $TargetFolder }

        # Move OneNote Notebooks Folder First
        if ($DocsFolder) {
            $OneNotePath = $TestPath + "\" + $OneNoteNotebookFolder
            if ((Test-Path -path $OneNotePath) -and $MoveOneNoteFiles) {
                LogWrite('Moving OneNote files...')
                $OneNoteMove = $TargetFolder + "\" + $OneNoteNotebookFolder
                Move-Item $OneNotePath $OneNoteMove
            } else {
                LogWrite('Not Moving OneNote Files...')
            }
        }

        foreach ($file in Get-ChildItem -Path $TestPath -Recurse | Where-Object { $extensionsArr -contains $_.extension -or $invalidNames -contains $_.Name }) {
            LogWrite("Processing " + $file.FullName)

            $TargetFolderN = $TargetFolder

            if ($file.extension -ne ".pst") {
                $directory = $file.Directory.Name
                $newdirpath = Join-Path $TargetFolder $directory
                if (Test-Path -Path $newdirpath) {
                    $TargetFolderN = $newdirpath
                } else {
                    # new-item -Name $newdirpath -ItemType directory
                    New-Item -type directory -path $newdirpath
                    if (!$?) {
                        LogWrite("ERROR: $($newdirpath) could not be created.")
                        ErrorLogWrite("ERROR: $($newdirpath) could not be created.")
                    }
                    else {
                        LogWrite("$($newdirpath) was created successfully.")
                        $TargetFolderN = $newdirpath
                    }
                }
            }

            $namechanged = $false
            $num = 1
            $nextName = Join-Path -Path $TargetFolderN -ChildPath $file.name
            while(Test-Path -Path $nextName)
            {
                $namechanged = $true
                $nextName = Join-Path $TargetFolderN ($file.BaseName + " ($num)" + $file.Extension)    
                $num+=1   
            }
            Move-Item -LiteralPath $file.FullName -Destination $nextName -Force
            if (!$?) {
                LogWrite("ERROR: $($file.FullName) could not be moved.")
                ErrorLogWrite("ERROR: $($file.FullName) could not be moved.")
            }
            else {
                if ($namechanged) {
                    LogWrite("$($file.FullName) was moved successfully but was renamed to $($nextName).")
                } else {
                    LogWrite("$($file.FullName) was moved successfully.")
                }
            }
        }

        foreach ($file in Get-ChildItem -Path $TestPath -Recurse) {
            if ($file -is [System.IO.FileInfo]) {
                if ($file.Name.StartsWith("~$")) {
                    LogWrite("Processing " + $file.FullName)
                    $namechanged = $false
                    $num = 1
                    $nextName = Join-Path -Path $TargetFolder -ChildPath $file.name
                    while(Test-Path -Path $nextName)
                    {
                        $namechanged = $true
                        $nextName = Join-Path $TargetFolder ($file.BaseName + " ($num)" + $file.Extension)    
                        $num+=1   
                    }
                    Move-Item -LiteralPath $file.FullName -Destination $nextName -Force
                    if (!$?) {
                        LogWrite("ERROR: $($file.FullName) could not be moved.")
                        ErrorLogWrite("ERROR: $($file.FullName) could not be moved.")
                    }
                    else {
                        if ($namechanged) {
                            LogWrite("$($file.FullName) was moved successfully but was renamed to $($nextName).")
                        } else {
                            LogWrite("$($file.FullName) was moved successfully.")
                        }
                    }
                    break
                }
            }       
            $invalidCharsArr | ForEach-Object {
                if ($file.Name.IndexOf($_) -ge 0) {
                    LogWrite("Processing " + $file.FullName)
                    $namechanged = $false
                    $num = 1
                    $nextName = Join-Path -Path $TargetFolder -ChildPath $file.name
                    while(Test-Path -Path $nextName)
                    {
                        $namechanged = $true
                        $nextName = Join-Path $TargetFolder ($file.BaseName + " ($num)" + $file.Extension)    
                        $num+=1   
                    }
                    Move-Item -LiteralPath $file.FullName -Destination $nextName -Force
                    if (!$?) {
                        LogWrite("ERROR: $($file.FullName) could not be moved.")
                        ErrorLogWrite("ERROR: $($file.FullName) could not be moved.")
                    }
                    else {
                        if ($namechanged) {
                            LogWrite("$($file.FullName) was moved successfully but was renamed to $($nextName).")
                        } else {
                            LogWrite("$($file.FullName) was moved successfully.")
                        }
                    }
                    break
                }
            }
        }
        LogWrite("Done processing folder " + $TestPath)
        LogWrite("##############################")
        LogWrite("")
   }
   else {
        LogWrite("Folder " + $TestPath + " was not processed as it could not be found.")
        ErrorLogWrite("Folder " + $TestPath + " was not processed as it could not be found.")
   }
}

# Function to check if onedrive and knownfolders are on same volume
Function SameVolumeCheck
{

   $onedrivepath = $env:onedrive
   $onedrivevolume = Split-Path -Path $onedrivepath -Qualifier
   $desktopvolume = Split-Path -Path $DesktopPath -Qualifier
   $documentsvolume = Split-Path -Path $DocumentsPath -Qualifier
   $picturesvolume = Split-Path -Path $PicturesPath -Qualifier
   Write-Output $onedrivevolume
   Write-Output $desktopvolume
   Write-Output $documentsvolume
   Write-Output $picturesvolume
   if (($onedrivevolume -eq $desktopvolume) -and ($onedrivevolume -eq $documentsvolume) -and ($onedrivevolume -eq $picturesvolume)) {
        IssuesLogWrite("Known folders are on the same volume as the OneDrive folder.")
        IssuesLogWrite("Desktop on:$($desktopvolume)  Documents on:$($documentsvolume)  Pictures on:$($picturesvolume)  OneDrive on:$($onedrivevolume)")
   }
   else {
        IssuesLogWrite("ISSUE: Known folder(s) is on a different volume than the OneDrive folder.")
        IssuesLogWrite("Desktop on:$($desktopvolume)  Documents on:$($documentsvolume)  Pictures on:$($picturesvolume)  OneDrive on:$($onedrivevolume)")
   }
}

# Function to check if any files exceeds the maximum path length
Function MaxPath
{
   Param ([string]$TestPath)

   LogWrite("Checking folder: $($TestPath)")
   if (Test-Path -LiteralPath $TestPath) {  
        $outputFolder = Split-Path $TestPath -leaf
        $TargetFolder = Join-Path $TargetPath $outputFolder
        if (!(Test-Path -LiteralPath $TargetFolder)) { New-Item -type directory -path $TargetFolder }
             
        foreach ($file in Get-ChildItem -LiteralPath $TestPath -Recurse) {
            if ($file.FullName.Length -gt 520) {
                LogWrite("ISSUE: $($file.FullName) exceeds the path length limit.")
                Move-Item -LiteralPath $file.FullName -Destination $TargetFolder -Force
                if (!$?) {
                    LogWrite("ERROR: $($file.FullName) could not be moved.")
                    ErrorLogWrite("ERROR: $($file.FullName) could not be moved.")
                }
                else {
                    LogWrite("$($file.FullName) was moved successfully.")
                }
            }
            if ($file -is [System.IO.FileInfo]) {
                if ($file.length -gt 15gb) {
                    LogWrite("ISSUE: $($file.FullName) exceeds the size limit of 15gb.")
                    Move-Item -LiteralPath $file.FullName -Destination $TargetFolder -Force
                    if (!$?) {
                        LogWrite("ERROR: $($file.FullName) could not be moved.")
                        ErrorLogWrite("ERROR: $($file.FullName) could not be moved.")
                    }
                    else {
                        LogWrite("$($file.FullName) was moved successfully.")
                    }
                }
            }
        }  
   }
}

# Check maximum path length for known folders
Function MaxPathCheck
{
    LogWrite("##############################")
    LogWrite("Checking max path length and file size for known folders.")
    LogWrite("")
    MaxPath($DesktopPath)
    MaxPath($DocumentsPath)
    MaxPath($PicturesPath)
    if ($screenshotsbool) {
        MaxPath($screenshot)
    }
    if ($camerarollbool) {
        MaxPath($camera)
    }
    LogWrite("##############################")
    LogWrite("")
}

# Check default location
Function DefaultLocationCheck
{
    $defaultloc = ":\users\$env:username\"
    if (!$DesktopPath.Contains($defaultloc)) {
        IssuesLogWrite("ISSUE: $($DesktopPath) is not in its default location.")
    }
    if (!$DocumentsPath.Contains($defaultloc)) {
        IssuesLogWrite("ISSUE: $($DesktopPath) is not in its default location.")
    }
    if (!$PicturesPath.Contains($defaultloc)) {
        IssuesLogWrite("ISSUE: $($DesktopPath) is not in its default location.")
    }
}


# Check reg key exists
function Test-PathReg
{
    param
    (
    [Parameter(mandatory=$true,position=0)]
    [string]$Path
    ,
    [Parameter(mandatory=$true,position=1)]
    [string]$Property
    )

    $compare = (Get-ItemProperty -LiteralPath $Path).psbase.members | foreach-object {$_.name} | Compare-Object $Property -IncludeEqual -ExcludeDifferent
    if($compare.SideIndicator -like "==") 
    {
        return $true
    }
    else
    {
        return $false
    }
}

# function to create a shortcut
Function New-Shortcut {
    <#
    .SYNOPSIS
        Creates a new .lnk or .url type shortcut
    .DESCRIPTION
        Creates a new shortcut .lnk or .url file, with configurable options
    .PARAMETER Path
        Path to save the shortcut
    .PARAMETER TargetPath
        Target path or URL that the shortcut launches
    .EXAMPLE
        New-Shortcut -Path "$envProgramData\Microsoft\Windows\Start Menu\My Shortcut.lnk" -TargetPath "$envWinDir\system32\notepad.exe" 
    .NOTES
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]$TargetPath
    )
    If (-not $Shell) {
        [__comobject]$Shell = New-Object -ComObject 'WScript.Shell' -ErrorAction 'Stop' 
    }

    Try {
        [IO.FileInfo]$Path = [IO.FileInfo]$Path
        [string]$PathDirectory = $Path.DirectoryName
                    
        If (-not (Test-Path -LiteralPath $PathDirectory -PathType 'Container' -ErrorAction 'Stop')) {
            $null = New-Item -Path $PathDirectory -ItemType 'Directory' -Force -ErrorAction 'Stop'
        }
    }
    Catch {
        Throw
    }
    If (($path.FullName).ToLower().EndsWith('.url')) {
        [string[]]$URLFile = '[InternetShortcut]'
        $URLFile += "URL=$targetPath"
        If ($iconIndex) {
            $URLFile += "IconIndex=$iconIndex" 
        }
        If ($IconLocation) {
            $URLFile += "IconFile=$iconLocation" 
        }
        $URLFile | Out-File -FilePath $path.FullName -Force -Encoding 'default' -ErrorAction 'Stop'
    }
    ElseIf (($path.FullName).ToLower().EndsWith('.lnk')) {
        $shortcut = $shell.CreateShortcut($path.FullName)
        $shortcut.TargetPath = $targetPath
        $shortcut.Save()
    }
}

# Need to add drive for HKU since does not exist by default
# please note that: 
# Temporary drives exist only in the current PowerShell session and in sessions that you create in the current session.
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
$UserProfiles = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Where-Object {$_.PSChildName -match "S-1-5-21-(\d+-?){4}$" } | Select-Object @{Name="SID"; Expression={$_.PSChildName}}, @{Name="Path"; Expression={$_.ProfileImagePath}}, @{Name="UserHive";Expression={"$($_.ProfileImagePath)\NTuser.dat"}}
Write-Output $UserProfiles
# New-Shortcut -Path "c:\_UnmovedFiles.lnk" -TargetPath '%localappdata%\UnmovedFiles'

# loop through each profile
foreach ($UserProfile in $UserProfiles)
{
    # reset all to blank
    $DesktopPath = ""
    $DocumentsPath = ""
    $PicturesPath = ""
    $TargetPath = ""
    $camerarollbool = $false
    $screenshotsbool = $false
    $camera = ""
    $screenshot = ""
    $key = ""

    $TargetPath = $UserProfile.Path + $TargetPathEnd

    # Setting up log file variables
    $LogFile = Join-Path $TargetPath "logfile.log"
    $ErrorLogFile = Join-Path $TargetPath "error.log"
    $IssueLogFile = Join-Path $TargetPath "issue.log"

    # Ensure target folder which files will be moved to exists
    if (!(Test-Path -path $TargetPath)) { New-Item -type directory -path $TargetPath }
    # Ensure log files exist
    if (!(Test-Path -path $LogFile)) { New-Item -type file -path $LogFile }
    if (!(Test-Path -path $ErrorLogFile)) { New-Item -type file -path $ErrorLogFile }
    if (!(Test-Path -path $IssueLogFile)) { New-Item -type file -path $IssueLogFile }


    # Logging to log files start of script
    LogWrite("##################################################################################")
    LogWrite("Preparing Windows known folders for OneDrive setup.  Start time is: $((Get-Date).ToString())")
    LogWrite("")
    ErrorLogWrite("##################################################################################")
    ErrorLogWrite("Preparing Windows known folders for OneDrive setup.  Start time is: $((Get-Date).ToString())")
    ErrorLogWrite("")
    IssuesLogWrite("##################################################################################")
    IssuesLogWrite("Preparing Windows known folders for OneDrive setup.  Start time is: $((Get-Date).ToString())")
    IssuesLogWrite("")


    If (($ProfileLoaded = Test-Path Registry::HKU\$($UserProfile.SID)) -eq $false) {
        $hive = "HKU\" + $UserProfile.SID
        reg.exe load $hive $UserProfile.UserHive
    }

    # Create full key with SID
    $key = $key1 + $UserProfile.SID + $key2
    Write-Output $hive
    #echo $TargetPath

    # Get My Documents location
    if (Test-PathReg -Path $key -Property "Personal") {
        $DocumentsPath = (Get-ItemProperty -Path $key -Name "Personal")."Personal".Replace($env:userprofile,$UserProfile.Path)
        #echo $DocumentsPath
        FolderCycler($DocumentsPath) ($TRUE)
    }

    # Get Desktop location
    if (Test-PathReg -Path $key -Property "Desktop") {
        $DesktopPath = (Get-ItemProperty -Path $key -Name "Desktop")."Desktop".Replace($env:userprofile,$UserProfile.Path)
        #echo $DesktopPath
        FolderCycler($DesktopPath)
    }

    # Get My Pictures location
    if (Test-PathReg -Path $key -Property "My Pictures") {
        $PicturesPath = (Get-ItemProperty -Path $key -Name "My Pictures")."My Pictures".Replace($env:userprofile,$UserProfile.Path)
        #echo $PicturesPath
        FolderCycler($PicturesPath)
    }

    # Check if camera roll is not in default location
    if (Test-PathReg -Path $key -Property $cameraroll) {
        $camerarollbool = $true
        $camera = (Get-ItemProperty -Path $key -Name $cameraroll).$cameraroll.Replace($env:userprofile,$UserProfile.Path)
        FolderCycler($camera)
    }

    # Check if screenshots is not in default location
    if (Test-PathReg -Path $key -Property $screenshots) {
        $screenshotsbool = $true
        $screenshot = (Get-ItemProperty -Path $key -Name $screenshots).$screenshots.Replace($env:userprofile,$UserProfile.Path)
        FolderCycler($screenshot)
    }

    #SameVolumeCheck
    MaxPathCheck
    
    # Setup restore of Outlook archives and add QuickAccess link
    $Explorer = (Get-WmiObject win32_process -Filter "Name = 'explorer.exe'" -ErrorAction SilentlyContinue)
    LogWrite('Verifying logged on user...')
    if ($null -ne $Explorer) {
        $LoggedOnDomain = $Explorer.GetOwner().Domain
        $LoggedOnUser = $Explorer.GetOwner().User
        LogWrite("$LoggedonDomain\$LoggedOnUser is logged on.")
    } else {
        LogWrite('No user currently logged on.')
    }
    
    LogWrite("Placing desktop shortcut to UnmovedFiles for $userprofile...")
    New-Shortcut -Path "$($UserProfile.Path)\Desktop\UnmovedFiles.lnk" -TargetPath $TargetPath

    if ($null -eq $LoggedOnUser) {
        LogWrite('Verifying if Outlook profiles are setup...')
        if ($null -ne (Get-ChildItem "$hive\Software\Microsoft\Office\16.0\Outlook\Profiles" -ErrorAction SilentlyContinue)) {
            LogWrite("$hive - Outlook profiles found! Setting runonce key to restore PSTs.")
            Set-ItemProperty -Path "$hive\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name AddPSTs -Value 'c:\windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -noprofile -windowstyle hidden -file "C:\temp\Restore-OnedriveFiles.ps1"'
        } else {
            LogWrite("$hive - No Outlook profiles found!")
        }
    } else {
        LogWrite("$LoggedonUser - Checking if scheduled task exists...")
        $taskname = "Restore OneDrive Files - $LoggedOnUser"
        LogWrite("$LoggedonUser - Creating scheduled task...")
        $action = New-ScheduledTaskAction -Execute 'c:\windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe' -Argument '-executionpolicy bypass -noprofile -windowstyle hidden -file "C:\temp\Restore-OnedriveFiles.ps1"'
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(30)
        $principal = New-ScheduledTaskPrincipal -UserId "$LoggedOnDomain\$LoggedonUser"
        $Settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
        Register-ScheduledTask -TaskName $taskname -Action $action -Trigger $trigger -Principal $principal -Settings $Settings

        $TargetTask = Get-ScheduledTask -TaskName $taskname
        $TargetTask.Triggers[0].EndBoundary = [DateTime]::Now.AddMinutes(15).ToString("yyyy-MM-dd'T'HH:mm:ss")
        $TargetTask.Settings.DeleteExpiredTaskAfter = 'PT0S'
        $TargetTask | Set-ScheduledTask
        LogWrite("$loggedonuser - Created scheduled task.")
    }

    if ($ProfileLoaded -eq $false) {
        reg.exe unload $hive
    }
}

LogWrite('Copying Restore-OneDriveFiles.ps1 to c:\temp...')
Copy-Item .\Restore-OneDriveFiles.ps1 -Destination c:\temp -Force -Verbose
LogWrite('Restore of OneDrive files complete!')