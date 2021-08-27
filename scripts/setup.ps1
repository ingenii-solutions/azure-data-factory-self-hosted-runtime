# Load the library of functions
. "$PSScriptRoot\lib.ps1"

# Register SHIR with key from Env Variable: AuthKey
if (Test-Registration) {
    Write-Log "Restart the existing node"

    if ($EnableHA -eq "True") {
        Write-Log "Enable High Availability"
        Write-Log "Remote Access Port: $($HAPort)"
        Start-Process $DmgcmdPath -Wait -ArgumentList "-EnableRemoteAccessInContainer", "$($HAPort)"
        Start-Sleep -Seconds 15
    }

    Start-Process $DmgcmdPath -Wait -ArgumentList "-Start"
}
elseif (Test-Path Env:AUTH_KEY) {
    Write-Log "Registering SHIR node with the node key: $($Env:AUTH_KEY)"
    Write-Log "Registering SHIR node with the node name: $($Env:NODE_NAME)"
    Write-Log "Registering SHIR node with the enable high availability flag: $($Env:ENABLE_HA)"
    Write-Log "Registering SHIR node with the tcp port: $($Env:HA_PORT)"
    
    Start-Process $DmgcmdPath -Wait -ArgumentList "-Start"

    Register-Node -AuthKey $Env:AUTH_KEY -NodeName $Env:NODE_NAME -EnableHA $Env:ENABLE_HA -HAPort $Env:HA_PORT
}
else {
    Write-Log "Invalid AUTH_KEY Value"
    exit 1
}

Write-Log "Waiting 60 seconds for connecting"
Start-Sleep -Seconds 60

try {
    $COUNT = 0
    $IS_REGISTERED = $false
    while ($true) {
        if (!$IS_REGISTERED) {
            if (Test-Registration) {
                $IS_REGISTERED = $true
                Write-Log "Self-hosted Integration Runtime is connected to the cloud service"
            }
        }

        if (Test-ProcessRunning) {
            $COUNT = 0
        }
        else {
            $COUNT += 1
            if ($COUNT -gt 5) {
                throw "Diahost.exe is not running"  
            }
        }

        Start-Sleep -Seconds 60
    }
}
finally {
    Write-Log "Stop the node connection"
    Start-Process $DmgcmdPath -Wait -ArgumentList "-Stop"
    Write-Log "Stop the node connection successfully"
    exit 0
}

exit 1