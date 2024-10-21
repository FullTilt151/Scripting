####################
#
# Title: Delete ConfigMgr Record
# Description: This script is to search a ConfigMgr server for a device and delete it. 
# Author: Daniel Ratliff
# Date Created: 07/04/2013
#
# ChangeLog:
# Version 1.0: 
#
####################

$title = "Delete ConfigMgr Record"
  
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")   
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")   
[System.Windows.Forms.Application]::EnableVisualStyles();

$objForm = New-Object System.Windows.Forms.Form  
$objForm.Text = $title  
$objForm.Size = New-Object System.Drawing.Size(500,350)
$objForm.StartPosition = "CenterScreen"  
$objForm.MinimizeBox = $False
$objForm.MaximizeBox = $False
$objform.FormBorderStyle = "Fixed3D"
$objForm.Topmost = $True  
$ObjForm.Icon = $Icon 

$compname = (get-wmiobject win32_computersystem).name

$custom = New-Object System.Windows.Forms.Label  
$custom.Location = New-Object System.Drawing.Size(20,20)
$custom.Size = New-Object System.Drawing.Size(90,15)
$custom.Text = "Computer Name:"  
$objForm.Controls.Add($custom)

$objTextBox = New-Object System.Windows.Forms.TextBox
$objTextBox.Location = New-Object System.Drawing.Size(110,17)
$objTextBox.Size = New-Object System.Drawing.Size(150,20)
$objTextbox.MaxLength = 15
$objForm.Controls.Add($objTextBox)
$objTextBox.Text = $compname

$logo = New-Object System.Windows.Forms.RichTextBox
$logo.location = New-Object System.Drawing.Size(20,50) 
$logo.Size = New-Object System.Drawing.Size(450,200) 
$logo.ReadOnly=$true
$logo.Visible=$True
$objform.controls.add($logo)

$connectButton = New-Object System.Windows.Forms.Button  
$connectButton.Location = New-Object System.Drawing.Size(275,15)  
$connectButton.Size = New-Object System.Drawing.Size(100,23)  
$connectButton.Text = "Connect" 
$connectButton.Add_Click({
    if (test-connection -count 1 $objtextbox.text) {
        $compname=$objTextBox.Text;
        $logo.text = ""
        $wkid = (Get-WmiObject win32_computersystem -computername $compname).name
        $macaddress = (get-wmiobject win32_networkadapter -property Name,MacAddress,AdapterType -computername $compname | where adaptertype -eq "Ethernet 802.3").MACAddress
        $uuid = (Get-WmiObject uuid -Namespace root\cimv2 -class win32_computersystemproduct -computername $compname).uuid
    
        $logo.AppendText("WKID:                                   " + $wkid + [char]13 + [char]10)
        $logo.AppendText("MAC Address:                       " + $macaddress + [char]13 + [char]10)
        $logo.AppendText("UUID/SMBIOSGUID:           " + $uuid + [char]13 + [char]10 + [char]13 + [char]10)
    } else {
        $logo.AppendText($objtextbox.text + " is offline!" + [char]13 + [char]10)
    }
})
$objForm.Controls.Add($connectbutton)

$searchButton = New-Object System.Windows.Forms.Button  
$searchButton.Location = New-Object System.Drawing.Size(130,275)  
$searchButton.Size = New-Object System.Drawing.Size(100,23)  
$searchButton.Text = "Search Records" 
$searchButton.Add_Click({
    $siteserver = "LOUAPPWPS875"
    $sitecode = "CAS"

    $sccmun = "HUMAD\sccmosdsvc"
    $sccmpw = 'e$6J1C6mWK' | ConvertTo-SecureString -AsPlainText -force
    $sccmcred = new-object -typename System.Management.Automation.PSCredential -argumentlist $sccmun, $sccmpw
        
    $logo.appendtext("Searching ConfigMgr for objects..." + [char]13 + [char]10)
    $computer =  Get-WMIObject -ComputerName $siteserver -Namespace "root\sms\site_$siteCode" -Query "select * from sms_r_system where name = '$typedname' or macaddresses like '$macaddress' or smbiosguid = '$uuid'" -Credential $sccmcred
    if ($computer) {
            $countobj = ($computer | measure-object).count
            $logo.appendtext("$countobj object(s) found!")
            $compoutput = $computer | select Name,MACAddresses,SMBIOSGUID | format-list | out-string
            $logo.appendtext($compoutput)
    } else {
            $logo.appendtext("No objects found!" + [char]13 + [char]10)
    }
})
$objForm.Controls.Add($searchbutton)

$sccmButton = New-Object System.Windows.Forms.Button  
$sccmButton.Location = New-Object System.Drawing.Size(230,275)  
$sccmButton.Size = New-Object System.Drawing.Size(100,23)  
$sccmButton.Text = "Delete Record" 
$sccmButton.Add_Click({  
    $typedname = ($objTextBox.Text).ToUpper()
    $sccmconfirm = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to delete all ConfigMgr records with the following info?" + "`n`n" + "WKID: " + $typedname + "`n" + "MAC: " + $macaddress + "`n" + "UUID: " + $uuid, "Confirm Delete!" , 4, "Exclamation")
    if ($sccmconfirm -eq "YES") {
        if($computer) {
            $logo.appendtext("Deleting $countobj object(s)..." + [char]13 + [char]10)
            foreach ($comp in $computer) {
                $comp.psbase.Delete()
                if ($?) {
                    $logo.appendtext("Successfully deleted " + $comp.name + "!" + [char]13 + [char]10)
                } else {
                    $logo.appendtext("Failed to delete " + $comp.name + "!" + [char]13 + [char]10)
                }
            }
        } else {
            $cmoutput.appendtext("No objects found!")
        }
    }
})
$objForm.Controls.Add($sccmButton)

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()