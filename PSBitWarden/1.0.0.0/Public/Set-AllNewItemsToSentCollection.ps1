<#
.SYNOPSIS
Sets all vault items in the Users/New collection to only be in the Users/Sent collection.

.DESCRIPTION
When user vault items are created, they are put into two collections: Users/New and Users/Sent. 
This function will remove the vault items in Users/New and only put them in Users/Sent.

.EXAMPLE
Set-AllNewItemsToSentCollection
#>
function Set-AllNewItemsToSentCollection {
    New-BWLoginUnlock

    $sentCollId = '"0f3a5a11-66dc-4cf2-af8a-b00a0014d120"'
    $newCollId = 'd663b595-1c92-43cc-82d5-b00a0014c32e'

    Write-Host 'getting list of items in users/new...'
    $newItems = Invoke-Command { bw list items --collectionid $newCollId } | ConvertFrom-Json
    
    Write-Host 'items retrieved.'

    Write-Host "setting each item's collection to users/sent ONLY"
    foreach ($item in $newItems) {
        Invoke-Command -ScriptBlock { "[$sentCollId]" | bw encode | bw edit item-collections $item.id } | Out-Null
        Write-Host "$($item.name) done."
    }
    Write-Host 'all items in users/new removed.'
}