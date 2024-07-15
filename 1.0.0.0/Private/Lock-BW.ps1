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
    Write-Host "Locking vault..."
    bw lock
    Write-Host "Logging out..."
    bw logout
}