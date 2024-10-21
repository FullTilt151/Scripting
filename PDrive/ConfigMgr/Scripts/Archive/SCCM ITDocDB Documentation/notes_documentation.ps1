if ([IntPtr]::size -ne 4) {
    write-host "***ERROR*** You are running x64 PowerShell! ***ERROR***" -foregroundcolor red -backgroundcolor black
    write-host ""
    write-host "***Please open the x86 PowerShell Console!***" -foregroundcolor red -backgroundcolor black
    read-host
    exit
}

write-host "-------------------------------------------------------" -foregroundcolor cyan -backgroundcolor black
write-host "This script connects to a specified SCCM 2007 Site and displays package and task sequence information information." -foregroundcolor cyan
write-host "-------------------------------------------------------" -foregroundcolor cyan -backgroundcolor black
write-host ""

$siteserver = "LOUAPPWTS207"
$sitecode = "ATS"
$pkgid = ""
$pkgtitle = ""
$user = $env:username
$date = get-date

write-host "Currently running as: " -foregroundcolor cyan -nonewline; write-host $user -foregroundcolor green
write-host ""
if ($user -notlike "*a") {
    write-host "***ERROR*** Not running as 'A' account, do not have access to query SCCM server! "-foregroundcolor red -backgroundcolor black
    read-host "Press any key to exit"
    exit
}
write-host ""

import-module .\SCCM_2007.psm1

write-host "Site: " -foregroundcolor cyan -nonewline; write-host $sitecode
write-host "Site Server: " -foregroundcolor cyan -nonewline; write-host $siteserver
write-host ""

connect-sccmserver -server $siteserver -sitecode $sitecode

write-host "Enter your CR#: " -foregroundcolor cyan -nonewline
$crnumber = read-host
write-host ""
write-host "Querying SharePoint..." -foregroundcolor cyan

$db = "http://workspaces.humana.com/sites/atsdocdb/"
$list = "{78E4F00E-098D-40B4-BCEF-7532169EF5C8}"

$connString = "Provider=Microsoft.ACE.OLEDB.12.0;WSS;IMEX=2;RetrieveIds=Yes; DATABASE=$db;LIST=$list;"
$spConn = new-object System.Data.OleDb.OleDbConnection($connString)
$spConn.open()
$qry="Select * from list"
$cmd = new-object System.Data.OleDb.OleDbCommand($qry,$spConn)
$adapter = new-object System.Data.OleDb.OleDbDataAdapter($cmd)
$sptable = new-object System.Data.dataTable
$adapter.fill($sptable) > $null
$crinfo = $sptable | where{$_.id -eq $crnumber}

if ($crinfo."client/server".contains("Windows XP") -and $crinfo."client/server".contains("Windows 7")) {
    $osinfo = "Windows XP/Windows 7"
    $osshort = "XP x86/Win7 x64"
} elseif ($crinfo."client/server".contains("Windows 7")) {
    $osinfo = "Windows 7"
    $osshort = "Win7 x64"
} elseif ($crinfo."client/server".contains("Windows XP")) {
    $osinfo = "Windows XP"
    $osshort = "XP x86"
}

$packages = get-sccmpackage | select packageid
$pkgid = $crinfo.SCCMTESTPKGID

#if ($packages -contains $crinfo.SCCMTESTPKGID) {
#  $pkgid = $crinfo.SCCMTESTPKGID
#} else {
#   write-host ""
#   write-host "Please fill out the SCCMTESTPKGID in your SharePoint Certification request!" -foregroundcolor red
#   read-host
#   exit
#}

$pkg = get-sccmpackage | select manufacturer, name, version, packageid, packagetype, pkgsourcepath | where{$_.packageid -eq $pkgid}
$pkgtitle = $pkg.manufacturer + " " + $pkg.name + " " + $pkg.version

if ($pkg.packagetype -eq 0) {
    $pkgtype = "Legacy" 
} elseif ($pkg.packagetype -eq 7) {
    $pkgtype = "App-V"
} else {
    $pkgtype = "Unknown"
}

if ($crinfo."Installation Method" -eq "Microsoft SCCM") {
  $subinstall = "SCCM Install - "
} elseif ($crinfo."Installation Method" -eq "Microsoft App-V") {
  $subinstall = "App-V Install - "
}

$subtitle = $subinstall + $osinfo

if ($user.substring($user.length-1 -eq "a")){
  $userloc = $user.substring(0,$user.length-1)
} else {
  $userloc = $user
}

$pkgloc="Packages\ATS\" + $userloc

write-host "Creating Word Doc template..." -foregroundcolor cyan

$savepath="C:\temp\MyDoc.docx"

$word=new-object -ComObject "Word.Application"
$word.Visible=$True
$doc=$word.documents.Add()
$selection=$word.Selection

