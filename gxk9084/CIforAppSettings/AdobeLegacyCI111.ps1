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
    $RemediateLegacy = $false
    $CompliantLegacy = $false
    $Remediate = $false
    $Compliant = $false
    If(Test-RegistryKeyValue "HKLM:\SOFTWARE\WOW6432Node\Adobe\Adobe ARM\Legacy\Reader\{AC76BA86-7AD7-FFFF-7B44-AE0F06755100}" -Name "Mode")
    {
        $val = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Adobe\Adobe ARM\Legacy\Reader\{AC76BA86-7AD7-FFFF-7B44-AE0F06755100}" -Name "Mode"
            if($val.'Mode' -eq '0')
            {
                $CompliantLegacy = $true
            }
            else
            {
                if($RemediateLegacy)
                {
                    set-itemproperty -Path "HKLM:\SOFTWARE\WOW6432Node\Adobe\Adobe ARM\Legacy\Reader\{AC76BA86-7AD7-FFFF-7B44-AE0F06755100}" -Name "Mode"  -value "0"
                }
            }
    }
    else
    {
        $CompliantLegacy = $true
    }
    If(Test-RegistryKeyValue "HKLM:\SOFTWARE\WOW6432Node\Policies\Adobe\Acrobat Reader\2015\FeatureLockDown" -Name "bUpdater")
    {
        $val = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Policies\Adobe\Acrobat Reader\2015\FeatureLockDown" -Name "bUpdater"
            if($val.'bUpdater' -eq '0')
            {
                $Compliant = $true
            }
            else
            {
                if($Remediate)
                {
                    set-itemproperty -Path "HKLM:\SOFTWARE\WOW6432Node\Policies\Adobe\Acrobat Reader\2015\FeatureLockDown" -Name "bUpdater"  -value "0"
                }
            }
    }
    else
    {
        $Compliant = $true
    }
    Return $Compliant -and $CompliantLegacy
    #Return $CompliantLegacy
}

Catch [System.Exception]
{
     Return $Compliant -and $CompliantLegacy
}

