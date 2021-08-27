$DmgcmdPath = "C:\Program Files\Microsoft Integration Runtime\5.0\Shared\dmgcmd.exe"

# ---------------------------------------------------------------------------------------------------------------------
# FUNCTIONS
# ---------------------------------------------------------------------------------------------------------------------
function Write-Log() {
    Param(
        $Message
    )
    Write-Host "[$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss')] $Message"
}

function Test-Registration() {
    $result = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\DataTransfer\DataManagementGateway\ConfigurationManager' -Name HaveRun -ErrorAction SilentlyContinue
    if (($result -ne $null) -and ($result.HaveRun -eq 'Mdw')) {
        return $True
    }
    return $False
}

function Test-ProcessRunning() {
    $ProcessResult = Get-WmiObject Win32_Process -Filter "name = 'diahost.exe'"
    
    if ($ProcessResult) {
        return $True
    }

    Write-Log "diahost.exe is not running"
    return $False
}


function Register-Node {
    Param(
        $AuthKey,
        $NodeName,
        $EnableHA = $True,
        $HAPort = "8060"
    )

    $registerOutFile = "register-out.txt"
    $registerErrFile = "register-error.txt"

    Write-Log "Start registering a new SHIR node"

    if ($EnableHA -eq "True") {
        Write-Log "Enable High Availability"
        Write-Log "Remote Access Port: $($HAPort)"
        Start-Process $DmgcmdPath -Wait -ArgumentList "-EnableRemoteAccessInContainer", "$($HAPort)" -RedirectStandardOutput $registerOutFile -RedirectStandardError $registerErrFile
        Start-Sleep -Seconds 15
    }

    if (!$NodeName) {
        Start-Process $DmgcmdPath -Wait -ArgumentList "-Register-Node", "$($AuthKey)" -RedirectStandardOutput $registerOutFile -RedirectStandardError $registerErrFile
    }
    else {
        Start-Process $DmgcmdPath -Wait -ArgumentList "-Register-Node", "$($AuthKey)", "$($NodeName)" -RedirectStandardOutput $registerOutFile -RedirectStandardError $registerErrFile
    }

    $StdOutResult = Get-Content $registerOutFile
    $StdErrResult = Get-Content $registerErrFile

    if ($StdOutResult) {
        Write-Log "Registration output:"
        $StdOutResult | ForEach-Object { Write-Log $_ }
    }

    if ($StdErrResult) {
        Write-Log "Registration errors:"
        $StdErrResult | ForEach-Object { Write-Log $_ }
    }
}

# Register SHIR with key from Env Variable: AuthKey
if (Test-Registration) {
    Write-Log "Restart the existing node"

    if ($EnableHA -eq "True") {
        Write-Log "Enable High Availability"
        $PORT = $HAPort
        if (!$HAPort) {
            $PORT = "8060"
        }
        Write-Log "Remote Access Port: $($PORT)"
        Start-Process $DmgcmdPath -Wait -ArgumentList "-EnableRemoteAccessInContainer", "$($PORT)"
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
    $IS_REGISTERED = $False
    while ($True) {
        if (!$IS_REGISTERED) {
            if (Test-Registration) {
                $IS_REGISTERED = $True
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