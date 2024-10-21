$KBID = "KB # for uninstall"

function Remove-Update {

$HotFixes = Get-HotFix

foreach ($HotFix in $HotFixes)
{

    if ($KBID -eq $HotFix.HotfixId)
    {
        "Inside first if"
        $KBID = $HotFix.HotfixId.Replace("KB", "") 
        $RemovalCommand = "wusa.exe /uninstall /kb:$KBID /quiet /norestart"
        Write-Host "Removing $KBID from the target."
        Invoke-Expression $RemovalCommand
        break
    }
    
    if ($KBID -match "All")
    {
        $KBNumber = $HotFix.HotfixId.Replace("KB", "")
        $RemovalCommand = "wusa.exe /uninstall /kb:$KBNumber /quiet /norestart"
        Write-Host "Removing update $KBNumber from the target."
        Invoke-Expression $RemovalCommand
        
    }
    
    if ($KBID -match "Security")
    {
        if ($HotFix.Description -match "Security")
        {
        
            $KBSecurity = $HotFix.HotfixId.Replace("KB", "")
            $RemovalCommand = "wusa.exe /uninstall /kb:$KBSecurity /quiet /norestart"
            Write-Host "Removing Security Update $KBSecurity from the target."
            Invoke-Expression $RemovalCommand
        }
    }
    

    while (@(Get-Process wusa -ErrorAction SilentlyContinue).Count -ne 0)
    {
        Start-Sleep 3
        Write-Host "Waiting for update removal to finish ..."
    }
}

}

Remove-Update