function Fix-BW {
  Rename-Item -Path "%APPDATA%\Bitwarden CLI" -NewName "Bitwarden CLI.backup"
}