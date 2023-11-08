<#
.SYNOPSIS
Creates a new user vault item and corresponding send.

.DESCRIPTION
Creates a new user vault item in the BMD organization and sets the item to be in
the Users/New and Users/Sent collections.

.PARAMETER FirstName
User's first name

.PARAMETER LastName
User's last name

.PARAMETER Username
User's username

.PARAMETER InitialPass
Initial password that was generated

.PARAMETER PersonalEmail
User's personal email address (optional)

.EXAMPLE
Add-BWUser -FirstName matty -LastName test -Username mattes1 -InitialPass 'blah' -PersonalEmail matt@bmail.com
#>
function Add-BWWifiUser {
    [CmdletBinding()]
    param(
        # User's first name
        [Parameter(Mandatory = $true)]
        [string]
        $FirstName,
        # User's last name
        [Parameter(Mandatory = $true)]
        [string]
        $LastName,
        # User's username
        [Parameter(Mandatory = $true)]
        [string]
        $Username,
        # Initial password that was generated
        [Parameter(Mandatory = $true)]
        [string]
        $InitialPass,
        # User's personal email address (optional)
        [Parameter(Mandatory = $false)]
        [string]
        $PersonalEmail
    )

    New-BWLoginUnlock

    if ($PSBoundParameters.ContainsKey('PersonalEmail')) {
        $nameOfVaultItem = "$FirstName $LastName $PersonalEmail"
    } else {
        $nameOfVaultItem = "$FirstName $LastName"
    }

    $vaultItem = @{
        organizationId = 'f97245e0-5ce6-4c36-ac40-ad0c004ae861'
        collectionIds  = @("0f3a5a11-66dc-4cf2-af8a-b00a0014d120", "d663b595-1c92-43cc-82d5-b00a0014c32e")
        folderId       = $null
        type           = 1
        name           = $nameOfVaultItem
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

    Write-Host "creating $FirstName $LastName"
    $createdItemOutput = Invoke-Command -ScriptBlock { $vaultItem | ConvertTo-Json | bw encode | bw create item }

    Write-Host "`nCreating Send for new user..."
    # WriteLog "[INFO] Adding new send to Sends"
    $getDate = Get-Date
    $date = ($getDate).AddDays(7).ToString("yyyy-MM-dd")
    $time = ($getDate).ToString("HH:mm:ss.fff")
    $deletionDate = "$($date)T$($time)Z" #needs to have T and Z for some reason

    $nameOfSend = "BMD Wifi-only Account Details for $nameOfVaultItem"

    $sendItem = @{
        object = "send"
        name = $nameOfSend
        notes = $null
        type = 0
        text = @{
            text = "Username: $Username`nPassword: $InitialPass"
            hidden = $false
        }
        file = $null
        maxAccessCount = 6
        deletionDate = $deletionDate
        expiratonDate = $deletionDate
        password = $null
        disabled = $false
        hideEmail = $true
    }

    # WriteLog "[INFO] Outputting send url and copied url to clipboard"
    $sendOutput = Invoke-Command -ScriptBlock { $sendItem | ConvertTo-Json | bw encode | bw send create }
    Write-Host "`nSend created."
    $accessUrl = $sendOutput | ConvertFrom-Json | Select-Object -expand accessUrl
    Write-Host "`nCopied this link to clipboard: $accessUrl"
    $accessUrl | clip
    Write-Host "Complete."
}