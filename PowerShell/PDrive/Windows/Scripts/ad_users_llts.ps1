import-module activedirectory
New-PSDrive -name HUMAD -psProvider ActiveDirectory -root "" -server humad.com
set-location AD:
Get-ADUser -filter * -properties name,samaccountname,distinguishedname,enabled,lastlogontimestamp | select name,samaccountname,distinguishedname,enabled,@{n="LastLogonTimeStamp";e={[DateTime]::FromFileTime($_.LastLogonTimestamp)}} | export-csv e:\adusers.csv -notypeinformation