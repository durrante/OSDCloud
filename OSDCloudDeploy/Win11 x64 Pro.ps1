#================================================
#   OSDCloud Build Sequence
#   WARNING: Will wipe hard drive without prompt!!
#   Windows 11 23H2 Pro en-gb Retail
#   Deploys OS
#   Updates OS
#   Removes AppX Packages from OS
#   No Office Deployment Tool
#   Creates post deployment scripts for Autopilot
#================================================
#   PreOS
#   Set VM Display Resolution
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Cyan "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}
#================================================
#   PreOS
# Set TLS to 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
#   Install and Import OSD Module
Install-Module OSD -Force -AllowClobber -SkipPublisherCheck
Import-Module OSD -Force 

#================================================
#   [OS] Start-OSDCloud with Params
#================================================
$Params = @{
    OSName = "Windows 11 23H2 x64"
    OSEdition = "Pro"
    OSLanguage = "en-gb"
    OSLicense = "Retail"
    SkipAutopilot = $true
    SkipODT = $true
    ZTI = $True
}
Start-OSDCloud @Params
#================================================
#   WinPE PostOS Sample
#   AutopilotOOBE Offline Staging
#================================================
Install-Module AutopilotOOBE -Force -AllowClobber -SkipPublisherCheck
Import-Module AutopilotOOBE -Force

$Params = @{
    Title = 'Autopilot Registration'
    GroupTagOptions = '2021', 'Base', 'DILKIOSK', 'EPAS', 'EPAA', 'ISL'
    Hidden = 'AddToGroup','AssignedComputerName','AssignedUser','PostAction'
    Assign = $true
    PostAction = 'Restart'
    Run = 'PowerShell'
    Disabled = 'Assign'
}
AutopilotOOBE @Params
#================================================
#   WinPE PostOS Sample
#   OOBEDeploy Offline Staging
#================================================
$Params = @{
    Autopilot = $true
    RemoveAppx = "CommunicationsApps","OfficeHub","People","Skype","Solitaire","Xbox","ZuneMusic","ZuneVideo","GetHelp","BingWeather","GamingApp","WindowsMaps","BingNews","MicrosoftTeams"
    UpdateDrivers = $true
    UpdateWindows = $true
}
Start-OOBEDeploy @Params
#================================================
#   WinPE PostOS
#   Set OOBEDeploy CMD.ps1
#================================================
$SetCommand = @'
@echo off

:: Set the PowerShell Execution Policy
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force

:: Add PowerShell Scripts to the Path
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts

:: Open and Minimize a PowerShell instance just in case
start PowerShell -NoL -W Mi

:: Install the latest OSD Module
start "Install-Module OSD" /wait PowerShell -NoL -C Install-Module OSD -Force -Verbose

:: Start-OOBEDeploy
:: The next line assumes that you have a configuration saved in C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json
start "Start-OOBEDeploy" PowerShell -NoL -C Start-OOBEDeploy

exit
'@
$SetCommand | Out-File -FilePath "C:\Windows\OOBEDeploy.cmd" -Encoding ascii -Force
#================================================
#   WinPE PostOS
#   Set AutopilotOOBE CMD.ps1
#================================================
$SetCommand = @'
@echo off

:: Set the PowerShell Execution Policy
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force

:: Add PowerShell Scripts to the Path
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts

:: Open and Minimize a PowerShell instance just in case
start PowerShell -NoL -W Mi

:: Install the latest AutopilotOOBE Module
start "Install-Module AutopilotOOBE" /wait PowerShell -NoL -C Install-Module AutopilotOOBE -Force -Verbose

:: Start-AutopilotOOBE
:: The next line assumes that you have a configuration saved in C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json
start "Start-AutopilotOOBE" PowerShell -NoL -C Start-AutopilotOOBE

exit
'@
$SetCommand | Out-File -FilePath "C:\Windows\Autopilot.cmd" -Encoding ascii -Force

#================================================
#   PostOS
#   Restart-Computer & Display Message
#================================================
# Display a banner of asterisks for emphasis
Write-Host -ForegroundColor Yellow "*************************************************************************"

# Display the word "IMPORTANT!" in red and enlarged text
Write-Host -ForegroundColor Red "`n`n`n                  IMPORTANT! IMPORTANT! IMPORTANT!`n`n`n"

# Display another banner of asterisks for emphasis
Write-Host -ForegroundColor Yellow "*************************************************************************"

# Display the instructions in Cyan for better readability
Write-Host -ForegroundColor Cyan -NoNewline "INSTRUCTIONS: "
Write-Host -ForegroundColor White "Ensure to run the C:\Windows\OOBEDeploy.cmd to complete the Autopilot readiness build."

# Load System.Windows.Forms for MessageBox functionality
Add-Type -AssemblyName System.Windows.Forms

# Define the message and title for the MessageBox
$message = "Please remove the build USB stick and click OK to restart your device and continue with the OSDCloud setup process."
$title = "Action Required Before Restart"

# Show the MessageBox and wait for the user to click OK
[System.Windows.Forms.MessageBox]::Show($message, $title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Restart the device
wpeutil reboot
