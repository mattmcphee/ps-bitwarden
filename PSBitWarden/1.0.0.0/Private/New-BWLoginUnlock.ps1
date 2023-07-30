<#
.SYNOPSIS
Helper function that sets up api key and password env vars and then logs in
unlocks vault and gets the session key and stores it in an env var

.DESCRIPTION
Helper function that sets up api key and password env vars and then logs in
unlocks vault and gets the session key and stores it in an env var

.EXAMPLE
New-BWLoginUnlock
#>
function New-BWLoginUnlock {
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
    
    if (Test-Path env:BW_PASSWORD) {
        $bwPass = $env:BW_PASSWORD
    } else {
        $bwPass = Read-Host -AsSecureString "BitWarden Master Password"
        $env:BW_PASSWORD = ConvertFrom-SecureString -SecureString $bwPass -AsPlainText
    }
    
    Write-Host 'logging into bw cli...'
    $loginInfo = Invoke-Command -ScriptBlock { bw login --apikey }
    Write-Host 'logged in.'
    
    Write-Host 'unlocking vault...'
    $unlockInfo = Invoke-Command -ScriptBlock { bw unlock --passwordenv BW_PASSWORD }
    $env:BW_SESSION = $unlockInfo[4].Split('"')[1]
    Write-Host 'unlocked. session key extracted.'
}