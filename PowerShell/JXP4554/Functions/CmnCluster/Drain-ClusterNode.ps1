<# 
           .SYNOPSIS  
           This script will Pull or drain cluster resources from the command line. 
 
           .DESCRIPTION 
           The script will Pull or drain cluster resources from the command line. 
		   
		   .NOTES 
           File Name : ClusterResourceMover2.ps1
           Authors   : Mark Harris
           Requires  : Windows Server 2012 R2 PowerShell
                       Windows Server 2012 R2 Clustering Cmdlets 
                       Windows Server 2008 R2 PowerShell
					   Windows Server 2008 R2 Clustering Cmdlets 
           Version   : 1.0 (July 26 2016)
					   1.1 (August 22, 2016) Added FuncMail to send notifications
					        
           .PARAMETER drain or pullall 
           Specifies send, retrieve or delegate cluster resources 
 
           .INPUTS 
           ClusterResourceMover2 accepts drain and pullall 
 
           .OUTPUTS 
           Log to c:\support directory and log to EventLog and sends email to teams / individuals. 
 
           .EXAMPLE 
           C:\PS> .\ClusterResourceMover2 drain # drains all cluster resources to the other node. 
			
		   .EXAMPLE 
           C:\PS> .\ClusterResourceMover2 pullall # Retrives all cluster resources to the current node.
		   
#> 
# Get User input and execute function Must be first line in code

Param
(
    [Parameter(Mandatory=$true,HelpMessage="Enter in drain, pullall")]
    [String]$ClusOp
)

Function Test-CMNPendingReboot
{
	Begin{$Computer="$env:COMPUTERNAME"}## End Begin Script Block

	Process
	{
		Try
		{
		## Setting pending values to false to cut down on the number of else statements
		$CompPendRen,$PendFileRename,$Pending,$SCCM = $false,$false,$false,$false
      
		## Setting CBSRebootPend to null since not all versions of Windows has this value
		$CBSRebootPend = $null
            
		## Querying WMI for build version
		$WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer -ErrorAction Stop

		## Making registry connection to the local/remote computer
		$HKLM = [UInt32] "0x80000002"
		$WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"
            
		## If Vista/2008 & Above query the CBS Reg Key
		If ([Int32]$WMI_OS.BuildNumber -ge 6001)
		{
			$RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
			$CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"    
		}
              
		## Query WUAU from the registry
		$RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
		$WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired"
            
		## Query PendingFileRenameOperations from the registry
		$RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\Session Manager\","PendingFileRenameOperations")
		$RegValuePFRO = $RegSubKeySM.sValue

		## Query ComputerName and ActiveComputerName from the registry
		$ActCompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\","ComputerName")      
		$CompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\","ComputerName")
		If ($ActCompNm -ne $CompNm)
		{
			$CompPendRen = $true
		}
            
		## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
		If ($RegValuePFRO)
		{
			$PendFileRename = $true
		}

		## Determine SCCM 2012 Client Reboot Pending Status
		## To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0
		$CCMClientSDK = $null
		$CCMSplat = @{
			NameSpace='ROOT\ccm\ClientSDK'
			Class='CCM_ClientUtilities'
			Name='DetermineIfRebootPending'
			ComputerName=$Computer
			ErrorAction='Stop'
		}
		  
		## Try CCMClientSDK
		Try
		{
			$CCMClientSDK = Invoke-WmiMethod @CCMSplat
		}
		Catch [System.UnauthorizedAccessException]
		{
			$CcmStatus = Get-Service -Name CcmExec -ComputerName $Computer -ErrorAction SilentlyContinue
			If ($CcmStatus.Status -ne 'Running')
			{
			Write-Warning "$Computer`: Error - CcmExec service is not running."
			$CCMClientSDK = $null
			}
		} 
		Catch
		{
			$CCMClientSDK = $null
		}

		If ($CCMClientSDK)
		{
			If ($CCMClientSDK.ReturnValue -ne 0)
			{
				Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"    
			}
			If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending)
			{
				$SCCM = $true
			}
		}
      
		Else
		{
			$SCCM = $null
		}
		Return ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename)
		} 

		Catch
		{
			Write-Warning "$Computer`: $_"
			## If $ErrorLog, log the file to a user specified location/path
			If ($ErrorLog)
			{
				Out-File -InputObject "$Computer`,$_" -FilePath $ErrorLog -Append
			}        
		}      
	}## End Process

	End {  }## End End

}## End Function Test-CMNPendingReboot

