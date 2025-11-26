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
        Write-Host "Logging into Bitwarden..."
    
        $env:BW_CLIENTID = Get-BWSecret -Type "Id"
        $env:BW_CLIENTSECRET = Get-BWSecret -Type "Secret"
        Invoke-Bw -Command "login --apikey" -IgnoreExitCodes | Out-Null
    
        Write-Host
        Write-Host "Unlocking vault..."
    
        $env:BW_PASSWORD = Get-BWSecret -Type "Password"
        $unlockInfo = Invoke-Bw -Command "unlock --passwordenv BW_PASSWORD"
        $env:BW_SESSION = ($unlockInfo | Select-String -Pattern 'BW_SESSION="(.*)"').matches.groups[1].value
    
        Write-Host
        Write-Host "Vault unlocked." -ForegroundColor Green
    } catch {
        throw $_
    }
}
