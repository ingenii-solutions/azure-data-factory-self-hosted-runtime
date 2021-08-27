$dmgCmdPath = "C:\Program Files\Microsoft Integration Runtime\5.0\Shared\dmgcmd.exe"
function Write-Log() {
    Param(
        $Message
    )
    Write-Host "[$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss')] $Message"
}

function Get-FileFromUrl() {
    Param(
        $Url,
        $Destination
    )

    Start-BitsTransfer -Source $Url -Destination $Destination
}

function Install-Runtime() {
    Param(
        $Workdir
    )
    Write-Log "Installing the ADF Self-Hosted Integration Runtime..."

    $MsiFileName = (Get-ChildItem -Path $Workdir | Where-Object { $_.Name -Match "IntegrationRuntime.*.msi" })[0].Name
    Write-Log $MsiFileName

    Start-Process msiexec.exe -Wait -ArgumentList "/i $MsiFileName /qn"
    if (!$?) {
        Write-Log "Installation failed."
        exit 1
    }

    Write-Log "Installaton complete."
}

function Clear-Workdir() {
    Param(
        $Workdir
    )

    Get-ChildItem $Workdir | Where-Object { $_.Name -Match "IntegrationRuntime.*.msi" } | Remove-Item -Force
}

function Test-NodeConnection() {
    $outputFile = "status-check.txt"

    Start-Process $DmgcmdPath -Wait -ArgumentList "-cgc" -RedirectStandardOutput $outputFile
    
    $ConnectionResult = Get-Content $outputFile
    
    Remove-Item -Force $outputFile

    if ($ConnectionResult -like "Connected") {
        exit 0
    }

    exit 1
}

function Test-Registration() {
    $result = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\DataTransfer\DataManagementGateway\ConfigurationManager' -Name HaveRun -ErrorAction SilentlyContinue
    if (($null -ne $result) -and ($result.HaveRun -eq 'Mdw')) {
        return $true
    }
    return $false
}

function Test-ProcessRunning() {
    $ProcessResult = Get-WmiObject Win32_Process -Filter "name = 'diahost.exe'"
    
    if ($ProcessResult) {
        return $true
    }

    Write-Log "diahost.exe is not running"
    return $false
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
        Start-Process $DmgcmdPath -Wait -ArgumentList "-RegisterNewNode", "$($AuthKey)" -RedirectStandardOutput $registerOutFile -RedirectStandardError $registerErrFile
    }
    else {
        Start-Process $DmgcmdPath -Wait -ArgumentList "--RegisterNewNode", "$($AuthKey)", "$($NodeName)" -RedirectStandardOutput $registerOutFile -RedirectStandardError $registerErrFile
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