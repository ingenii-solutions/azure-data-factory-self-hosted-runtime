# ---------------------------------------------------------------------------------------------------------------------
# IMPORTS
# ---------------------------------------------------------------------------------------------------------------------
. "$PSScriptRoot\common.ps1"

function Test-NodeConnection() {
    $outputFile = "status-check.txt"

    Start-Process $DmgcmdPath -Wait -ArgumentList "-cgc" -RedirectStandardOutput $outputFile
    
    $ConnectionResult = Get-Content $outputFile
    
    Remove-Item -Force $outputFile

    if ($ConnectionResult -like "Connected") {
        return $true
    }

    $false
}

if (!Test-NodeConnection) { exit 1 }
