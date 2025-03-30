##Copy file to machines from machines.txt

#Get machine names from text file
$Computers =  Get-Content "C:\temp\machines.txt"

#Source file to copy
$Source = "C:\temp\Shopping.Admin.Client.exe.config"

#Destination
$destination = "C$\Program Files (x86)\1E\Shopping\AdminConsole"

Foreach ($computer in $Computers)
{
    If ((Test-Path -Path \\$computer\$destination))
    {
        Copy-Item $Source -Destination "\\$computer\$destination" -Recurse
    }
    Else
    {
        "\\$computer\$destination is not reachable or does not exist."
    }
}
