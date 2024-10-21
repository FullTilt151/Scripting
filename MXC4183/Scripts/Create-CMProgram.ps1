$parameters = @{
    PackageID = "WQ1013BE"
    StandardProgramName = "Uninstall All"
    CommandLine = "Deploy-Application.ps1 -Version Nuke"
    RunType = "Normal"
    ProgramRunType = "WhetherOrNotUserIsLoggedOn"
    DiskSpaceRequirement = 200
    DiskSpaceUnit = "MB"
    Duration = 120
    DriveMode = "RunWithUnc"
  }


  New-CMProgram @parameters