$selection.Style="Title"
$selection.TypeText("Documentation Template")

$selection.TypeParagraph()
$selection.Style="Heading 1"
$selection.TypeText("Document Information")

$selection.TypeParagraph()
$selection.Style="No Spacing"
$selection.borders.insidelinestyle=1
$selection.borders.outsidelinestyle=1

$selection.Font.Color="wdColorblack"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("Certification Request Number: ")
$selection.Font.Bold=$false
$selection.TypeText($crnumber)
$selection.TypeParagraph()
$selection.Font.Bold=$true
$selection.TypeText("Product: ")
$selection.Font.Bold=$false
$selection.TypeText($crinfo."Product Title" + " " + $osshort)

$selection.TypeParagraph()
$selection.Font.Color="wdColorblack"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("Subtitle: ")
$selection.Font.Color="wdColorblack"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$false
$selection.TypeText($subtitle)

$selection.TypeParagraph()
$selection.Style="Heading 1"
$selection.TypeText("Support Documentation")

$selection.TypeParagraph()
$selection.Style="No Spacing"
$selection.borders.insidelinestyle=1
$selection.borders.outsidelinestyle=1

$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("SCCM TEST Package Name: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($pkgtitle)

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("SCCM TEST Package ID: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($pkg.packageid)

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("Manufacturer: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($pkg.manufacturer)

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("Product: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($pkg.name)

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("Version: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($pkg.version)

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("SCCM Package Type: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($pkgtype)

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("Source Directory: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($pkg.pkgsourcepath)

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("SCCM TEST Package Location: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($pkgloc)

$selection.TypeParagraph()
$selection.Style="No Spacing"
$selection.borders.insidelinestyle=0
$selection.borders.outsidelinestyle=0

$selection.TypeParagraph()
$selection.Style="No Spacing"
$selection.borders.insidelinestyle=1
$selection.borders.outsidelinestyle=1

$selection.Font.Color="wdColorBlack"
$selection.Font.Size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$true
$selection.TypeText("Custom Tracking Information:")

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("File Name: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($crinfo."signature filename")

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("WinXP File Path: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText(" ")

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("Win7 File Path: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText(" ")

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("File Size: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($crinfo."signature filesize")

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("File Version: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($crinfo."signature file version")

$selection.TypeParagraph()
$selection.Style="No Spacing"
$selection.borders.insidelinestyle=0
$selection.borders.outsidelinestyle=0
$selection.TypeParagraph()

$selection.Font.Color="wdColorRed"
$selection.Font.Size=14
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("DSI Doc Cert Note:")
$selection.TypeParagraph()
$selection.Font.Color="wdColorBlack"
$selection.Font.size=12
$selection.Font.Name="Calibri"
$selection.Font.Bold=$false
$selection.TypeText("Example note to DSI Doc Cert")

$selection.TypeParagraph()
$selection.Style="Heading 1"
$selection.TypeText("Below Support Documentation")

$selection.TypeParagraph()
$selection.Style="No Spacing"
$selection.borders.insidelinestyle=1
$selection.borders.outsidelinestyle=1

$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("SCCM Package Name: ")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText($pkgtitle)

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("SCCM PROD Package Location:")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText(" ")

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("SCCM PROD Package ID:")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText(" ")

$selection.TypeParagraph()
$selection.Font.Color="wdColorRed"
$selection.Font.Size=12
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("SCCM PROD Collection ID:")
$selection.Font.Color="wdColorDarkBlue"
$selection.Font.size=14
$selection.Font.Name="Times New Roman"
$selection.Font.Bold=$false
$selection.TypeText(" ")

$selection.TypeParagraph()
$selection.Style="No Spacing"
$selection.borders.insidelinestyle=0
$selection.borders.outsidelinestyle=0
$selection.TypeParagraph()

$selection.Font.Color="wdColorRed"
$selection.Font.Size=14
$selection.Font.Name="Helv"
$selection.Font.Bold=$true
$selection.TypeText("DSI Tech Note:")
$selection.TypeParagraph()
$selection.Font.Color="wdColorBlack"
$selection.Font.size=12
$selection.Font.Name="Calibri"
$selection.Font.Bold=$false
$selection.TypeText("Example note to DSI")
$selection.TypeParagraph()

if ($pkg.packagetype -eq 7) {
    $selection.TypeParagraph()
    $selection.Font.Color="wdColorgray65"
    $selection.Font.size=10
    $selection.Font.Name="Calibri"
    $selection.Font.Italic=$true
    $selection.TypeText("Required on all App-V docs!")
    $selection.TypeParagraph()
    $selection.Font.Color="wdColorBlack"
    $selection.Font.size=12
    $selection.Font.Name="Calibri"
    $selection.Font.Italic=$false
    $selection.TypeText("There is no manual install for App-V packages, they must be deployed through SCCM. No changes are made to the operating system as this application is ran in a virtual bubble.")
    $selection.TypeParagraph()
    $selection.TypeParagraph()
    $table = $selection.Tables.add($selection.range, 8, 2)
    $table.cell(1,1).range.text = "Workstation Client(s)"
    $table.cell(1,2).range.text = $osinfo
    $table.cell(2,1).range.text = "Storage Requirements"
    $table.cell(2,2).range.text = "Size in MB"
    $table.cell(3,1).range.text = "RAM Requirements"
    $table.cell(3,2).range.text = "Standard RAM"
    $table.cell(4,1).range.text = "Network Resources"
    $table.cell(4,2).range.text = "I:\ = \\lounaswps01\idrive"
    $table.cell(5,1).range.text = "Estimated Installation Duration"
    $table.cell(5,2).range.text = "Time in minutes"
    $table.cell(6,1).range.text = "Uninstall Previous Versions"
    $table.cell(6,2).range.text = "Not Applicable"
    $table.cell(7,1).range.text = "Software Prerequisites"
    $table.cell(7,2).range.text = "Not Applicable"
    $table.cell(8,1).range.text = "Additional Info"
    $appvnote = "Users must be a member of " + $crinfo."App-V Group name" + " to receive this package. To grant a user access to this application, please open a ticket to ATSPNR with the username and group name. The application should be available on the users workstation within 24 hours of being added to the group."
    $table.cell(8,2).range.text = $appvnote
    $table.borders.insidelinestyle=1
    $table.borders.outsidelinestyle=1
    $selection.EndOf(15)
    $selection.MoveDown()
    $selection.TypeParagraph()
    $selection.TypeParagraph()
    $selection.Font.Color="wdColorgray65"
    $selection.Font.size=10
    $selection.Font.Name="Calibri"
    $selection.Font.Italic=$true
    $selection.TypeText("Required on all App-V docs deployed through Run Advertised Programs!")
    $selection.TypeParagraph()
    $selection.Font.Color="wdColorBlack"
    $selection.Font.size=12
    $selection.Font.Name="Calibri"
    $selection.Font.Italic=$false
    $selection.TypeText("The following document can be sent to users for instructions on how to access a Virtual Application through Run Advertised Programs on Windows 7.")
    $selection.TypeParagraph()
    $selection.TypeParagraph()
    $selection.hyperlinks.add($selection.range, "http://teams.humana.com/sites/ats/Shared%20Documents/Training/SCCM/Using%20Run%20Advertised%20Programs%20to%20install%20software.docx",$null,$null,"http://teams.humana.com/sites/ats/Shared%20Documents/Training/SCCM/Using%20Run%20Advertised%20Programs%20to%20install%20software.docx") | out-null
    $selection.TypeParagraph()
    $selection.Font.Color="wdColorgray65"
    $selection.Font.size=10
    $selection.Font.Name="Calibri"
    $selection.Font.Italic=$true
    $selection.TypeText("Do not paste this link in your IT Doc DB Entry, please save the document and attach it!")
} elseif ($pkg.packagetype -eq 0) {
    $selection.TypeParagraph()
    $selection.Font.Color="wdColorgray65"
    $selection.Font.size=10
    $selection.Font.Name="Calibri"
    $selection.Font.Bold=$false
    $selection.Font.Italic=$true
    $selection.TypeText("Required on all SCCM docs!")
    $selection.TypeParagraph()
    $selection.Font.Color="wdColorblack"
    $selection.Font.size=12
    $selection.Font.Bold=$true
    $selection.Font.Italic=$false
    $selection.TypeText("This product is installed via System Center Configuration Manager (SCCM).")
    $selection.TypeParagraph()
    $selection.Font.Bold=$false
    $selection.TypeText("Please open CSS Ticket and assign to appropriate DSI team.")
    $selection.TypeParagraph()
    $selection.TypeText("Verify the following information is included in the Service Desk ticket:")
    $selection.TypeParagraph()
    $selection.TypeText("•	Name , TSO ID, and WKID for each user requesting the software")
    $selection.TypeParagraph()
    $selection.TypeText("•	Exact title of the document (including version) as listed above under Product.")
}

$selection.TypeParagraph()
$selection.TypeParagraph()
$selection.Font.Color="wdColorGray65"
$selection.Font.Size=10
$selection.Font.Name="Calibri"
$selection.Font.Bold=$flase
$selection.TypeText("Document created by $user on $date")

#$doc.SaveAs([ref]$savepath)    
#$doc.Close()
#$word.quit()

#Invoke-Item $savepath