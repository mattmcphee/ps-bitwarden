<#
.SYNOPSIS
Creates a new user vault item.

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
New-BwUser -FirstName matty -LastName test -Username mattes1 -InitialPass 'blah' -PersonalEmail matt@bmail.com
#>
function New-BWUser {
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

    $fullName = "$FirstName $LastName $PersonalEmail"

    $vaultItem = @{
        organizationId = 'f97245e0-5ce6-4c36-ac40-ad0c004ae861'
        collectionIds  = @("0f3a5a11-66dc-4cf2-af8a-b00a0014d120","d663b595-1c92-43cc-82d5-b00a0014c32e")
        folderId       = $null
        type           = 1
        name           = $fullName
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
}