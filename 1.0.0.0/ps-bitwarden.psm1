$publicPath = Join-Path $PSScriptRoot 'Public'
$privatePath = Join-Path $PSScriptRoot 'Private'
# Get all the ps1 files in the Public folder
$Functions = Get-ChildItem -Path $publicPath, $privatePath -Filter '*.ps1'

# Loop through each ps1 file
foreach ($import in $Functions) {
    try {
        Write-Verbose "dot-sourcing file '$($import.fullname)'"
        # Execute each ps1 file to load the function into memory
        . $import.fullname
    } catch {
        Write-Error -Message "Failed to import function $($import.name)"
    }
}

# set secret vars
$script:BW_PASSWORD = $null
$script:BW_CLIENTID = $null
$script:BW_CLIENTSECRET = $null
