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
    try {
        Unlock-BW

        Write-Host
        Write-Host "Running bw sync..."
        Invoke-Bw -Command "sync"
        
        $sentCollName = "001-H07/Users/Sent"
        $sentCollId = "0f3a5a11-66dc-4cf2-af8a-b00a0014d120"
        $newCollName = "001-H07/Users/New"
        $newCollId = "d663b595-1c92-43cc-82d5-b00a0014c32e"
        $orgId = "f97245e0-5ce6-4c36-ac40-ad0c004ae861"
    
        Write-Host
        Write-Host "Getting a list of items in collection: $newCollName..."
        $newItems = Invoke-Bw -Command "list items --collectionid $newCollId"
        Write-Host
        Write-Host "Removing each item from $newCollName and adding it to $sentCollName..."
        Write-Host
    
        foreach ($item in $newItems) {
            $itemId = $item.id
            $itemName = $item.name
            $sentCollIdString = '["' + $sentCollId + '"]'
            $sentCollIdString | bw encode | bw edit item-collections $itemId --organizationid $orgId *> $null

            if ($LASTEXITCODE -ne 0) {
                throw "Could not remove $item from collection: $newCollName"
            }

            Write-Host "'$($itemName)' processed."
            Write-Host
        }
    
        Write-Host 'All items processed.'
        Write-Host
    
        Lock-BW
    } catch {
        throw $_
    }
}
