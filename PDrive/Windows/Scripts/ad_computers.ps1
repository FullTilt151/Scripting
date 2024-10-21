import-module activedirectory
New-PSDrive -name HUMAD -psProvider ActiveDirectory -root "" -server humad.com
set-location AD:
Get-ADcomputer -filter * -properties name,distinguishedname,enabled | select name,dnshostname,distinguishedname,enabled | export-csv e:\adcomputers.csv -notypeinformation