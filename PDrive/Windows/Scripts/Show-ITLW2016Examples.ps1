region ConditionalStatements {
    1 -eq $true # 1 is always $true, everything else is false
    0 -eq $true
    2 -eq $true
    1 -ne $null # Existential check, and 1 does exist, so its true
    1 -eq 2
    'a' -eq $true # strings are not true
    $i = 3
    $i -eq $true # It's not 1, so it's false
    $i -lt 5 # i is less than 5, so its true
    if ($i) { # Since we didnt specify a condition, it's an existential check, not conditional
        write-host 'True'
    }
}

region ConditionalBranches {
    # if/elseif/else
    # Useful for checking for small number of items
    $variable = 1
    if ($variable -eq 1) {
        Write-Output '1'
    } elseif ($variable -eq 2) {
        Write-Output '2'
    } else {
        Write-Output 'Not 1 or 2'
    }

    # switch statement
    # Useful for checking for larger number of items
    $variable = 'card'
    switch -Wildcard ($variable) {
        1 { Write-Output '1' }
        2 { Write-Output '2' }
        ca* { Write-Output 'Starts with ca' } # You could add a break here
        card { Write-Output 'Card' }
        default { Write-Output 'Not anything above' }
    }
}

region Loops {
    # do/until
    # Does something once, and loops until condition evaluates to true
    $i = 0
    do {
        $i
        $i++
    } until ($i -gt 5)

    # do/while
    # Does something once, and loops while condition evalutes to true
    $i = 0
    do {
        $i
        $i++
    } while ($i -le 5)

    # while
    # Loops only while the condition evaluates to true
    $i = 0
    while ($i -le 5) {
        $i
        $i++
    }

    # for
    # Sets the variable, sets the condition that must evaluate to true, sets the increment
    for ($i=0; $i -le 5 ;$i++) {
        $i
    }

    # foreach
    # Runs a scriptblock that iterates against a set of objects in an variable
    $numbers = 1,2,3,4,5
    foreach ($number in $numbers) {
        $number # Current object variable
        $number.GetType().Name
    }

    # Foreach-Object
    # Runs a scriptblock that iterates against a set of objects passed through the pipeline
    $array = (1..5)
    $array | ForEach-Object {
        $psitem # psitem is the current object
        $_.GetType().Name # $_ is another method for current object
    }
}

region Transcripts/Logging {
    ### Transcripts ###
    Start-Transcript -Path c:\temp\ITLWTranscript.log -Append
    
    # Transcripts only accept write-output, not write-host
    Write-Output 'Good ol'' output'
    
    # Why is my output on a new line?
    Write-Output "The date is: "(Get-Date -Format MM/dd/yyyy)
    
    # Put a dollar sign before your declaration and move it inside the double quotes
    Write-Output "The date is: $(Get-Date -Format MM/dd/yyyy)"

    Stop-Transcript

    ### Logging ###

    ## DEMO: New-LogEntry
}

region ObjectTypes {
    # Create an object, in this case the processes running on your computer
    $object = Get-Process

    # Show the object, in this case an array of all process objects
    $object

    # Show every member and value of each object in the array
    $object | Select-Object *

    # What types of members does each object have?
    $object | Get-Member

    # See what type of object it is (shown at the top of Get-Member)
    $object[0].GetType()

    # What is just the name property?
    $object.GetType().Name
            
    # How many objects are in the array?
    $object.Count

    # What is the first object in the array?
    $object[0]

    # What are all the members and values of this object?
    $object[0] | Select-Object *

    # What are the members of this object?
    $object[0] | Get-Member

    # See what type of object it is (shown at the top of Get-Member)
    $object[0].GetType()

    # What is just the name property?
    $object[0].GetType().Name

    # What are some of the object properties?
    $object[0].Name
    $object[0].Path

    # What about a method?
    $ObjectNotepad = Get-Process -Name notepad2
    $ObjectNotepad.Kill()
}

region Filtering {
     # Show all processes
     Get-Process | Get-Member

     # Use Select-Object to pick just the columns you want
     Get-Process | Select-Object Id, Name, PagedMemorySize, ProcessorAffinity, StartTime, Path
     
     # Want a table instead? Use format-table
     Get-Process | Select-Object Id, Name, PagedMemorySize, ProcessorAffinity, StartTime, Path | Format-Table

     # You can even exclude the select-object cmdlet in your pipeline
     Get-Process | Format-Table Id, Name, PagedMemorySize, ProcessorAffinity, StartTime, Path
     
     # Format-table can even autosize each column for you
     Get-Process | Format-Table Id, Name, PagedMemorySize, ProcessorAffinity, StartTime, Path -AutoSize

     # Want an interactive table with a nice GUI?
     Get-Process | Out-GridView
    
     # Get all processes from WMI
     Get-WmiObject -Namespace root\cimv2 -Class win32_process

     # Filter to just ccmexec using where-object
     Get-WmiObject -Namespace root\cimv2 -Class win32_process | Where-Object {$_.Name -eq 'CcmExec.exe'}

     # Filter to just ccmexec using the where method
     (Get-WmiObject -Namespace root\cimv2 -Class win32_process).where({$_.Name -eq 'CcmExec.exe'}) 

     # Filter to just ccmexec using the -Filter parameter
     Get-WmiObject -Namespace root\cimv2 -Class win32_process -Filter "Name = 'CcmExec.exe'"

     # Which command is fastest?
     Measure-Command -Expression { Get-WmiObject -Namespace root\cimv2 -Class win32_process | Where-Object {$_.Name -eq 'CcmExec.exe'} }
     Measure-Command -Expression { (Get-WmiObject -Namespace root\cimv2 -Class win32_process).where({$_.Name -eq 'CcmExec.exe'})  }
     Measure-Command -Expression { Get-WmiObject -Namespace root\cimv2 -Class win32_process -Filter "Name = 'CcmExec.exe'" }
}

region AdvancedFiltering {
    # Get some large content
    $Log = Get-Content C:\windows\ccmsetup\logs\ccmsetup.log
    
    # Give me the return code in this log
    $Log | Select-String 'return code'

    # Give me the last return code in this log
    $Log | Select-String 'return code' | Select-Object -Last 1

    #Set some variables
    $LogFileDir = 'C:\Temp'
    $ScriptName = 'Something.ps1'

    #This isused to build the log file name, first we need to make sure the directory ends in '\'
    $LogFileDir
    if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
    $LogFileDir

    #Next, we need the scriptname - '.ps1'
    $LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
    $ScriptName
    $LogFile

    #We combine the two and get our logfile name
    $LogFile = $LogFileDir + $LogFile + '.log'
    $Logfile
    
    $DataBaseServer = '["Display=CM_CAS"]SQL:["SMS_SITE=CAS"]\\LOUSQLWPS401.rsc.humad.com\CM_CAS\'
    $Database = '["Display=CM_CAS"]SQL:["SMS_SITE=CAS"]\\LOUSQLWPS401.rsc.humad.com\CM_CAS\'
    $DataBaseServer -replace '.*\\\\([A-Z0-9_.]+)\\.*', '$+'
    $DataBaseServer -match '.*\\\\([A-Z0-9_.]+)\\.*' | Out-Null ; $Matches
    $Database -replace '.*\\([A-Z_]*?)\\$', '$+'
}