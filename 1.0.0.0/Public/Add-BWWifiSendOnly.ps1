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

    New-BWLoginUnlock

    if ($PSBoundParameters.ContainsKey('PersonalEmail')) {
        $nameOfSend = "$Username $PersonalEmail"
    } else {
        $nameOfSend = $Username
    }

    Write-Host "`nCreating Send for new user..."
    # WriteLog "[INFO] Adding new send to Sends"
    $getDate = Get-Date
    $date = ($getDate).AddDays(7).ToString("yyyy-MM-dd")
    $time = ($getDate).ToString("HH:mm:ss.fff")
    $deletionDate = "$($date)T$($time)Z" #needs to have T and Z for some reason

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