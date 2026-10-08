function Get-BWSecret {
    [CmdletBinding()]
    param (
        # Type
        [Parameter(Mandatory=$true)]
        [ValidateSet("Password", "Secret", "Id")]
        [string]
        $Type
    )
    try {
        switch ($Type) {
            "Password" {
                return (New-Object System.Net.NetworkCredential("", $script:BW_PASSWORD)).Password
            }
            "Secret" {
                return (New-Object System.Net.NetworkCredential("", $script:BW_CLIENTSECRET)).Password
            }
            "Id" {
                return (New-Object System.Net.NetworkCredential("", $script:BW_CLIENTID)).Password
            }
        }
    } catch {
        throw $_
    }
}
