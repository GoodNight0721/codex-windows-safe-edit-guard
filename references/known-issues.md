# Known Issues

This project targets a narrow failure pattern seen by some Codex Desktop users on Windows.

## Search keywords

Use these keywords when looking for related reports or local logs:

- `codex-windows-sandbox-setup.exe`
- `找不到指定的模块`
- `The specified module could not be found`
- `apply_patch`
- `WindowsApps`
- `OpenAI.Codex_26.616`

## Observed pattern

- Ordinary shell commands, PowerShell commands, Python scripts, and Node commands may work normally.
- `apply_patch` or a Codex file edit helper may trigger a `codex-windows-sandbox-setup.exe` popup.
- The popup may reference a path under `C:\Program Files\WindowsApps\OpenAI.Codex_...\app\resources\`.
- A patch may appear to succeed while the popup still appears.
- A phone, browser, or remote client may keep showing a running state while the Windows desktop is waiting on the popup.

## Project choice

This repository avoids the high-risk path instead of trying to repair Codex Desktop. The guardrails ask agents to use explicit PowerShell or Python UTF-8 writes, report Git state after edits, and avoid protected installation paths.

## Not a product fix

This project is not an official OpenAI bug fix. It is a local workflow workaround that can be added to or removed from a project.

It does not modify WindowsApps, repackage MSIX, edit `app.asar`, replace OpenAI binaries, or disable the sandbox.