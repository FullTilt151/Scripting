function Set-PFEWebServiceACL {
    <#
    .SYNOPSIS
        Used to set the ACL if the PFE client healthweb service is used
    .DESCRIPTION
        Sets the ACL on the appropriate folders for the service account specified when the PFE Client Health Web Service is implemented
    .EXAMPLE
        PS C:\> Set-PFEWebServiceACL -ServiceAccount 'humad\sccm_cli_connect'
        Sets the ACLs to add 'humad\sccm_cli_connect' with write, readandexecute, synchronize permissions
    .NOTES
        The service account should be non-privelaged
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServiceAccount
    )
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($ServiceAccount, "Write, ReadAndExecute, Synchronize", "ContainerInherit,Objectinherit", "none", "Allow")

    $PFEIncoming = Join-Path -Path (Split-Path -Path $env:SMS_LOG_PATH -Parent) -ChildPath 'PFE\PFEIncoming$'

    $Folders = @(
        'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\Temporary ASP.NET Files', 
        'C:\Windows\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files', 
        $PFEIncoming
    )

    foreach ($Folder in $Folders) {
        $ACL = Get-Acl -Path $Folder
        $ACL.AddAccessRule($AccessRule)
        $ACL | Set-Acl -Path $Folder
    }
}