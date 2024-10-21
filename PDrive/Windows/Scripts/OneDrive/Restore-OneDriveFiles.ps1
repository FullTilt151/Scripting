# Create Quick Access item for OneDrive Unmoved Files
$Path = "$env:LOCALAPPDATA\UnmovedFiles"
$QuickAccess = New-Object -ComObject shell.application
$TargetObject = $QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | Where-Object {$_.Path -eq "$Path"}
If ($null -ne $TargetObject){
    Write-Warning "Path is already pinned to Quick Access." | Out-File "c:\temp\RestoreOneDriveFiles_$env:USERNAME.log" -Append
} Else {
    "Adding UnmovedFiles to Quick Access..." | Out-File "c:\temp\RestoreOneDriveFiles_$env:USERNAME.log" -Append
    $QuickAccess.Namespace("$Path").Self.InvokeVerb(“pintohome”)
}

function Restore-OutlookArchives {
    # Restore Outlook Archives
    Add-type -assembly "Microsoft.Office.Interop.Outlook" | out-null
    $outlook = new-object -comobject outlook.application
    $namespace = $outlook.GetNameSpace("MAPI")
    $namespace.Stores | Where-Object {$_.Filepath -like 'c:\users\*\Documents\*.pst'} | 
    ForEach-Object {
        "Removing old entry for $($_.FilePath)..." | Out-File "c:\temp\RestoreOneDriveFiles_$env:USERNAME.log" -Append
        $namespace.RemoveStore($_.Filepath)
    }

    Get-ChildItem "$env:LOCALAPPDATA\UnmovedFiles" -Filter *.pst -Recurse | ForEach-Object {
        "Found $($_.FullName)..." | Out-File "c:\temp\RestoreOneDriveFiles_$env:USERNAME.log" -Append
        if ($_.FullName -notin ($namespace.Stores | Select-Object -ExpandProperty FilePath)) {
            "Reattaching $($_.Fullname)..." | Out-File "c:\temp\RestoreOneDriveFiles_$env:USERNAME.log" -Append
            $namespace.AddStore($_.FullName)
        }
    }
}