function Add-BWBitLocker {
    [CmdletBinding()]
    param (
        # User's computer name
        [Parameter(Mandatory = $true)]
        [string]
        $ComputerName
    )

    New-BWLoginUnlock

    Write-Host "Getting recovery code..."

    $getDate = Get-Date
    $getDate = Get-Date
    $date = ($getDate).AddDays(7).ToString("yyyy-MM-dd")
    $time = ($getDate).ToString("HH:mm:ss.fff")
    $deletionDate = "$($date)T$($time)Z" #needs to have T and Z for some reason

    $computer = Get-ADComputer $ComputerName
    $BitlockerObject = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $computer -Properties 'msFVE-RecoveryPassword'
    $recoveryCodeObject = $BitlockerObject | Sort-Object Name -Descending | Select-Object -Last 1 | Select-Object 'msfve-recoverypassword'
    $recoveryCode = $recoveryCodeObject.'msfve-recoverypassword'

    $sendItem = @{
        object = "send"
        name = "BitLocker Recovery Code for $ComputerName"
        notes = $null
        type = 0
        text = @{
            text = "Bitlocker Recovery Code:`n$recoveryCode"
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

    Write-Host "`nCreating Send for machine's BitLocker Recovery code..."

    # WriteLog "[INFO] Outputting send url and copied url to clipboard"
    $sendOutput = Invoke-Command -ScriptBlock { $sendItem | ConvertTo-Json | bw encode | bw send create }
    Write-Host "`nSend created."
    $accessUrl = $sendOutput | ConvertFrom-Json | Select-Object -expand accessUrl
    Write-Host "`nCopied this link to clipboard: $accessUrl"
    $accessUrl | clip
    Write-Host "Complete."
}