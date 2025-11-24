function Add-BWTempAccessPass {
    [CmdletBinding()]
    param (
        # Username
        [Parameter(Mandatory)]
        [string]
        $Username,
        # Temporary Access Pass
        [Parameter(Mandatory)]
        [string]
        $TempAccessPass
    )
    try {
        Unlock-BW
    
        New-SendItem -SendName $Username -SendContents "Temporary Access Pass: $TempAccessPass"
    
        Lock-BW
    } catch {
        throw $_
    }
}
