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

    New-VaultItem -VaultItemName $nameOfVaultItem -Username $Username -InitialPass $InitialPass

    New-SendItem -SendName $nameOfVaultItem -SendContents "Username: $Username`nPassword: $InitialPass"
}