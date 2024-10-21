Function Test-PsRemoting { 
    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]
    Param( 
        [Parameter(Mandatory = $true)] 
        [ValidateScript( {Test-Connection -ComputerName $_ -Count 1 -Quiet})]
        [String]$computername 
    ) 
     
    try { 
        Get-Service -ComputerName $computername -Name WinRM | Start-Service
        $errorActionPreference = "Stop" 
        $result = Invoke-Command -ComputerName $computername { 1 } 
    }

    catch { 
        Write-Verbose $_ 
        return $false 
    } 
     
    ## I've never seen this happen, but if you want to be 
    ## thorough.... 
    if ($result -ne 1) { 
        Write-Verbose "Remoting to $computerName returned an unexpected result." 
        return $false 
    } 
     
    return $true     
} 

Function Enable-WinRM {

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Array of computer names to target')]
        [Alias('host')]
        [ValidateLength(3, 30)]
        [string[]]$computerNames
    )

    begin {
        Write-Verbose 'Starting Function'
        Write-Verbose "computerNames = $computerNames"
        $cmd = '\\lounaswps01\pdrive\Dept907.CIT\OSD\packages\PSTools\psexec.exe'
        $returnHashTable = @{}
    }

    process {
        write-verbose 'Beginning process loop'

        foreach ($computerName in $computerNames) {
            Write-Verbose "Processing $computerName"
            $EnableWinRMargs = ('-AcceptEula', "\\$computerName", 'C:\Windows\system32\winrm.cmd', 'qc', 'quiet')
            $EnablePSRemoting = ('-AcceptEula', "\\$computerName", '-s', 'PowerShell', 'Enable-PSRemoting -Force')
            if ($PSCmdlet.ShouldProcess($CIID)) {
                $status = winrm id -r:$($computerName)
                if ($LASTEXITCODE -eq 0) {
                    Write-Verbose "WinRM is already enabled on $ComputerName"
                    $result = [Array]"WinRM Already Enabled "
                }
                else {
                    $status = Invoke-Command -ScriptBlock {& $cmd $EnableWinRMargs}
                    if ($LASTEXITCODE -eq 0) {
                        Write-Verbose "WinRM Enabled on $computerName"
                        $result = [Array]"WinRM Enabled"
                    }
                    elseif ($LASTEXITCODE -eq 1) {
                        Write-Verbose "WinRM failed to enable on $computerName because C:\Windows\System32\WinRM.cmd is missing"
                        $result = [Array]"WinRM Failed because c:\windows\system32\winrm.cmd is missing"
                    }
                    else {
                        Write-Verbose "WinRM Failed on $computerName with $($Error[0].Message)"
                        $result = [Array]"WinRM Failed with $($Error[0].Message)"
                    }
                }
                
                if (Test-PsRemoting -computername $computerName) {
                    Write-Verbose "PSRemoting enabled on $computerName"
                    $result += [Array]"PSRemoting already enabled"
                }
                else {
                    Write-Verbose "Enabling PSRemote on $computerName"
                    Start-Process -Wait -FilePath $cmd -ArgumentList $EnablePSRemoting
                    if ($LASTEXITCODE -eq 0) {
                        Write-Verbose "PSRemoting enabled on $computerName"
                        $result += [Array]"PSRemoting Enabled"
                    } 
                    else {
                        Write-Verbose "PSRemoting failed to enable on $computerName with $($Error[0].Message)"
                        $result = [Array]"PSRemoting Failed with $($Error[0].Message)"
                    }
                }
            }
            $returnHashTable.Add($computerName, $result)
        }
    }

    End {
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.Enable-WinRM')
        Return $obj	
    }
} #End Enable-WinRM

#Begin - Testing info
Enable-WinRM -computerNames ('LOUAPPWTS1140') -Verbose
#End - Testing info