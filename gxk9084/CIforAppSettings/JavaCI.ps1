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
    If(Test-RegistryKeyValue "HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy" -Name "EnableJavaUpdate")
    {
        $val = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy" -Name "EnableJavaUpdate"
            if($val.'EnableJavaUpdate' -eq '0')
            {
                $Compliant = $true
            }
            else
            {
                if($Remediate)
                {
                    set-itemproperty -Path "HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy" -Name "EnableJavaUpdate"  -value "0"
                }
            }
    }
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

