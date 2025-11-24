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
    
        bw lock
        Remove-Item $env:BW_SESSION
        
        Write-Host
        Write-Host
    } catch {
        throw $_
    }
}