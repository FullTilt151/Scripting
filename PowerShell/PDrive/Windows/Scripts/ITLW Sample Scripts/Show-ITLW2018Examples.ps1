## Cmdlets are the lightweight commands used to accomplish tasks in PowerShell
## Notice how they use a verb-noun format
Get-Process
Get-Command
Get-ChildItem
Get-Member
Get-Verb

## Aliases are shorthand for typing longer commands, you can even lookup the different aliases with Get-Alias
## If you want to find all aliases for get-process, run the below command
Get-Alias | Where-Object {$_.definition -Match 'Get-Process'}

## In order for PowerShell scripts to run, the execution policy has to allow it
## Non-administrators must specify the scope for their specific user or session
Get-ExecutionPolicy -List
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

## Snapins and Modules are used to provide added functionality for a specific purpose
## Snapins are legacy DLLs that must be installed to function
## Modules are newer and based off PowerShell files that just need to be imported to function
Get-PSSnapin
Get-Module -ListAvailable

## Need help? Get-Help is the answer! 
## Help is cached locally, update it first!
Update-Help -Force

## Lots of different help commands with different output
Get-Help Get-Command
Get-Help Get-Command -Examples
Get-Help Get-Command -Full
Get-Help Get-Command -Online
Get-Help Get-Command -ShowWindow ## My Personal favorite 

## Files, Folders, Registry, Network drives, certificates, etc are all PSDrives
## The 'net use' of PowerShell
Get-PSDrive

## The Pipeline allows you to chain commands together to achieve a result
$computers = "WKMJ059G4B", "SIMXDWTSSA1131", "CITPXEWPW03"
$computers | Where-Object {$_.Equals("WKMJ059G4B")} | ForEach-Object { Test-Connection -ComputerName $_ -Count 1 }
$computers.Where({$_.Equals("WKMJ059G4B")}) | ForEach-Object { Test-Connection -ComputerName $_ -Count 1 }

## Measure-Command allows you to see how long commands take, to make an educated decision on the fastest approach
Measure-Command -Expression { $computers | Where-Object {$_.Equals("WKMJ059G4B")} | ForEach-Object { Test-Connection -ComputerName $_ -Count 1 } }
Measure-Command -Expression { $computers.Where({$_.Equals("WKMJ059G4B")}) | ForEach-Object { Test-Connection -ComputerName $_ -Count 1 } }

## Functions allow your script to be modular so you can just run specific parts
## Functions also allow you to do loops and re-run code without having to type it multiple times
function CreateFile {
    New-Item c:\temp\$name.txt -ItemType File
}

$name = "Dog"
CreateFile
$name = "Cat"
CreateFile
$name = "Mouse"
CreateFile

## Comments
## See this script!

## Quotes are very important, especially when you want specific output
## Single quotes evaluate as a string
## Double quotes allow variable expansion
$Test = "123"

Write-Output 'Test = $Test'
Write-Output "Test = $Test"