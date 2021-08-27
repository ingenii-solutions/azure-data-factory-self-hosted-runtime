Param(
    $RuntimeDownloadUrl,
    $Workdir = $(Get-Location)
)

# Load the library of functions
. "$PSScriptRoot\lib.ps1"

# Download the runtime
try {
    Get-FileFromUrl -Url $RuntimeDownloadUrl -Destination $Workdir
}
catch {
    Write-Log -Message "Unable to download the runtime installation file from URL: $RuntimeDownloadUrl"
    Write-Log -Message $_
    exit 1
}

# Install the runtime
try {
    Install-Runtime -Workdir $Workdir
}
catch {
    Write-Log -Message "Unable to install the runtime."
    Write-Log -Message $_
    exit 1
}

# Clean up the working directory
Clear-Workdir -Workdir $Workdir