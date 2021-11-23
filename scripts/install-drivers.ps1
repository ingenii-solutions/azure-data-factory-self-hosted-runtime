Param(
    $Workdir = $(Get-Location)
)

Import-Module $PSScriptRoot\common.ps1

Write-Log -Message "Installing additional drivers.."

# Install vendor drivers
$DriversPath = Join-Path -Path $Workdir -ChildPath "drivers"
$InstallScriptName = "install.ps1"

$DriverInstallScripts = Get-ChildItem -Path $DriversPath -Filter $InstallScriptName -Recurse

# Find the install.ps1 script in each driver directory and call it.
ForEach ($script in $DriverInstallScripts) {
    # Call the install script in the driver folder.
    &$script.FullName
}

Write-Log -Message "Additional drivers installed."