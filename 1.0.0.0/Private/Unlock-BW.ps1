<#
.SYNOPSIS
Helper function that sets up api key and password env vars and then logs in
unlocks vault and gets the session key and stores it in an env var

.DESCRIPTION
Helper function that sets up api key and password env vars and then logs in
unlocks vault and gets the session key and stores it in an env var

.EXAMPLE
Unlock-BW
#>
function Unlock-BW {
    if (Test-Path env:BW_PASSWORD) {
        $bwPass = $env:BW_PASSWORD
    } else {
        $bwPass = Read-Host -AsSecureString "BitWarden Master Password"
        $env:BW_PASSWORD = ConvertFrom-SecureString -SecureString $bwPass -AsPlainText
    }

    if (Test-Path env:BW_CLIENTID) {
        $bwClientId = $env:BW_CLIENTID
    } else {
        $bwClientId = Read-Host "BitWarden Client ID"
        $env:BW_CLIENTID = $bwClientId
    }
    
    if (Test-Path env:BW_CLIENTSECRET) {
        $bwClientSecret = $env:BW_CLIENTSECRET
    } else {
        $bwClientSecret = Read-Host "BitWarden Client Secret"
        $env:BW_CLIENTSECRET = $bwClientSecret
    }
    
    Write-Host
    Write-Host "Logging into BitWarden..."
    bw login --apikey | Out-Null
    Write-Host
    Write-Host "Unlocking vault..."
    $unlockInfo = bw unlock --passwordenv BW_PASSWORD
    $env:BW_SESSION = $unlockInfo[4].Split('"')[1]
    Write-Host
    Write-Host "Vault unlocked." -ForegroundColor Green
}