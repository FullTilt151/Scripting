@echo off
Echo This batch file will Set Service Object Security for WUAUSERV and BITS.
REM Result will be written to %temp%\SetServiceObjectSecurity.log and then launched in Notepad.
Echo Please wait...
@echo on
sc sdset bits "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" >c:\temp\SetServiceObjectSecurity.log
sc sdset wuauserv "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" >>c:\temp\SetServiceObjectSecurity.log
sc stop wuauserv >>c:\temp\SetServiceObjectSecurity.log
sc stop BITS >>c:\temp\SetServiceObjectSecurity.log
sc start BITS >>c:\temp\SetServiceObjectSecurity.log
sc start wuauserv >>c:\temp\SetServiceObjectSecurity.log
@echo off
