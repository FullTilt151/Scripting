#Backup current log and opy Humana logo. NOTE: Change the server names for each env.
$OldServer = 'LOUAPPWTS1047.rsc.humad.com\D$\Program Files (x86)\1E\Shopping\WebSite\Shopping'
$NewServer = 'LOUAPPWTL112S01.rsc.humad.com\D$\Program Files (x86)\1E\Shopping\WebSite\Shopping'

#Backup current logo and copy Humana logo.
    Rename-Item -Path "\\$Newserver\Assets\Uploads\Images\logo.png" -NewName "logo.bck"
    Copy-Item "\\$Oldserver\Assets\Uploads\Images\logotst.png" -destination "\\$Newserver\D$\Program Files (x86)\1E\Shopping\WebSite\Shopping\Assets\Uploads\Images\logo.png"

#Backup and adjust filesize of log to fix stretching.
#Rename-Item -Path "\\$Newserver\Views\Shared\_LayoutBase.cshtml" -NewName "_LayoutBase.bak"
Copy-Item -Path "\\$Newserver\Views\Shared\_LayoutBase.cshtml" -Destination "\\$Newserver\Views\Shared\_LayoutBase.bak"
(Get-Content -Path "\\$Newserver\Views\Shared\_LayoutBase.cshtml").Replace('width="56" height="36" alt="1E"','width="66" height="26" alt="CIT Rocks"') | Set-Content "\\$Newserver\Views\Shared\_LayoutBase.cshtml"


#Backup and modify custom.css file.
Copy-Item -Path "\\$Newserver\Assets\css\custom.css" -Destination "\\$Newserver\Assets\css\custom.bak"

Get-ChildItem -Path "\\$Newserver\Assets\css"

Add-Content c:\scripts\test.txt "The End"