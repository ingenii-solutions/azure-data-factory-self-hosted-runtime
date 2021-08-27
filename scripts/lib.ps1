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
        return $true
    }

    $false
}