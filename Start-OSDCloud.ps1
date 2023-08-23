Write-Host -ForegroundColor Green "Starting OSDCloud"
Start-Sleep -Seconds 5

#Change Display Resolution for Virtual Machine
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Green "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

#Update OSD Module
Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
Install-Module OSD -Force -AllowClobber -SkipPublisherCheck

Write-Host  -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force

#Start OSDCloudScriptPad
Write-Host -ForegroundColor Green "Start OSDPad"
Start-OSDPad -RepoOwner Durrante -RepoName OSDCloud -RepoFolder OSDCloudDeploy -Hide Script -BrandingTitle 'OSDCloud Deployment'
