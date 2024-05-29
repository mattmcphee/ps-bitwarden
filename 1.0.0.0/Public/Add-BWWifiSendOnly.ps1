<#
.SYNOPSIS
Creates a send only.

.DESCRIPTION
Creates a new send with user's login details without creating a corresponding vault item (probably because it already exists).

.PARAMETER Username
User's username

.PARAMETER InitialPass
Initial password that was generated

.PARAMETER PersonalEmail
User's personal email address (optional)

.EXAMPLE
Add-BWUser -FirstName matty -LastName test -Username mattes1 -InitialPass 'blah' -PersonalEmail matt@bmail.com
#>
function Add-BWWifiSendOnly {
    [CmdletBinding()]
    param(
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

    Unlock-BW

    if ($PSBoundParameters.ContainsKey('PersonalEmail')) {
        $nameOfSend = "$Username $PersonalEmail"
    } else {
        $nameOfSend = $Username
    }

    if (!($PSBoundParameters.ContainsKey('InitialPass'))) {
        $sentCollId = '0f3a5a11-66dc-4cf2-af8a-b00a0014d120'
        $allVaultItems = Invoke-Command { bw list items --collectionid $sentCollId } | ConvertFrom-Json

        $allVaultItems | ForEach-Object {
            if ($_.login.username -eq $Username) {
                $InitialPass = $_.login.password
            }
            break
        }
    }
    
    New-SendItem -SendName $nameOfSend -SendContents "Username: $Username`nPassword: $InitialPass"
}