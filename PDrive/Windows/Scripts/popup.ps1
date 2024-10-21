$msg = new-object -comobject wscript.shell
$Answer = $msg.popup("This is a message box!",`
0,"Message Box",0)
$msg.popup("Goodbye.")

# Reference: http://www.devguru.com/technologies/wsh/quickref/wshshell_popup.html

# Value Button 
# 0 OK 
# 1 OK, Cancel 
# 2 Abort, Ignore, Retry 
# 3 Yes, No, Cancel 
# 4 Yes, No 
# 5 Retry, Cancel 
 
#   Value Icon 
# 16 Critical 
# 32 Question 
# 48 Exclamation 
# 64 Information 

# intReturnValue Button Clicked 
# 1 OK 
# 2 Cancel 
# 3 Abort 
# 4 Retry 
# 5 Ignore 
# 6 Yes 
# 7 No 
# -1 None, message box was dismissed automatically (timeout) 
