function New-VaultItem {
    [CmdletBinding()]
    param (
        # Name of vault item
        [Parameter(Mandatory = $true)]
        [string]
        $VaultItemName,
        # Username of vault item
        [Parameter(Mandatory = $true)]
        [string]
        $Username,
        # Initial Password
        [Parameter(Mandatory = $true)]
        [string]
        $InitialPass
    )
    
    $vaultItem = @{
        organizationId = 'f97245e0-5ce6-4c36-ac40-ad0c004ae861'
        collectionIds  = @("0f3a5a11-66dc-4cf2-af8a-b00a0014d120", "d663b595-1c92-43cc-82d5-b00a0014c32e")
        folderId       = $null
        type           = 1
        name           = $VaultItemName
        notes          = $null
        favorite       = $false
        fields         = $null
        login          = @{
            uris     = $null
            username = $Username
            password = $InitialPass
            totp     = $null
        }
        securenote     = $null
        card           = $null
        identity       = $null
        reprompt       = 0
    }

    Write-Host "`ncreating vault item..."
    Invoke-Command -ScriptBlock { $vaultItem | ConvertTo-Json | bw encode | bw create item }
}