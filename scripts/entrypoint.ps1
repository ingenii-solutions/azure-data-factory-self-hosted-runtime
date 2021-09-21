Import-Module $PSScriptRoot\common.ps1

function Test-NodeRegistration() {
    $result = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\DataTransfer\DataManagementGateway\ConfigurationManager' -Name HaveRun -ErrorAction SilentlyContinue
    
    if (($result -ne $null) -and ($result.HaveRun -eq 'Mdw')) {
        return $true
    }

    return $false
}

function Test-NodeProcessRunStatus() {
    $result = Get-WmiObject Win32_Process -Filter "name = 'diahost.exe'"

    if ($result) {
        return $true
    }

    return $false
}

# Main

if (Test-NodeRegistration) {
    Write-Log -Message "Starting the Self-Hosted Runtime process..."

    # The node is already registered.
    Start-Process $dmgCmdPath -Wait -ArgumentList "-Start"

}
elseif ($env:AUTH_KEY) {
    $authKey = $env:AUTH_KEY

    Write-Log -Message "Registering the current node with Azure Data Factory..."

    Start-Process $dmgCmdPath -Wait -ArgumentList "-Start"

    if ($env:ENABLE_HA -eq "true") {
        if ($env:HA_PORT) {
            $haPort = $env:HA_PORT
        }
        else {
            $haPort = "8060"
        }

        Start-Process $dmgCmdPath -Wait -ArgumentList "-EnableRemoteAccessInContainer", "$($haPort)"

        Write-Log -Message "High Availability: Enabled"
    }
    
    if ($env:NODE_NAME) {
        $nodeName = $env:NODE_NAME
    }
    else {
        $nodeName = $env:COMPUTERNAME
    }

    Write-Log -Message "Node Name: $nodeName"

    if ($env:OFFLINE_NODE_AUTO_DELETION_TIME_IN_SECONDS) {
        $offlineNodeAutoDeletionTimeInSeconds = $env:OFFLINE_NODE_AUTO_DELETION_TIME_IN_SECONDS
    }
    else {
        $offlineNodeAutoDeletionTimeInSeconds = "601"
    }

    Write-Log -Message "Auto Deletion Offline Nodes: In $offlineNodeAutoDeletionTimeInSeconds seconds after they are unreachable."

    $registerStdOut = "register-out.txt"
    $registerStdErr = "register-err.txt"

    # Node registration
    Start-Process $dmgCmdPath -Wait -ArgumentList "-RegisterNewNode", "$($authKey)", "$($nodeName)", "$($offlineNodeAutoDeletionTimeInSeconds)" -RedirectStandardOutput $registerStdOut -RedirectStandardError $registerStdErr

    $registerStdOutResult = Get-Content $registerStdOut
    $registerStdErrResult = Get-Content $registerStdErr

    if ($registerStdOutResult) {
        Write-Log -Message "Registration Output"
        $registerStdOutResult | ForEach-Object { Write-Log -Message $_ }
    }

    if ($registerStdErrResult) {
        Write-Log -Message "Registration Errors"
        $registerStdErrResult | ForEach-Object { Write-Log -Message $_ }

        exit 1
    }

    # Wait for the connection to be established.
    Start-Sleep 120

    Write-Log -Message "Registration complete."

}
else {
    Write-Log -Message "AUTH_KEY environment variable is missing." -TextColor Red
    exit 1
}

# Infinite loop (keeping the Docker container running)
try {
    $count = 0
    $is_registered = $false

    while ($true) {
        if (!$is_registered) {
            if (Test-NodeRegistration) {
                $is_registered = $true
                Write-Log -Message  "The Self-Hosted Integration Runtime is connected to Azure Data Factory."
            }
        }

        if (Test-NodeProcessRunStatus) {
            $count = 0
        }
        else {
            $count += 1
            if ($count -gt 5) {
                throw "The runtime process (diahost.exe) is not running."
            }
        }

        Start-Sleep -Seconds 60
    }

}
finally {
    Write-Log -Message  "Stopping the runtime process..."
    Start-Process $dmgCmdPath -Wait -ArgumentList "-Stop"
    Write-Log -Message  "Stopped."

    exit 0
}

exit 1