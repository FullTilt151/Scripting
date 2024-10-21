# My Processes for CRs

## Description
```
This is my first markdown file. I'm using to record the process of running my automation scripts, etc.
```
## Editing CR details from go/software.
```
1. Receive software, initialize folder (this creates the .ps1 files)
2. Change date required.
3. Input deployment method.
4. Input requirements, manual paths, etc.
5. Now ready to modify installation script.
```
## Modifying deployment script.
```
1. Run: C:\Users\MXC4183A\Repos\SCCM-PowerShell_Scripts\MXC4183\Scripts\Update-PSADTinfo.ps1. This takes 1 CR parameter, then updates the PSADT with today's date, my name and the CR#.
2. Make appropriate changes to the script.
3. Test the script manually with a test physical and VM.
```
## Creating MEMCM package and testing deployments.
```
1. Run: C:\Users\MXC4183A\Repos\SCCM-PowerShell_Scripts\MXC4183\Scripts\Create-MEMCMPackage.ps1. Script will prompt for what's needed and create everything.
2. From a test machine, open Software Center and run script.
3. Modify/fix if needed.
```

## Finalizing CR details.

```
Typically the CR already has a previous version approved, I use the previous tracking as a base for the new CR.
1. Find previous version approved CR #.
2. Open SQL Server Studio.
3. Connect to scdddb.humana.com > ATScertreq database.
4. Run: \\lounaswps08\pdrive\workarea\mxc4183\SQL_Queries\Get-Priortracking.sql. Add the previous CR#.
5. Copy/Paste the sql info into the web form. Make the appropriate changes.
6. Add MEMCM package via the web form. (Create-MEMCMPackage.ps1 will output this or you can use the console.)
7. Finish up (Add UAT info, pre-reqs, etc) and submit for approval.
8. Done.