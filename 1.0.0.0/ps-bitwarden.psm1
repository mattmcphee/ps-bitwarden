$publicPath = Join-Path $PSScriptRoot 'Public'
if (Test-Path $publicPath) {
    Get-ChildItem $publicPath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

$privatePath = Join-Path $PSScriptRoot 'Private'
if (Test-Path $privatePath) {
    Get-ChildItem $privatePath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

# set secret vars
$script:BW_PASSWORD = $null
$script:BW_CLIENTID = $null
$script:BW_CLIENTSECRET = $null
