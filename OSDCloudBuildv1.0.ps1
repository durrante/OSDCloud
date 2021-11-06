#================================================
#   OSDCloud Task Sequence
#   Windows 10 21H1 Pro en-gb Retail
#   No Autopilot
#   No Office Deployment Tool
#================================================
#   PreOS
#   Install and Import OSD Module
#================================================
Install-Module OSD -Force
Import-Module OSD -Force
#================================================
#   [OS] Start-OSDCloud with Params
#================================================
$Params = @{
    OSBuild = "21H1"
    OSEdition = "Pro"
    OSLanguage = "en-gb"
    OSLicense = "Retail"
    SkipAutopilot = $true
    SkipODT = $true
}
Start-OSDCloud @Params
#================================================
#   WinPE PostOS Sample
#   AutopilotOOBE Offline Staging
#================================================
Install-Module AutopilotOOBE -Force
Import-Module AutopilotOOBE -Force

$Params = @{
    "Assign":  {
                   "IsPresent":  true
               },
    "AssignedComputerNameExample":  "Azure AD Join Only",
    "GroupTagOptions":  [
                            "ISL"
                        ],
    "Hidden":  [
                   "AddToGroup",
                   "AssignedComputerName",
                   "AssignedUser"
               ],
    "PostAction":  "Restart",
    "Run":  "PowerShell",
	"Disabled":	"Assign"
    "Docs":  "https://docs.microsoft.com/en-us/mem/autopilot/windows-autopilot",
    "Title":  "Autopilot Registration"
}

AutopilotOOBE @Params
#================================================
#   WinPE PostOS Sample
#   OOBEDeploy Offline Staging
#================================================
$Params = @{
    Autopilot = $true
    RemoveAppx = "CommunicationsApps","OfficeHub","People","Skype","Solitaire","Xbox","ZuneMusic","ZuneVideo"
    UpdateDrivers = $true
    UpdateWindows = $true
}
Start-OOBEDeploy @Params
#================================================
#   PostOS
#   Restart-Computer
#================================================
Restart-Computer
