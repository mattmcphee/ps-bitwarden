function Clear-BWAppData {
    $BWAppdataPath = "$env:APPDATA\Bitwarden CLI"
    $BWAppdataBackupPath = "$env:APPDATA\Bitwarden CLI.backup"
    $SuccessMsg = ("Bitwarden CLI appdata cleared!`n" + 
        "Run 'bw status' to regenerate appdata!")

    if (Test-Path -Path $BWAppdataPath) {
        if (Test-Path -Path $BWAppdataBackupPath) {
            Remove-Item -Path $BWAppdataBackupPath -Force -Recurse -Verbose
            Write-Host "Bitwarden CLI backup appdata deleted."
        }

        Rename-Item -Path $BWAppdataPath -NewName $BWAppdataBackupPath -Verbose
        Write-Host $SuccessMsg
    } else {
        Write-Host $SuccessMsg
    }
}
