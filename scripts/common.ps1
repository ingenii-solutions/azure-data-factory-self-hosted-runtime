$dmgCmdPath = "C:\Program Files\Microsoft Integration Runtime\5.0\Shared\dmgcmd.exe"

function Write-Log() {
    Param(
        [string] $Message,
        [string] $TextColor = "White"
    )

    $timeNow = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

    Write-Host "[$timeNow] $Message" -ForegroundColor $TextColor
}