Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colCD = objWMIService.ExecQuery("Select * from Win32_CDROMDrive")

For Each objCD In colCD  '  If there are multiple CD drives, this loop will only set the variable for the last one listed
    strCDLetter = objCD.Drive
    wscript.echo "CD-ROM at " & strCDLetter
Next 

