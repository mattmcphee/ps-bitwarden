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

    try {
        $orgId = 'f97245e0-5ce6-4c36-ac40-ad0c004ae861'
        $collectionIds = @(
            "0f3a5a11-66dc-4cf2-af8a-b00a0014d120",
            "d663b595-1c92-43cc-82d5-b00a0014c32e"
        )
        
        $vaultItem = @{
            passwordHistory = @()
            revisionDate    = $null
            creationDate    = $null
            deletedDate     = $null
            archivedDate    = $null
            organizationId  = $orgId
            collectionIds   = $collectionIds
            folderId        = $null
            type            = 1
            name            = $VaultItemName
            notes           = $null
            favorite        = $false
            fields          = @()
            login           = @{
                uris             = @()
                username         = $Username
                password         = $InitialPass
                totp             = $null
                fido2Credentials = @()
            }
            securenote      = $null
            card            = $null
            identity        = $null
            sshKey          = $null
            reprompt        = 0
        }
    
        Write-Host
        Write-Host "Creating vault item: $VaultItemName..."
        Write-Host
    
        $vaultItem | ConvertTo-Json | bw encode | bw create item 2> $null
        
        if ($LASTEXITCODE -ne 0) {
            throw "Could not create vault item. The vault needs to be unlocked - run bw status to verify. Run Clear-BWAppData and start again if issue persists."
        }
        
        Write-Host "Vault item created." -ForegroundColor Green
    } catch {
        throw $_
    }
}