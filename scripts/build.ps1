
Param(
    $RuntimeDownloadUrl,
    $Workdir = $(Get-Location)
)

. "$PSScriptRoot\lib.ps1"

try {
    Get-FileFromUrl -Uri $RuntimeDownloadUrl -Destination $Workdir
}
catch {
    Write-Log -Message "Unable to download the runtime installation file from URL: $RuntimeDownloadUrl"
    Write-Log -Message $_
    exit 1
}

try {
    Install-Runtime -Workdir $Workdir
}
catch {
    Write-Log -Message "Unable to install the runtime."
    Write-Log -Message $_
    exit 1
}


Clear-Workdir -Workdir $Workdir