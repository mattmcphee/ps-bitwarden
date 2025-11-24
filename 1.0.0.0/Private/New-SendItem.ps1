function New-SendItem {
    [CmdletBinding()]
    param (
        # Send name
        [Parameter(Mandatory = $true)]
        [string]
        $SendName,
        # Send contents
        [Parameter(Mandatory = $true)]
        [string]
        $SendContents
    )

    try {
        $deletionDate = Get-DeletionDate
    
        $sendItem = @{
            object = "send"
            name = $SendName
            notes = $null
            type = 0
            text = @{
                text = $SendContents
                hidden = $false
            }
            file = $null
            maxAccessCount = 8
            deletionDate = $deletionDate
            expiratonDate = $deletionDate
            password = $null
            disabled = $false
            hideEmail = $true
        }
        
        Write-Host
        Write-Host "Creating send item: $SendName..."
    
        $sendOutput = $sendItem | ConvertTo-Json | bw encode | bw send create
        $accessUrl = $sendOutput | ConvertFrom-Json | Select-Object -expand accessUrl
        $accessUrl | clip
        
        Write-Host
        Write-Host "Send created." -ForegroundColor Green
        Write-Host
        Write-Host "Copied this link to clipboard: $accessUrl" -ForegroundColor Cyan
        Write-Host
    } catch {
        throw $_
    }
}
