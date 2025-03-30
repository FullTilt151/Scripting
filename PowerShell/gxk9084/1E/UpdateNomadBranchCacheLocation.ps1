Function ChangeLocalCachePath {
    If((Get-ItemProperty -Path HKLM:\Software\1e\NomadBranch -Name LocalCachePath).LocalCachePath -ne 'D:\NomadCache\') {     
        Try {
            Add-Content $NomadCacheLog "$(Get-Date) Updating NomadBranch LocalCachePath in registry"
            New-ItemProperty HKLM:\Software\1e\NomadBranch -Name LocalCachePath -Value D:\NomadCache\ -PropertyType string -Force | Out-Null
             }
             Catch {
                    $SetErrorMessage = $_.Exception.Message
                    Add-Content $NomadCacheLog "$(Get-Date) Error updating NomadBranch LocalCachePath in registry"
                    Add-Content $NomadCacheLog "$(Get-Date) $SetErrorMessage"
            exit
             }
       }
       else {
             Add-Content $NomadCacheLog "$(Get-Date) NomadBranch LocalCachePath entry already set to: D:\NomadCache\"
       }
} 
