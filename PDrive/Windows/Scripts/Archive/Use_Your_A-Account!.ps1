# ==============================================================================================
# 
# NAME: Use Your "A" Account! 
# AUTHOR: Derek Horn, Humana Inc.
# DATE  : 01/05/2012
# 
# ==============================================================================================

$cred = Get-Credential

Write-Host " "
Write-Host "This script will allow you to run various programs with your 'A' account." -ForegroundColor Green
Write-Host " "

Function Menu {
Write-Host " "
Write-Host " "
Write-Host "Which application would you like to start?" -ForegroundColor DarkGreen
Write-Host "1. DSM Explorer" -ForegroundColor DarkCyan
Write-Host "2. SCCM Console" -ForegroundColor DarkCyan
Write-Host "3. MSTSC" -ForegroundColor DarkCyan
Write-Host "4. COMPMGMT"  -ForegroundColor DarkCyan
Write-Host "5. Browse Remote PC"  -ForegroundColor DarkCyan
Write-Host "6. ReType Your Credentials" -ForegroundColor DarkCyan
Write-Host "7. Quit" -ForegroundColor DarkCyan
Write-Host " "
$a = Read-Host "Select 1-5: "

Write-Host " "
 
switch ($a) 
    { 
        1 {
           Write-Host ** Loading DSM ** -ForegroundColor Red
           Write-Host " "
           C:
           Start-Process DSMGUI profile:DSM -Credential $cred
           Start-Sleep -Milliseconds 500
           cls
          } 
       2 {
           Write-Host ** Loading SCCM Console ** -ForegroundColor Red
           Write-Host " "
           cd 'C:\Program Files (x86)\Configuration manager 2007\AdminUI\bin\'
           Start-Process MMC adminconsole.msc -Credential $cred
           Start-Sleep -Milliseconds 500
           cls
          } 
        3 {
           Write-Host ** Loading Remote Desktop Client ** -ForegroundColor Red
           Write-Host " "
           $WKID_MSTSC = Read-Host "What PC would you like to connect to?"
           C:
           Start-Process mstsc /v:$WKID_MSTSC -Credential $cred
           Start-Sleep -Milliseconds 500
           cls
          }
        4 {
           Write-Host ** Loading Computer Management ** -ForegroundColor Red
           Write-Host " "
           $WKID_COMPMGMT = Read-Host "What PC would you like to connect to?"
           C:
           Start-Process MMC "compmgmt.msc /computer=$WKID_COMPMGMT" -Credential $cred
           Start-Sleep -Milliseconds 500
           cls
          } 
        5 {
           Write-Host ** Remote PC Browsing ** -ForegroundColor Red
           Write-Host " "
           $WKID_MSTSC = Read-Host "What PC would you like to browse to?"
           C:
           Write-Host "April Fools.  This isn't working yet."  -ForegroundColor Cyan
           Start-Sleep -Milliseconds 500
           Write-Host "Press any key to continue ..."  -ForegroundColor DarkCyan
           $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

           cls
          }
        6 {
           Write-Host ** You Should Learn to Type More Accurately ** -ForegroundColor Red
           Start-Sleep -Milliseconds 500
           Write-Host ** You Should Learn to Type More Accurately ** -ForegroundColor Red
           Start-Sleep -Milliseconds 500
           Write-Host ** You Should Learn to Type More Accurately ** -ForegroundColor Red
           Start-Sleep -Milliseconds 500
           Write-Host ** You Should Learn to Type More Accurately ** -ForegroundColor Red
           Start-Sleep -Milliseconds 500
           Write-Host ** You Should Learn to Type More Accurately ** -ForegroundColor Red
           Start-Sleep -Milliseconds 500
           $cred = Get-Credential
           Start-Sleep -Milliseconds 500
           cls
          } 
        7 {
           Start-Sleep -Milliseconds 500
           Write-Host "3..."
           Start-Sleep -Milliseconds 500
           Write-Host "2..."
           Start-Sleep -Milliseconds 500
           Write-Host "1..."
           Start-Sleep -Milliseconds 500
           Write-Host "*Goodbye*"
           Start-Sleep -Milliseconds 500
           exit
          } 
        default {
          "** Invalid Selection **";
          break;
          }
    }
}

Do {Menu} until (Exit-PSSession)
