$i = 0
$hash = @{}
Switch -Regex (Get-Content -Path "\\LOUAPPWPS359\SMS_HGB\Logs\colleval.log")
{'^.*\d{3,8}\.\d{1,3} seconds' {$evalline = $switch.current
                                #({0} - {1}) -f "LOUAPPWPS359", $evalline
                                $evalline
                                $evalline | Out-File c:\temp\longeval.txt -Append
                                $hash.Add($i, $evalline)
                                $i += 1
                                }

}

Switch -Regex (Get-Content -Path "\\LOUAPPWPS610\SMS_SDC\Logs\colleval.log")
{'^.*\d{3,8}\.\d{1,3} seconds' {$evalline = $switch.current
                                $evalline
                                $evalline | Out-File c:\temp\longeval.txt -Append
                                $hash.Add($i, $evalline)
                                $i += 1
                                }

}

Switch -Regex (Get-Content -Path "\\LOUAPPWPS862\SMS_LDC\Logs\colleval.log")
{'^.*\d{3,8}\.\d{1,3} seconds' {$evalline = $switch.current
                                $evalline
                                $evalline | Out-File c:\temp\longeval.txt -Append
                                $hash.Add($i, $evalline)
                                $i += 1
                                }

}

$hash