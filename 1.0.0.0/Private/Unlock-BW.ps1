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
    try {
        Set-BWSessionSecrets
    
        Write-Host
        Write-Host "Logging into BitWarden..."
    
        $env:BW_CLIENTID = Get-BWSecret -Type "Id"
        $env:BW_CLIENTSECRET = Get-BWSecret -Type "Secret"
        bw login --apikey | Out-Null
        Remove-Item $env:BW_CLIENTID
        Remove-Item $env:BW_CLIENTSECRET
    
        Write-Host
        Write-Host "Unlocking vault..."
    
        $env:BW_PASSWORD = Get-BWSecret -Type "Password"
        $unlockInfo = bw unlock --passwordenv
        Remove-Item -Path $env:BW_PASSWORD
        $env:BW_SESSION = $unlockInfo[4].Split('"')[1]
    
        Write-Host
        Write-Host "Vault unlocked." -ForegroundColor Green
    } catch {
        throw $_
    }
}
