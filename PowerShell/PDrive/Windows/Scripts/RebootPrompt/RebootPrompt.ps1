param(
[switch]$AllowOK,
[switch]$RemoveOK,
[switch]$ForcePopup
)

Write-Output "### Humana Reboot Popup Script Started ###"

$uptime = [math]::truncate((gwmi Win32_PerfFormattedData_PerfOS_System).SystemUpTime/60/60/24)
Write-Output "Current uptime: $uptime days"

function RebootPopup {

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")   
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")   
[System.Windows.Forms.Application]::EnableVisualStyles();

$title = "Humana Reboot Notification"

#Draw the base form
$RebootForm = New-Object System.Windows.Forms.Form
$RebootForm.Text = $title
$RebootForm.Size = New-Object System.Drawing.Size(620,430)
$RebootForm.DataBindings.DefaultDataSourceUpdateMode = 0
$RebootForm.StartPosition = "CenterScreen"
$RebootForm.MinimizeBox = $False
$RebootForm.MaximizeBox = $False
$RebootForm.ControlBox = $False
$RebootForm.FormBorderStyle = "Fixed3D"
$RebootForm.Topmost = $True
$RebootForm.BackColor="White"

$WarningText1 = New-Object System.Windows.Forms.Label
$WarningText1.Location = New-Object System.Drawing.Size(20,20)
$WarningText1.Size = New-Object System.Drawing.Size(500,30)
$WarningText1.Font = New-Object System.Drawing.Font("Calibri Light",18)
$WarningText1.ForeColor = "#5C9A1B"
$WarningText1.Text = "Your computer has not been rebooted recently!"

$RebootForm.Controls.Add($WarningText1)

$WarningText2 = New-Object System.Windows.Forms.Label
$WarningText2.Location = New-Object System.Drawing.Size(90,70)
$WarningText2.Size = New-Object System.Drawing.Size(500,80)
$WarningText2.Font = New-Object System.Drawing.Font("Calibri Light",14)
$WarningText2.ForeColor = "#AA005F"
$WarningText2.Text = "Please use the Go Home icon on your desktop to restart your workstation at your earliest convenience and at the end of each work day going forward."

$RebootForm.Controls.Add($WarningText2)

$WarningText3 = New-Object System.Windows.Forms.Label
$WarningText3.Location = New-Object System.Drawing.Size(20,150)
$WarningText3.Size = New-Object System.Drawing.Size(575,160)
$WarningText3.Font = New-Object System.Drawing.Font("Calibri Light",11)
$WarningText3.ForeColor = "#000000"
$WarningText3.Text = "Using the Go Home icon daily will allow you to avoid being caught off guard at an inconvenient time by automatic system reboots. Everyone who uses a Humana workstation should reboot their workstations on a daily basis to ensure that proper system and security updates are applied. Thank you for your prompt attention and cooperation in keeping Humana workstations safe and functioning efficiently!
`nIf you do not reboot for an extended period of time, your workstation may be rebooted automatically.Please search for the term `"reboot`" in the AUP for more information."

$RebootForm.Controls.Add($WarningText3)

$WarningText3Link = New-Object System.Windows.Forms.LinkLabel
$WarningText3Link.Location = New-Object System.Drawing.Size(20,300)
$WarningText3Link.Size = New-Object System.Drawing.Size(325,20)
$WarningText3Link.LinkColor = "#0074A2"
$WarningText3Link.Font = New-Object System.Drawing.Font("Calibri Light",11)
$WarningText3Link.ActiveLinkColor = "#114C7F"
$WarningText3Link.Text = "Information Protection Acceptable Use Policy (AUP)"
$WarningText3Link.add_Click({[system.Diagnostics.Process]::start("https://dctm.humana.com/mentor/web/view.aspx?ObjectId=0900092980259bed&title=Information%20Protection%20Acceptable%20Use%20Policy")})

$RebootForm.Controls.Add($WarningText3Link)
$WarningText3Link.BringToFront()

$WarningText4 = New-Object System.Windows.Forms.Label
$WarningText4.Location = New-Object System.Drawing.Size(20,355)
$WarningText4.Size = New-Object System.Drawing.Size(100,30)
$WarningText4.Font = New-Object System.Drawing.Font("Calibri Light",16,[System.Drawing.FontStyle]::Bold)
$WarningText4.ForeColor = "#5C9A1B"
$WarningText4.Text = "Humana"

$RebootForm.Controls.Add($WarningText4)

$GoHomeFile = (get-item ".\GoHome.PNG")
$GoHomeImage = [System.Drawing.Image]::Fromfile($GoHomeFile);

$GoHomePictureBox = new-object Windows.Forms.PictureBox
$GoHomePictureBox.location = New-Object System.Drawing.Size(20,75)
$GoHomePictureBox.Width = $GoHomeImage.Size.Width;
$GoHomePictureBox.Height = $GoHomeImage.Size.Height; 
$GoHomePictureBox.Image = $GoHomeImage;
$RebootForm.controls.add($GoHomePictureBox)

$RebootInfo = New-Object System.Windows.Forms.Label
$RebootInfo.Location = New-Object System.Drawing.Size(20,335)
$RebootInfo.Size = New-Object System.Drawing.Size(400,20)
$RebootInfo.Font = New-Object System.Drawing.Font("Calibri Light",11)
$RebootInfo.Text = "For more information, do not contact CSS, please visit"
$RebootForm.Controls.Add($RebootInfo)

$RebootInfoLink = New-Object System.Windows.Forms.LinkLabel
$RebootInfoLink.Location = New-Object System.Drawing.Size(347,335)
$RebootInfoLink.Size = New-Object System.Drawing.Size(150,20)
$RebootInfoLink.LinkColor = "#0074A2"
$RebootInfoLink.Font = New-Object System.Drawing.Font("Calibri Light",11)
$RebootInfoLink.ActiveLinkColor = "#114C7F"
$RebootInfoLink.Text = "http://go/reboot"
$RebootInfoLink.add_Click({[system.Diagnostics.Process]::start("http://go.humana.com/Reboot")})
$RebootForm.Controls.Add($RebootInfoLink)
$RebootInfoLink.BringToFront()

if ($uptime -ge 7 -or $RemoveOK -eq $True -and $AllowOK -ne $True) {
    $RebootNowText = New-Object System.Windows.Forms.Label
    $RebootNowText.Location = New-Object System.Drawing.Size(350,340)
    $RebootNowText.Size = New-Object System.Drawing.Size(250,50)
    $RebootNowText.Font = New-Object System.Drawing.Font("Calibri Light",11,[System.Drawing.FontStyle]::Bold)
    $RebootNowText.ForeColor = "#AA005F"
    $RebootNowText.Text = "Please save your work and reboot at your earliest convenience."
    $RebootForm.Controls.Add($RebootNowText)
}

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(500,355)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.BackColor = "#AA005F"
$OKButton.ForeColor = "White"
$OKButton.Add_Click({
    $RebootForm.Close()
})

if ($uptime -lt 7 -or $AllowOK -eq $True) {
    $RebootForm.Controls.Add($OKButton)
}

$RebootForm.Add_Shown({$RebootForm.Activate()})
[void] $RebootForm.ShowDialog()

}

if ($uptime -ge 5 -or $ForcePopup -eq $true) {
    if ($ForcePopup) {
        Write-Output "ForcePopup equals true!"
    }
    Write-Output "Displaying popup..."
    RebootPopup
    Write-Output "Popup closed!"
}

Write-Output "### Humana Reboot Popup Script Finished ###"