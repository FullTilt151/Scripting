param(
[Parameter(Mandatory)]  
[ValidateSet('Pin','Unpin')] 
$Action = 'Pin'
)

if (Test-Path 'c:\Program Files (x86)\Microsoft Office\Office16\OUTLOOK.EXE') {
    switch ($Action) {
        'Pin' {.\syspin.exe 'c:\Program Files (x86)\Microsoft Office\Office16\OUTLOOK.EXE' "Pin to taskbar"}
        'Unpin' {.\syspin.exe 'c:\Program Files (x86)\Microsoft Office\Office16\OUTLOOK.EXE' "Unpin from taskbar"}
    }
} else {
    Write-Warning 'Cannot find Outlook.exe, aborting!'
}