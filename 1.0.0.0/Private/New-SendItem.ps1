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
    
    Write-Host "`nCreating $SendName..."

    # WriteLog "[INFO] Outputting send url and copied url to clipboard"
    $sendOutput = Invoke-Command -ScriptBlock { $sendItem | ConvertTo-Json | bw encode | bw send create }
    $accessUrl = $sendOutput | ConvertFrom-Json | Select-Object -expand accessUrl
    $accessUrl | clip
    
    Write-Host "`nSend created."
    Write-Host "`nCopied this link to clipboard: $accessUrl"
    Write-Host "`nComplete."
}