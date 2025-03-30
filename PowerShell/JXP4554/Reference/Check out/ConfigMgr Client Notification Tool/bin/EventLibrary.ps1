#######################################################################
##                                                                   ##
## Defines event handlers used by ConfigMgr Client Notification Tool ##
##                                                                   ##
#######################################################################

# Bring the window to the fore
$UI.Window.Add_Loaded({
    $This.Activate()
})

# The Go button
$UI.Go.Add_Click({

    $UI.DataSource[1] = "Ready"
    $UI.DataSource[2] = "Black"
    
    # Make sure we have the required data first
    If ($UI.SiteServerName.Text -eq "")
    {
        New-WPFMessageBox -Content "Dude, enter the Site Server name first!" -Title "Doh!" -TitleBackground OrangeRed -TitleTextForeground White -TitleFontWeight Bold -Sound 'Windows Exclamation' -WindowHost $UI.Window
        $Handled = $True
    }

    If (!($Handled) -and $UI.ClientNotificationCombo.SelectedIndex -eq -1)
    {
        New-WPFMessageBox -Content "Dude, select a Client Notification type first!" -Title "Doh!" -TitleBackground OrangeRed -TitleTextForeground White -TitleFontWeight Bold -Sound 'Windows Exclamation' -WindowHost $UI.Window
        $Handled = $True
    }

    If (!($Handled) -and $UI.ClientTextBox.Text -eq "")
    {
        New-WPFMessageBox -Content "Dude, enter at least one computer name first!" -Title "Doh!" -TitleBackground OrangeRed -TitleTextForeground White -TitleFontWeight Bold -Sound 'Windows Exclamation' -WindowHost $UI.Window
        $Handled = $True
    }

    # Invoke code in a background thread
    If (!($Handled))
    {
        $UI.DataSource[1] = "Creating CimSession to $($UI.SiteServerName.Text)"
        $UI.DataSource[2] = "Black"
        $UI.DataSource[0] = $True
        
        # Convert the computername list text into an array
        [array]$ResourceArray = ($ui.ClientTextBox.Text -split "\n").Trim() | where  {-not [string]::IsNullOrEmpty($_)}

        $Code = {
            Param($UI,$SiteServer,$Type,$Resources)
            Get-ClientOnlineStatus -UI $UI -SiteServer $SiteServer -Resources $Resources
            [array]$ResourceIDs = $UI.DataSource[3].Rows.ResourceID | where {$_ -ne ""}
            Trigger-ClientNotification -UI $UI -SiteServer $SiteServer -Type $Type -Resources $ResourceIDs
        }
        $Job = [BackgroundJob]::new($Code,@($UI,$UI.SiteServerName.Text,$UI.ClientNotificationCombo.SelectedValue,$ResourceArray),@("Function:\Get-ClientOnlineStatus","Function:\Trigger-ClientNotification"))
        $UI.Jobs += $Job
        $Job.Start()

    }

})