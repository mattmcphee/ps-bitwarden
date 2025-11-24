function Add-BWBitLocker {
    [CmdletBinding()]
    param (
        # User's computer name
        [Parameter(Mandatory = $true)]
        [string]
        $ComputerName
    )
    try {
        Unlock-BW

        Write-Host "Getting recovery code..."

        $computer = Get-ADComputer $ComputerName
        $BitlockerObject = Get-ADObject -Filter { objectclass -eq 'msFVE-RecoveryInformation' } -SearchBase $computer -Properties 'msFVE-RecoveryPassword'
        $recoveryCodeObject = $BitlockerObject | Sort-Object -Property DistinguishedName | Select-Object -Last 1 | Select-Object 'msfve-recoverypassword'
        $recoveryCode = $recoveryCodeObject.'msfve-recoverypassword'

        New-SendItem -SendName "BitLocker Recovery Code for $ComputerName" -SendContents "Bitlocker Recovery Code: $recoveryCode"

        Lock-BW
    } catch {
        throw $_
    }
}
