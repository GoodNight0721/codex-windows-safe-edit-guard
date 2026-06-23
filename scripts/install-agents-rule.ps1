param(
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

function Write-Result {
    param([string]$Level, [string]$Message)
    Write-Host "[$Level] $Message"
}

try {
    $resolvedRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
} catch {
    Write-Result "FAIL" "ProjectRoot does not exist: $ProjectRoot"
    exit 1
}

if (-not (Test-Path -LiteralPath $resolvedRoot -PathType Container)) {
    Write-Result "FAIL" "ProjectRoot is not a directory: $resolvedRoot"
    exit 1
}

$agentsPath = Join-Path $resolvedRoot "AGENTS.md"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$guardStart = "<!-- codex-windows-safe-edit-guard:start -->"
$guardEnd = "<!-- codex-windows-safe-edit-guard:end -->"

$guardBlock = @"
$guardStart

# Codex Windows Safe Edit Guard

This project uses project-level guardrails for Codex Desktop on Windows.

- Do not use apply_patch.
- Do not use Codex built-in file edit helper.
- Before editing, list files and plan, then wait for confirmation.
- Write files only through PowerShell or Python with explicit UTF-8.
- For non-ASCII content, read back and verify no ???.
- After editing, run git status --short and git diff --name-only.
- Do not commit or push unless user explicitly asks.
- Do not delete untracked files unless user confirms.
- Do not modify .codex / WindowsApps / Codex install / Cursor extension / AppData Codex binaries.

$guardEnd
"@

if (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
    $existing = Get-Content -LiteralPath $agentsPath -Raw -Encoding UTF8
    if ($existing.Contains($guardStart)) {
        Write-Result "PASS" "AGENTS.md already contains the codex-windows-safe-edit-guard block. No changes made."
        Write-Result "INFO" "Path: $agentsPath"
        exit 0
    }

    $backupPath = "$agentsPath.bak_$timestamp"
    Copy-Item -LiteralPath $agentsPath -Destination $backupPath -Force
    $newContent = $existing.TrimEnd() + "`r`n`r`n" + $guardBlock.TrimEnd() + "`r`n"
    [System.IO.File]::WriteAllText($agentsPath, $newContent, [System.Text.UTF8Encoding]::new($false))
    Write-Result "PASS" "Appended safe-edit guard block to existing AGENTS.md."
    Write-Result "INFO" "Backup: $backupPath"
    Write-Result "INFO" "Path: $agentsPath"
    exit 0
}

$newFileContent = $guardBlock.TrimEnd() + "`r`n"
[System.IO.File]::WriteAllText($agentsPath, $newFileContent, [System.Text.UTF8Encoding]::new($false))
Write-Result "PASS" "Created AGENTS.md with safe-edit guard block."
Write-Result "INFO" "Path: $agentsPath"
exit 0