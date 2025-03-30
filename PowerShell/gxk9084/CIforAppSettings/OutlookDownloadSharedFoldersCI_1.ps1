New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction Ignore
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\windows NT\CurrentVersion\profilelist' -Name | ForEach-Object {
    $key = "HKU:\$_\Software\Policies\Microsoft\office\16.0\outlook\cached mode"
    #If (Test-Path $key){
    If (Test-Path $key){
    #Write-output $key
        #If 
        If (Get-ItemProperty $key DownloadSharedFolders -ErrorAction SilentlyContinue){
        Write-output $key exists
        Remove-ItemProperty $key DownloadSharedFolders}
        #    $Remediate = True
         #   }
        }
}
   
  

