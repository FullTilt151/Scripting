# functions
Function Confirm-BaseReachable
{
    $Compliant = $false
    $CurrentIFs = (netsh interface ipv4 show interface)
    # Find the LAN and determine the Current ARP
    foreach($CurrentIF in $CurrentIFs)
    {
        if($CurrentIF -match 'Local Area Connection')
        {
            $CurrentIF -match '(\d+)' | Out-Null
            $CurrentARPS = (netsh interface ipv4 show interface $($Matches[1]))
            foreach($CurrentARP in $CurrentARPS)
            {
                if($CurrentARP -match 'Base Reachable Time')
                {
                    $CurrentARP -match '(\d+)' | Out-Null
                    if($CurrentARP -eq $Script:ArpValue)
                    {
                    Write-Output "1"
                    #$Compliant = $true
                    }
                    else
                    {
                    Write-output "0"
                    }
                   # if($CurrentARP -ne $Script:ArpValue){Set-BaseReachable}
                }
            }
        }
    }
    #return $Compliant
}

Function Set-BaseReachable
{
    $CurrentIFs = (netsh interface ipv4 show interface)
    # Find the LAN and determine the Current ARP
    foreach($CurrentIF in $CurrentIFs)
    {
        if($CurrentIF -match 'Local Area Connection')
        {
            $CurrentIF -match '(\d+)' | Out-Null
            $CurrentARPS = (netsh interface ipv4 show interface $($Matches[1]))
            foreach($CurrentARP in $CurrentARPS)
            {
               
                        netsh interface ipv4 set interface $Matches[1] basereachable = $arpvalue | Out-Null
            }
        }
    }  
}

#Begin the flowchart
[Int32]$ArpValue = 900000
Confirm-BaseReachable

#http://www.powershellcookbook.com/recipe/qAxK/appendix-b-regular-expression-reference