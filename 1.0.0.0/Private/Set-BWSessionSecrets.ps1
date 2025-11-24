function Set-BWSessionSecrets {
    [CmdletBinding()]
    param (
        # Force
        [Parameter(Mandatory=$false)]
        [switch]
        $Force
    )

    try {
        if ((-not $script:BW_PASSWORD) -or $Force) {
            $script:BW_PASSWORD = Read-Host "Enter your Bitwarden master password" -AsSecureString
        }
    
        if ((-not $script:BW_CLIENTID) -or $Force) {
            $script:BW_CLIENTID = Read-Host "Enter your Bitwarden client ID" -AsSecureString
        }
    
        if ((-not $script:BW_CLIENTSECRET) -or $Force) {
            $script:BW_CLIENTSECRET = Read-Host "Enter your Bitwarden client secret" -AsSecureString
        }
    } catch {
        throw $_
    }
}
