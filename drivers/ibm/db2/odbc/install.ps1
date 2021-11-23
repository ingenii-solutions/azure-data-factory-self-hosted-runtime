function Write-Log() {
    Param(
        [string] $Message,
        [string] $TextColor = "White"
    )

    $timeNow = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

    Write-Host "[$timeNow] $Message" -ForegroundColor $TextColor
}

function Install-Driver {
    Write-Log -Message "Installing the IBM DB2 ODBC Driver..."

    $setupFile = (Get-ChildItem -Path $PSScriptRoot | Where-Object { $_.Name -Match "setup.exe" })[0].Name
    $setupFilePath = Join-Path -Path $PSScriptRoot -ChildPath $setupFile
    
    Write-Log -Message $setupFilePath

    Start-Process $setupFilePath -Wait -ArgumentList "/n Default /u dsdriver.rsp" -WorkingDirectory $PSScriptRoot
    if (!$?) {
        Write-Log -Message "Installation failed."
        exit 1
    }

    Write-Log -Message "Installaton complete."

    # Clean up the driver directory
    $setupFilePath | Remove-Item -Force
}

# Install the driver
try {
    Install-Driver
}
catch {
    Write-Log -Message "Unable to install the driver."
    Write-Log -Message $_
    exit 1
}