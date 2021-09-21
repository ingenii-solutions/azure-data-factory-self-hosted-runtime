Import-Module $PSScriptRoot\common.ps1

function Test-NodeConnection() {
    Param(
        [string]$DmgCmdPath
    )

    $tempFileName = "healthcheck.txt"

    Start-Process $DmgCmdPath -Wait -ArgumentList "-CheckGatewayConnected" -RedirectStandardOutput $tempFileName
    $result = Get-Content $tempFileName
    Remove-Item -Force $tempFileName

    if ($result -like "Connected") {
        return $true
    } else {
        exit 1
    }
}

# Main
Test-NodeConnection -DmgCmdPath $dmgCmdPath