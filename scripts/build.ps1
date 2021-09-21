Param(
    $RuntimeDownloadUrl,
    $Workdir = $(Get-Location)
)

# Download the runtime
try {
    Start-BitsTransfer -Source $RuntimeDownloadUrl -Destination $Workdir
}
catch {
    Write-Log -Message "Unable to download the runtime installation file from URL: $RuntimeDownloadUrl"
    Write-Log -Message $_
    exit 1
}

# Install the runtime
try {
    Write-Log -Message "Installing the ADF Self-Hosted Integration Runtime..."

    $MsiFileName = (Get-ChildItem -Path $Workdir | Where-Object { $_.Name -Match "IntegrationRuntime.*.msi" })[0].Name
    Write-Log -Message $MsiFileName

    Start-Process msiexec.exe -Wait -ArgumentList "/i $MsiFileName /qn"
    if (!$?) {
        Write-Log -Message "Installation failed."
        exit 1
    }

    Write-Log -Message "Installaton complete."
}
catch {
    Write-Log -Message "Unable to install the runtime."
    Write-Log -Message $_
    exit 1
}

# Clean up the working directory
Get-ChildItem $Workdir | Where-Object { $_.Name -Match "IntegrationRuntime.*.msi" } | Remove-Item -Force