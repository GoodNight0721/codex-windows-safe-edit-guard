---
name: codex-windows-safe-edit-guard
description: project-level safe edit guard for Codex Windows apply_patch / sandbox helper failures
---

# codex-windows-safe-edit-guard

Use this skill when working in a Windows Codex Desktop project where `apply_patch`, a built-in file edit helper, or `codex-windows-sandbox-setup.exe` failures may interrupt normal editing.

This skill is a project-level workaround / guardrail. It is not an official OpenAI fix, not a root fix, and not a guarantee. It does not repair Codex Desktop, patch WindowsApps, repackage MSIX files, edit `app.asar`, replace OpenAI binaries, or disable the sandbox.

## When to use

Use this skill when:

- The user reports `codex-windows-sandbox-setup.exe` popups.
- The dialog mentions `The specified module could not be found` or `找不到指定的模块`.
- Normal PowerShell or Python commands work, but Codex file editing fails or hangs.
- A phone or web client keeps showing `running`, while the Windows desktop is waiting on a dialog.
- The project contains Chinese or other non-ASCII text and needs explicit UTF-8 handling.
- The user wants a low-risk project-level workaround instead of modifying Codex installation files.

## Rules

- Do not use `apply_patch`.
- Do not use Codex built-in file edit helpers.
- Before editing, explain the plan, list files to be modified, and wait for confirmation.
- Create or modify files only with PowerShell or Python scripts using explicit UTF-8 encoding.
- For non-ASCII content, read back the file and verify text did not become `???`.
- After editing, run `git status --short` and `git diff --name-only`.
- Do not commit or push unless the user explicitly asks.
- Do not delete untracked files unless the user confirms.
- Do not modify `.codex`, `WindowsApps`, Codex Desktop installation files, Cursor extension files, or AppData Codex binaries.

## Install AGENTS.md rules with PowerShell

Use `scripts/install-agents-rule.ps1` to add the guard block to a target project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-agents-rule.ps1 -ProjectRoot D:\path\to\project
```

The installer backs up an existing `AGENTS.md`, avoids duplicate guard blocks, and writes UTF-8.

## Direct prompt installation workflow

If the user does not want to run scripts manually, they can ask the agent to install the guard block into the current project's `AGENTS.md`. The agent must still obey the safe-edit rules while doing this.

Suggested prompt:

```text
This Windows Codex Desktop project may trigger a codex-windows-sandbox-setup.exe "The specified module could not be found" error when using apply_patch or the built-in file edit helper. Do not use apply_patch. Install the codex-windows-safe-edit-guard AGENTS.md rules into the current project. Write files only through PowerShell or Python with explicit UTF-8. Before editing, list the plan and files and wait for my confirmation. After editing, run git status --short and git diff --name-only, and verify non-ASCII text did not become ???. Do not commit or push.
```

Important: direct prompt installation is not permission to use `apply_patch`. The agent should write `AGENTS.md` with PowerShell or Python and explicit UTF-8.

## Run the canary

Run the canary before relying on the workflow:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\codex-sandbox-canary.ps1
```

The canary creates a temporary directory in the current repository, writes Chinese UTF-8 text, runs a small Python script, removes the temporary directory, and reports `git status --short`.

## Use safe UTF-8 helpers

Write a whole file from a content file:

```powershell
python .\scripts\safe_write_utf8.py --path .\target.md --content-file .\draft.txt
```

Replace text inside a file:

```powershell
python .\scripts\safe_replace_text.py --path .\target.md --old "before" --new "after"
```

Both helpers restrict writes to the project root, reject dangerous paths, make timestamped backups, write UTF-8, read back the result, check for `???`, and output JSON.

## Diagnostics

Use the read-only diagnostic script when the user wants evidence about the local failure pattern:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\diagnose-codex-windows-sandbox.ps1
```

The diagnostic script must not modify files and must not require administrator privileges.

## Boundary

This skill deliberately avoids fixing Codex Desktop itself. Official product bugs should be fixed by the product owner. This skill keeps project work moving with reversible, project-local rules and helper scripts.

A successful canary or integration test only proves that the guarded workflow worked during that specific test run. It does not prove that Codex Desktop is permanently fixed, and it does not guarantee that sandbox/helper dialogs will never appear again.