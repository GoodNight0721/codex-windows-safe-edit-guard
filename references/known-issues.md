# Known Issues

This project targets a narrow failure pattern seen by some Codex Desktop users on Windows.

## Observed pattern

- Ordinary shell commands, PowerShell commands, and Python scripts may work normally.
- `apply_patch` or a Codex file edit helper may trigger a `codex-windows-sandbox-setup.exe` popup.
- A patch may appear to succeed while the popup still appears.
- A remote or mobile client may keep showing a running state while the desktop needs attention.

## Project choice

This repository avoids the high-risk path instead of trying to repair Codex Desktop. The guardrails ask agents to use explicit PowerShell or Python UTF-8 writes, report Git state after edits, and avoid protected installation paths.

## Not a product fix

This project is not an official OpenAI bug fix. It is a local workflow workaround that can be added to or removed from a project.