[CmdletBinding()]
[OutputType()]
param (
)

function New-BitWardenConnection {
    #let's make sure we have the bitwarden cli
    try {
        bw -v #output bw cli version
    } catch {
        throw "You must install the BitWarden CLI first. Exiting..."
    }

    #let's set up apikey environment variables
    if ($null -eq $env:BW_CLIENTID) {
        $env:BW_CLIENTID = Read-Host "Enter the API client ID" -MaskInput
    } else {
        Write-Verbose 'API client ID found in env var: $env:BW_CLIENTID'
    }

    if ($null -eq $env:BW_CLIENTSECRET) {
        $env:BW_CLIENTSECRET = Read-Host "Enter the API client secret" -MaskInput
    } else {
        Write-Verbose 'API client secret found in env var: $env:BW_CLIENTSECRET'
    }

    #master pw needs more security
    if ($null -eq $env:BW_PASSWORD) {
        $bwPass = Read-Host "Enter the Bitwarden master password" -AsSecureString
        $bwPassCred = New-Object `
            -TypeName System.Management.Automation.PSCredential `
            -ArgumentList "bwpass", $bwPass
        $env:BW_PASSWORD = $bwPassCred.Password | ConvertFrom-SecureString -AsPlainText
    } else {
        Write-Verbose 'BitWarden password found in env var: $env:BW_PASSWORD'
    }

    #now we can login to the bw cli
    Write-Verbose "Logging into the BitWarden CLI"
    $bwLogin = (bw login --apikey 2>&1) #capture the output in $bwLogin
    #[0] contains the output message, [1] contains the error code (if any).
    $loginMessage = $bwLogin[0].ToString()
    if ($bwLogin -like "You are already logged in*") {
        Write-Verbose "$loginMessage Continuing..."
    } elseif ($bwLogin -like "You are logged in*") {
        Write-Verbose $loginMessage
    } elseif ($bwLogin -like "Invalid API Key*") {
        # a problem occurred (most likely incorrect api client ID or secret)
        # clear env vars
        $env:BW_CLIENTID = $null
        $env:BW_CLIENTSECRET = $null #need to get api creds next time
        throw "Invalid API credentials supplied. Exiting..."
    } else {
        throw "An error occurred. Here is the error message: $loginMessage"
    }

    #to access the Vault Management API we have to 
    #run a local express server using the bw CLI
    #if server is not running, start it in the background as a job
    Write-Verbose "Starting local CLI server..."
    if (!(Get-Job -State Running | Where-Object { $_.Command.Contains("bw serve") })) {
        Start-Job -ScriptBlock { bw serve } | Out-Null
        Write-Verbose "Local BitWarden CLI server started."
    } else {
        Write-Verbose "Local CLI server already running. Continuing..."
    }
}

New-BitWardenConnection

$env:BW_BMD_ORG_ID = "f97245e0-5ce6-4c36-ac40-ad0c004ae861"
$env:BW_NEW_COLL_ID = "d663b595-1c92-43cc-82d5-b00a0014c32e"
$env:BW_SENT_COLL_ID = "0f3a5a11-66dc-4cf2-af8a-b00a0014d120"

$baseUrl = "http://localhost:8087"
$unlockEndpoint = "/unlock"
$syncEndpoint = "/sync"
$listItemsEndpoint = "/list/object/items"
$editItemEndpoint = "/object/item/"

$headers = @{
    "Accept"       = "application/json"
    "Content-Type" = "application/json"
}

#if we don't have the session key, we have to unlock our vault and 
#obtain the session key used to authorize any requests we make
if ($null -eq $env:BW_SESSION) {
    $payload = @{
        "password" = $env:BW_PASSWORD
    }

    $res = Invoke-RestMethod `
        -Uri "$baseUrl$unlockEndpoint" `
        -Method Post `
        -Headers $headers `
        -Body ($payload | ConvertTo-Json) `
        -ResponseHeadersVariable r `
        -StatusCodeVariable s

    if ($s -eq 200) {
        Write-Verbose "Vault unlocked."
        $seshKey = $res.data.raw
    } else {
        #clear env vars
        $env:BW_PASSWORD = $null
        throw "Failed to unlock vault. Exiting..."
    }

    $env:BW_SESSION = $seshKey
}

#sync the vault so the data is up to date
$params = @{
    Uri                     = "$($baseUrl)$($syncEndpoint)"
    Method                  = 'Post'
    Headers                 = $headers
    Body                    = $null
    ResponseHeadersVariable = $r
    StatusCodeVariable      = $s
}
$res = Invoke-RestMethod @params
if ($s -ne 200) {
    throw "Could not sync vault. Exiting..."
} else {
    Write-Host "`nVault synced.`n"
}

$queryParams = @{
    collectionId = "d663b595-1c92-43cc-82d5-b00a0014c32e"
}
$params = @{
    Method                  = 'Get'
    Uri                     = "$($baseUrl)$($listItemsEndpoint)"
    Headers                 = $headers
    Body                    = $queryParams
    ResponseHeadersVariable = $r
    StatusCodeVariable      = $s
}
$res = Invoke-RestMethod @params
if ($s -ne 200) {
    throw "Could not retrieve items in 'new' collection. Exiting..."
} else {
    Write-Host "`nItems in 'new' collection retrieved.`n"
}

#res.data.data now contains an array of items currently in the new collection
#now we need to add the sent collection id and remove the new collection id
#from each item
$bwItems = $res.data.data
foreach ($bwItem in $bwItems) {
    $bwItem.login | Add-Member -MemberType NoteProperty -Name "uris" -Value $null -Force
    $newItem = @{
        object         = $bwItem.object
        id             = $bwItem.id
        organizationId = $bwItem.organizationId
        collectionIds  = @('0f3a5a11-66dc-4cf2-af8a-b00a0014d120')
        folderId       = $null
        type           = 1
        name           = $bwItem.name
        notes          = $null
        favorite       = $false
        fields         = $null
        login          = $bwItem.login
        reprompt       = 0
    }
    $params = @{
        Method                  = 'Put'
        Uri                     = "$($baseUrl)$($editItemEndpoint)$($bwItem.id)"
        Headers                 = $headers
        Body                    = ($newItem | ConvertTo-Json)
        ResponseHeadersVariable = $r
        StatusCodeVariable      = $s
    }
    $res = Invoke-RestMethod @params
    if ($s -ne 200) {
        throw "Item edit failed. Exiting..."
    } else {
        Write-Host "success: $($res.success)"
        Write-Host $res.data.collectionIds
        Write-Host "`nItem '$($bwItem.name)' updated successfully.`n"
    }
}