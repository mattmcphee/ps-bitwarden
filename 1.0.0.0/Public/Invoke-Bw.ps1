function Invoke-Bw {
    [CmdletBinding()]
    param (
        # Command
        [Parameter(Mandatory = $true)]
        [string]
        $Command,
        # IgnoreExitCodes
        [Parameter(Mandatory = $false)]
        [switch]
        $IgnoreExitCodes
    )

    $bwInstalled = Get-Command -Name "bw" -ErrorAction SilentlyContinue
    if (-not $bwInstalled) {
        Write-Host "bitwarden-cli not found! You need to install it (chocolatey is best)!" -ForegroundColor Red
        Write-Host "Install chocolatey by running: irm https://community.chocolatey.org/install.ps1 | iex"
        Write-Host "Then run: choco install bitwarden-cli -y"
        throw "bitwarden-cli not found!"
    }
    
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "bw"
    $processInfo.Arguments = $Command
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.UseShellExecute = $false

    $p = [System.Diagnostics.Process]::Start($processInfo)
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()

    if ($p.ExitCode -ne 0 -and (-not $IgnoreExitCodes)) {
        throw "bw $Command failed! (exit $($p.ExitCode)): $stderr"
    }

    if ($stdout.Trim().StartsWith('{') -or $stdout.Trim().StartsWith('[')) {
        return $stdout | ConvertFrom-Json
    }

    return $stdout
}
