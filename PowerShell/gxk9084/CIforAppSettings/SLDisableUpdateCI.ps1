function Test-RegistryKeyValue
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Path,

        [Parameter(Mandatory=$true)]
        [string]
        $Name
    )

    if( -not (Test-Path -Path $Path -PathType Container) )
    {
        return $false
    }

    $properties = Get-ItemProperty -Path $Path 
    if( -not $properties )
    {
        return $false
    }

    $member = Get-Member -InputObject $properties -Name $Name
    if( $member )
    {
        return $true
    }
    else
    {
        return $false
    }

}



Try 
{
    $Remediate = $false
    $Compliant = $false
   
    If (Test-RegistryKeyValue "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Silverlight" -Name "UpdateConsentMode")
    {
        $val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Silverlight"
            if(($val.'UpdateConsentMode' -eq '0') -and ($val.'UpdateMode' -eq '2'))
            {
                $Compliant = $true
            }
            else
            {
                if($Remediate)
                {
                    set-itemproperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Silverlight" -Name "UpdateConsentMode"  -value "0"
                    set-itemproperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Silverlight" -Name "UpdateMode"  -value "2"
                }
            }
   # }
    else
    {
        $Compliant = $true
    }
    Return $Compliant
}

Catch [System.Exception]
{
     Return $Compliant
}

