# Set this variable to true for the remediation script, false for the detection script
$remediate = $false

#Functions
    function Get-Shortcut {
      param(
        $path = $null
      )

      $obj = New-Object -ComObject WScript.Shell

      if ($path -eq $null) {
        $pathUser = [System.Environment]::GetFolderPath('StartMenu')
        $pathCommon = $obj.SpecialFolders.Item('AllUsersStartMenu')
        $path = dir $pathUser, $pathCommon -Filter *.lnk -Recurse 
      }
      if ($path -is [string]) {
        $path = dir $path -Filter *.lnk
      }
      $path | ForEach-Object { 
        if ($_ -is [string]) {
          $_ = dir $_ -Filter *.lnk
        }
        if ($_) {
          $link = $obj.CreateShortcut($_.FullName)

          $info = @{}
          $info.Hotkey = $link.Hotkey
          $info.TargetPath = $link.TargetPath
          $info.LinkPath = $link.FullName
          $info.Arguments = $link.Arguments
          $info.Target = try {Split-Path $info.TargetPath -Leaf } catch { 'n/a'}
          $info.Link = try { Split-Path $info.LinkPath -Leaf } catch { 'n/a'}
          $info.WindowStyle = $link.WindowStyle
          $info.IconLocation = $link.IconLocation

          New-Object PSObject -Property $info
        }
      }
    }

# Put code here to determine if item is compliant #if the item is not compliant, be sure to run the lines below 
Write-Output $false 

if($remediate) # Put code here to remediate 
{
     #Fix HOD
      
   function Set-Shortcut {
      param(
      [Parameter(ValueFromPipelineByPropertyName=$true)]
      $LinkPath,
      $Hotkey,
      $IconLocation,
      $Arguments,
      $TargetPath
      )
      begin {
        $shell = New-Object -ComObject WScript.Shell
      }

      process {
        $link = $shell.CreateShortcut($LinkPath)

        $PSCmdlet.MyInvocation.BoundParameters.GetEnumerator() |
          Where-Object { $_.key -ne 'LinkPath' } |
          ForEach-Object { $link.$($_.key) = $_.value }
        $link.Save()
      }
    }

    #operating Script
    #Variables
    $TargetPath = 'C:\ProgramData\Oracle\java\javapath\javaws.exe'
    $ProfilePath = (gci Env:\USERPROFILE).value
    $UserName = (GCI env:username).value

    ## Script Core
    # Check for JRE8 Symlinks
    If ((Test-Path C:\ProgramData\Oracle\java\javapath) -eq $False) {
        Write-error "JRE 8 not installed - Icons not fixed" -errorID 1608
        Break
        }
    $OutputLine = (Get-Date -format "MM/dd/yyyy HH:mm:ss")+'> '+"Username: "+$UserName+' _____________________<Start>'
    Write-Output $OutputLine|Out-File -filepath "C:\temp\FixMyHod.Log" -Append
    $DesktopShortcuts = Get-Shortcut "$profilePath\desktop"
    $DesktopShortcuts | ForEach-Object {
        $TargetLNK = $_.Link
        $LNKPath = $_.TargetPath
        $CurrentTarget = $_.Target
        If ($CurrentTarget -ne "n/a") {
            if ($CurrentTarget -contains "javaws.exe") {
                $NewLNKPath = $TargetPath
                $LNKStatus = "Changed"
                Set-Shortcut -LinkPath $_.LinkPath -TargetPath $TargetPath
                }
            Else {
                $NewLNKPath = $LNKPath
                $LNKStatus = "Skipped"
                }
            }
        Else {
            $NewLNKPath = "Warning: Null Path shortcut"
            $LNKStatus = "Skipped"
            }
        $OutputLine = (Get-Date -format "MM/dd/yyyy HH:mm:ss")+'> Processing:'+$TargetLNK+' Target App:'+$CurrentTarget+' Current Path:'+$LNKPath+' New Path:'+$NewLNKPath+' Result:'+$LNKStatus
        Write-Output $OutputLine|Out-File -filepath "C:\temp\FixMyHod.Log" -Append

        }
        $OutputLine = (Get-Date -format "MM/dd/yyyy HH:mm:ss")+'> _____________________<End>'
        Write-Output $OutputLine|Out-File -filepath "C:\temp\FixMyHod.Log" -Append

      #
    
        # If it is not, put the code here to fix it 
    } 
    else # We are compliant!!! Shout it to the world!
    {     
        Write-Output $true 
    }