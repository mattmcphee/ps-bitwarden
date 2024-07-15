function Fix-BW {
  Rename-Item -Path "$env:APPDATA\Bitwarden CLI" -NewName "Bitwarden CLI.backup"
}