$dmgCmdPath = "C:\Program Files\Microsoft Integration Runtime\5.0\Shared\dmgcmd.exe"
function Write-Log() {
    Param(
        $Message
    )
    Write-Host "[$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss')] $Message"
}
