$ErrorActionPreference = "Stop"

$checks = New-Object System.Collections.Generic.List[object]
function Add-Check {
    param([string]$Name, [string]$Status, [string]$Detail)
    $checks.Add([pscustomobject]@{ Name = $Name; Status = $Status; Detail = $Detail }) | Out-Null
}

$repoRoot = (Get-Location).Path
$tmpDir = Join-Path $repoRoot "__codex_safe_edit_tmp"
$textPath = Join-Path $tmpDir "utf8-chinese-test.txt"
$pythonPath = Join-Path $tmpDir "hello_utf8.py"

try {
    if (Test-Path -LiteralPath $tmpDir) {
        Remove-Item -LiteralPath $tmpDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tmpDir | Out-Null
    Add-Check "create temp dir" "PASS" $tmpDir

    $text = "中文 UTF-8 canary: Codex 安全写入测试"
    [System.IO.File]::WriteAllText($textPath, $text, [System.Text.UTF8Encoding]::new($false))
    $readBack = [System.IO.File]::ReadAllText($textPath, [System.Text.UTF8Encoding]::new($false))
    if ($readBack.Contains("???")) {
        Add-Check "utf8 readback" "FAIL" "Found ??? in Chinese test file."
    } elseif ($readBack -eq $text) {
        Add-Check "utf8 readback" "PASS" "Chinese text round-tripped."
    } else {
        Add-Check "utf8 readback" "FAIL" "Readback did not match written text."
    }

    $py = @"
# -*- coding: utf-8 -*-
print("中文 Python canary: PASS")
"@
    [System.IO.File]::WriteAllText($pythonPath, $py, [System.Text.UTF8Encoding]::new($false))
    $oldPythonIoEncoding = $env:PYTHONIOENCODING
    $env:PYTHONIOENCODING = "utf-8"
    try {
        $oldConsoleEncoding = [Console]::OutputEncoding
        $oldPowerShellOutputEncoding = $OutputEncoding
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        try {
            $pythonOutput = & python $pythonPath 2>&1
            if ($LASTEXITCODE -eq 0 -and ($pythonOutput -join "`n").Contains("PASS")) {
                Add-Check "python execution" "PASS" "Python printed Chinese canary text: PASS"
            } else {
                Add-Check "python execution" "FAIL" ($pythonOutput -join " ")
            }
        } finally {
            [Console]::OutputEncoding = $oldConsoleEncoding
            $OutputEncoding = $oldPowerShellOutputEncoding
        }
    } finally {
        $env:PYTHONIOENCODING = $oldPythonIoEncoding
    }
} catch {
    Add-Check "canary exception" "FAIL" $_.Exception.Message
} finally {
    try {
        if (Test-Path -LiteralPath $tmpDir) {
            Remove-Item -LiteralPath $tmpDir -Recurse -Force
            Add-Check "cleanup temp dir" "PASS" "Removed $tmpDir"
        }
    } catch {
        Add-Check "cleanup temp dir" "FAIL" $_.Exception.Message
    }
}

Write-Host "# Codex safe edit canary"
$checks | Format-Table -AutoSize

Write-Host ""
Write-Host "# git status --short"
git status --short

if ($checks.Status -contains "FAIL") {
    exit 1
}
exit 0