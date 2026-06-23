$ErrorActionPreference = "Continue"

$results = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param([string]$Name, [string]$Status, [string]$Detail)
    $results.Add([pscustomobject]@{ Name = $Name; Status = $Status; Detail = $Detail }) | Out-Null
}

function Get-FileReport {
    param([string]$Path)
    $exists = Test-Path -LiteralPath $Path -PathType Leaf
    if (-not $exists) {
        return [pscustomobject]@{ Path = $Path; Exists = $false; Size = $null; Sha256 = $null; SignatureStatus = $null }
    }

    $item = Get-Item -LiteralPath $Path
    $hash = Get-FileHash -LiteralPath $Path -Algorithm SHA256
    $sig = Get-AuthenticodeSignature -LiteralPath $Path
    return [pscustomobject]@{
        Path = $Path
        Exists = $true
        Size = $item.Length
        Sha256 = $hash.Hash
        SignatureStatus = $sig.Status.ToString()
    }
}

Write-Host "# Codex Windows Sandbox Diagnostic"
Write-Host "This script is read-only and does not require administrator privileges."
Write-Host ""

Write-Host "## System"
Write-Host "Windows: $([System.Environment]::OSVersion.VersionString)"
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
Write-Host "User: $env:USERNAME"
Write-Host "Computer: $env:COMPUTERNAME"
Write-Host "PWD: $(Get-Location)"
Write-Host ""
Add-Check "PowerShell" "PASS" "PowerShell is running."

Write-Host "## OpenAI Codex AppX"
try {
    $packages = Get-AppxPackage -Name "OpenAI.Codex" -ErrorAction SilentlyContinue
    if ($packages) {
        $packages | Select-Object Name, PackageFullName, Version, InstallLocation | Format-List
        Add-Check "OpenAI.Codex AppX" "PASS" "Package found."
    } else {
        Write-Host "OpenAI.Codex package not found by Get-AppxPackage."
        Add-Check "OpenAI.Codex AppX" "WARN" "Package not found by Get-AppxPackage."
    }
} catch {
    Write-Host "Get-AppxPackage failed: $($_.Exception.Message)"
    Add-Check "OpenAI.Codex AppX" "WARN" "Get-AppxPackage failed."
}
Write-Host ""

Write-Host "## codex-windows-sandbox-setup.exe search"
$searchRoots = @(
    "$env:LOCALAPPDATA",
    "$env:APPDATA",
    "$env:USERPROFILE\.codex",
    "$env:ProgramFiles\WindowsApps"
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

$found = New-Object System.Collections.Generic.List[string]
foreach ($root in $searchRoots) {
    Write-Host "Searching: $root"
    try {
        Get-ChildItem -LiteralPath $root -Filter "codex-windows-sandbox-setup.exe" -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $found.Add($_.FullName) | Out-Null
        }
    } catch {
        Write-Host "WARN: Could not fully search $root : $($_.Exception.Message)"
    }
}

if ($found.Count -eq 0) {
    Write-Host "No codex-windows-sandbox-setup.exe found in common paths."
    Add-Check "sandbox helper file" "WARN" "No helper found in common paths."
} else {
    foreach ($path in $found | Select-Object -Unique) {
        Get-FileReport -Path $path | Format-List
    }
    Add-Check "sandbox helper file" "PASS" "$($found.Count) candidate path(s) found."
}
Write-Host ""

Write-Host "## Sandbox log keyword scan"
$keywords = @(
    "找不到指定的模块",
    "The specified module could not be found",
    "module not found",
    "apply_patch",
    "codex-windows-sandbox-setup",
    "failed",
    "panic",
    "exception"
)

$logRoot = Join-Path $env:USERPROFILE ".codex\.sandbox"
if (-not (Test-Path -LiteralPath $logRoot -PathType Container)) {
    Write-Host "Sandbox log directory not found: $logRoot"
    Add-Check "sandbox logs" "WARN" "No ~/.codex/.sandbox directory found."
} else {
    $logs = Get-ChildItem -LiteralPath $logRoot -File -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 20
    if (-not $logs) {
        Write-Host "No log files found under: $logRoot"
        Add-Check "sandbox logs" "WARN" "Log directory exists but no files were found."
    } else {
        $hitCount = 0
        foreach ($log in $logs) {
            try {
                $matches = Select-String -LiteralPath $log.FullName -Pattern $keywords -SimpleMatch -Encoding UTF8 -ErrorAction SilentlyContinue
                if ($matches) {
                    $hitCount += $matches.Count
                    Write-Host "Log: $($log.FullName)"
                    $matches | Select-Object -First 20 | ForEach-Object {
                        Write-Host "  $($_.LineNumber): $($_.Line)"
                    }
                }
            } catch {
                Write-Host "WARN: Could not scan $($log.FullName): $($_.Exception.Message)"
            }
        }
        if ($hitCount -gt 0) {
            Add-Check "sandbox log keywords" "WARN" "$hitCount keyword hit(s) found."
        } else {
            Add-Check "sandbox log keywords" "PASS" "No selected failure keywords found in recent logs."
        }
    }
}
Write-Host ""

Write-Host "## Summary"
$results | Format-Table -AutoSize

if ($results.Status -contains "FAIL") {
    exit 2
}
if ($results.Status -contains "WARN") {
    exit 1
}
exit 0