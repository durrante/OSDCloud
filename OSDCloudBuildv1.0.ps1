#================================================
#   OSDCloud Build Sequence
#   WARNING: Will wipe hard drive without prompt!!
#   Windows 10 21H1 Pro en-gb Retail
#   Deploys OS
#   Updates OS
#   Removes AppX Packages from OS
#   No Office Deployment Tool
#   Creates post deployment scripts for Autopilot
#   Installs latest versions of Edge and OneDrive
#================================================
#   PreOS
#   Set VM Display Resolution
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Cyan "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}
#================================================
#   PreOS
#   Install and Import OSD Module
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
    ZTI = $True
}
Start-OSDCloud @Params
#================================================
#   WinPE PostOS Sample
#   AutopilotOOBE Offline Staging
#================================================
Install-Module AutopilotOOBE -Force
Import-Module AutopilotOOBE -Force

$Params = @{
    Title = 'Autopilot Registration'
    GroupTagOptions = 'ISL'
    Hidden = 'AddToGroup','AssignedComputerName','AssignedUser','PostAction'
    Assign = $true
    Run = 'PowerShell'
	Disabled = 'Assign'
	Docs = 'https://docs.microsoft.com/en-gb/mem/autopilot/windows-autopilot'
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

:: Download and Install latest version of OneDrive
;Findstr -rbv ; %0 | powershell -c -
$URL = "https://go.microsoft.com/fwlink/?linkid=844652"
Write-Host -ForegroundColor Green "Downloading OneDriveSetup"
$dest = "$($env:TEMP)\OneDriveSetup.exe"
Invoke-WebRequest -uri $url -OutFile $dest
Write-Host -ForegroundColor Green "Installing: $dest"
$proc = Start-Process $dest -ArgumentList "/allusers /Silent" -WindowStyle Hidden -PassThru
$proc.WaitForExit()
Write-Host -ForegroundColor Green "OneDriveSetup exit code: $($proc.ExitCode)"

:: Download and Install latest version of Edge
;Findstr -rbv ; %0 | powershell -c -
$URL = "http://go.microsoft.com/fwlink/?LinkID=2093437"
Write-Host -ForegroundColor Green "Downloading Edge"
$dest = "$($env:TEMP)\MicrosoftEdgeEnterpriseX64.msi"
Invoke-WebRequest -uri $url -OutFile $dest
Write-Host -ForegroundColor Green "Installing: $dest"
$proc = Start-Process 'msiexec.exe' -ArgumentList "/i $dest /qn" -NoNewWindow -Wait -PassThru
$proc.WaitForExit()
Write-Host -ForegroundColor Green "Edge exit code: $($proc.ExitCode)"

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
#   Restart-Computer
#================================================
Write-Host -Foregroundcolor Red "IMPORTANT! - " -Nonewline
Write-Host -ForegroundColor Green "Autopilot Readiness Build has now completed, ensure that the additional steps are completed before handover, click any button to proceed and the device will restart."
read-host -Foregroundcolor Green "Press ANY key to continue..."
Wpeutil Reboot
