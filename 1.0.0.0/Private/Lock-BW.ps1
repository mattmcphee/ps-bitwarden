<#
.SYNOPSIS
Helper function that locks the vault and logs out once an operation has
completed.

.DESCRIPTION
Helper function that locks the vault and logs out once an operation has 
completed.

.EXAMPLE
Lock-BW
#>
function Lock-BW {
    try {
        Write-Host "Locking vault..."
        Write-Host
    
        Invoke-Bw -Command "lock"
        $env:BW_PASSWORD = $null
        $env:BW_CLIENTID = $null
        $env:BW_CLIENTSECRET = $null
        $env:BW_SESSION = $null
        
        Write-Host
        Write-Host
    } catch {
        throw $_
    }
}