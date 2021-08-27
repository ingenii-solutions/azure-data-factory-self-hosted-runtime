
# ---------------------------------------------------------------------------------------------------------------------
# PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------
Param(
    $RuntimeDownloadUrl,
    $Workdir = $(Get-Location)
)

# ---------------------------------------------------------------------------------------------------------------------
# IMPORTS
# ---------------------------------------------------------------------------------------------------------------------
. "$PSScriptRoot\common.ps1"

# ---------------------------------------------------------------------------------------------------------------------
# FUNCTIONS
# ---------------------------------------------------------------------------------------------------------------------
function Get-Runtime() {
    Param(
        $Uri,
        $Destination
    )

    Start-BitsTransfer -Source $Uri -Destination $Destination
}

function Install-Runtime() {
    Param(
        $Workdir
    )
    Write-Log "Installing the ADF Self-Hosted Integration Runtime..."

    $MsiFileName = (Get-ChildItem -Path $Workdir | Where-Object { $_.Name -Match "IntegrationRuntime.*.msi" })[0].Name
    Write-Log $MsiFileName

    Start-Process msiexec.exe -Wait -ArgumentList "/i $MsiFileName /qn"
    if (!$?) {
        Write-Log "Installation failed."
        exit 1
    }

    Write-Log "Installaton complete."
}

function Clear-Workdir() {
    Param(
        $Workdir
    )

    Get-ChildItem $Workdir | Where-Object { $_.Name -Match "IntegrationRuntime.*.msi" } | Remove-Item -Force
}

# ---------------------------------------------------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------------------------------------------------

# Download
try {
    Get-Runtime -Uri $RuntimeDownloadUrl -Destination $Workdir
}
catch {
    Write-Log -Message "Unable to download the runtime installation file from URL: $RuntimeDownloadUrl"
    Write-Log -Message $_
    exit 1
}

# Install
Install-Runtime

# Clean
Clear-Workdir -Workdir $Workdir