Function Drain 
{
    Write-EventLog -LogName "Application" -Source "ServerMaint" -EventID 101 -EntryType Information -Message "Cluster Drain Operation started for Windows Patching"
    Import-Module FailoverClusters
    Add-Content -Path $LogFileName -Value "Date: $date1" -Encoding ASCII
    Add-Content -Path $LogFileName -Value "Executed By: $admin" -Encoding ASCII
    Add-Content -Path $LogFileName -Value "Current Cluster Assignments" -Encoding ASCII
    Get-ClusterGroup | Out-File -append  -Encoding ASCII -FilePath $LogFileName 
    $computer = get-content env:computername
    $computer = $computer.ToLower()
    $destnode = Get-clusternode | select Name

    # Convert to string for use in foreach-object
    [string]$drainnode = ($destnode.Name -ne $computer) 

    Get-ClusterGroup |
    foreach-object `
	{
	    If ($_.Name -ne $computer)
		{
		    Move-ClusterGroup -Name $_.Name -Node $drainnode
		}
	}
	
    Add-Content -Path $LogFileName -Value "($clustervipname) Drain Operation Completed to $drainnode " -Encoding ASCII
    Add-Content -Path $LogFileName -Value "New Cluster Assignments" -Encoding ASCII
    Get-ClusterGroup | Out-File -append  -Encoding ASCII -FilePath $LogFileName
    Write-EventLog -LogName "Application" -Source "ServerMaint" -EventID 201 -EntryType Information -Message "($clustervipname) Cluster Drain Operation completed for Windows Patching"
    FuncMail -To "toemail.com" -From "myemail.com"  -Subject "($clustervipname) Cluster Drain Opertaion completed by ($node)." -Body "($clustervipname) Cluster Drain Operation completed for Windows Patching" -smtpServer "mgds.td.afg"
}

Function PullAll 
{
    Write-EventLog -LogName "Application"  -Source "ServerMaint" -EventID 101 -EntryType Information -Message "Cluster PullAll Operation Started for Windows Patching"
    Import-Module FailoverClusters
    Add-Content -Path $LogFileName -Value "Date: $date1" -Encoding ASCII
    Add-Content -Path $LogFileName -Value "Executed By: $admin" -Encoding ASCII
    Add-Content -Path $LogFileName -Value "Current Cluster Assignments" -Encoding ASCII
    Get-ClusterGroup | Out-File -append  -Encoding ASCII -FilePath $LogFileName 
    $computer = get-content env:computername
    $computer = $computer.ToLower()
    Get-clusternode | Get-ClusterGroup |
    foreach-object `
	{
	    If ($_.Name -ne $computer)
		{ 
		    Move-ClusterGroup -Name $_.Name -Node $computer
		}
	}
    Add-Content -Path $LogFileName -Value "($clustervipname) PullAll Operation Completed to $computer " -Encoding ASCII
    Add-Content -Path $LogFileName -Value "New Cluster Assignments" -Encoding ASCII
    Get-ClusterGroup | Out-File -append  -Encoding ASCII -FilePath $LogFileName
    Write-EventLog -LogName "Application" -Source "ServerMaint" -EventID 201 -EntryType Information -Message "($clustervipname) Cluster PullAll Operation completed for Windows Patching"
    FuncMail -To "toemail.com" -From "myemail.com"  -Subject "($clustervipname) Cluster PullAll Opertaion completed by ($node)." -Body "($clustervipname) Cluster PullAll Operation completed for Windows Patching" -smtpServer "mgds.td.afg"
}

Function FuncMail 
{
    param($To, $From, $Subject, $Body, $smtpServer)
    $msg = new-object Net.Mail.MailMessage
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)
    $msg.From = $From
    $msg.To.Add($To)
    $msg.Subject = $Subject
    $msg.IsBodyHtml = 1
    $msg.Body = $Body
    $smtp.Send($msg)
}
  
# Create Local logfile
$node = hostname
$date1=Get-Date -Format "yyyy-MM-dd hh:mm tt"
$clustervip=Get-Cluster 
$clustervipname=($clustervip.Name)
$admin = (Get-Content -Path env:username).ToString()
$LogFileName = "c:\Support\ClusterResMove-"+ $node +".txt"
Out-File -append -FilePath $LogFileName -Encoding ASCII
Add-Content -Path $LogFileName -Value "Computer: $node" -Encoding ASCII
Add-Content -Path $LogFileName -Value "*****************************" -Encoding ASCII

# Take the parameter and validate the input and call the functions.
If ("drain","pullall" -NotContains $ClusOp) 
  { 
    Throw "Not a valid option! Please use drain, pullall or balance option" | Out-File -append  -Encoding ASCII -FilePath $LogFileName 
  } 

 # All parameters are valid call function 
If ($ClusOp -eq "drain") { Drain }
If ($ClusOp -eq "pullall") { PullAll }
