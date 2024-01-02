Import-Module $PSScriptRoot\common.ps1

function Test-NodeConnection() {
    Param(
        [string]$DmgCmdPath
    )

    Write-Log -Message "Attempting healthcheck..."

    $tempFileName = "healthcheck.txt"

    Start-Process $DmgCmdPath -Wait -ArgumentList "-CheckGatewayConnected" -RedirectStandardOutput $tempFileName
    $result = Get-Content $tempFileName
    Remove-Item -Force $tempFileName

    if ($result -like "Connected") {
        return $true
    } else {
        Write-Log -Message "Failed health check: $result"
        exit 1
    }
}

# Main
Test-NodeConnection -DmgCmdPath $dmgCmdPath