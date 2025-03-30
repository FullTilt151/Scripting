# XDUser-IDCleanUP.ps1
#
# Brent Griffith Client Innovation Tech.  Thanks to Jim Parris!!!
#
# Reads a list of IDs.  Removes duplicates and GUIDS.
#
# Raw data comes from the VAS team and is read from the file usersIn.csv
# Output is written to usersOut.csv
#
# v 1.0  - 01/10/17 - Initial script.
#

# Load an array with the list of users from file.
$usersCSV = Get-Content -Path 'Users.csv'
# Initialize the array to hold the results.  
$users = @()

# Walk the input data.   
foreach($usr in $usersCSV)
{
    if($usr -match ';')  # Rows with multiple Users will have the ID separated by a ;.  If a ; is found split the users apart. 
    {
        $users += $usr -split ';'
    }
    elseif($usr -ne '' -and $usr -ne $null)  # As long as the line is not blank store it in the array. 
    {
        $users += $usr
    }
}

# Sort resulting array of users and remove unique items.
$users = $users | Sort-Object -Unique 


# Filter the results to only include IDs that are HUMAD and remove GUIDs.

# Initialize the array to hold the results.
$finalList = @()

# Walk the data representing separated IDs looking for an indicator its not a GUID and the ID is in HUMAD.  
foreach($user in $users) 
{
    if($user -notmatch '^S-1-5-\d' -and $user -match '^HUMAD\\')
    {
        $finalList += [Array]$user -replace '.*\\(.*)','$1'
    }
}

# Generate the output file name - include date and time.
$DateTime = Get-Date -Format MM-dd-yyyy--hh-mm-sstt
$OutFileName = 'UsersOut' +'-'+ $DateTime + '.csv'

#Write the results to file.
Add-Content -Value $finalList -Path $OutFileName  
