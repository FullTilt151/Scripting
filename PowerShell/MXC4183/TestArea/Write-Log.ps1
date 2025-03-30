$Global:LogFile = ".\LogTesting.log" #log to the script folder... (dot sourced)

Function WriteLog
{
	Param ([string]$string)
	Add-content $Logfile -value $string

}

WriteLog "$(Get-Date): no more devices to purge"
WriteLog "This is a test."