1. Install ODBC driver - \\wkmjxzhnb\shared\Packages\ACE ODBC
2. Get SharePoint LIST GUID
    a. Connect to SP list
    b. Export list to Excel
    c. Data tab -> Connections -> Select 'owssvr' -> Properties
    d. Definition Tab
    e. Command text
    f. Get <LISTNAME> 
    <LIST><VIEWGUID>{5C55037B-ADC0-4082-A1AD-DF673942B081}</VIEWGUID><LISTNAME>{79F3CD8B-ACAA-4182-8583-B7867067876F}</LISTNAME><LISTWEB>
3. Run PoSH scripts: P:\Dept907.CIT\Windows\Scripts\SharePoint
