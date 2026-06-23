# Codex Safe Edit Rules for Windows

These rules are for projects used with Codex Desktop on Windows when file editing helpers may trigger sandbox helper failures.

## Why these rules exist

Some users see `codex-windows-sandbox-setup.exe` popups or stalled sessions when Codex uses `apply_patch` or an internal file editing helper. At the same time, ordinary PowerShell and Python commands may still work. This template keeps edits simple, visible, and reversible.

## Rule details

### Do not use apply_patch

`apply_patch` can be convenient, but on affected Windows setups it may trigger the failure path. Use PowerShell or Python scripts instead.

### Do not use built-in file edit helpers

Use plain scripts where the exact write operation is visible. This makes it easier to audit what changed.

### Plan before editing

Before changing files, the agent should explain the intended changes, list the files to be modified, and wait for confirmation. This prevents accidental edits outside the requested scope.

### Use explicit UTF-8

Windows tools can use different default encodings. Always specify UTF-8 when reading or writing Markdown, YAML, Python, PowerShell, JSON, or text files.

### Check non-ASCII content

After writing Chinese or other non-ASCII content, read the file back and search for unexpected `???`. This is a simple signal that encoding may have failed.

### Review Git state

Always run:

```powershell
git status --short
git diff --name-only
```

This shows what changed without committing anything.

### Avoid dangerous paths

Do not modify `.codex`, `WindowsApps`, Codex Desktop installation files, Cursor extension files, or AppData Codex binaries. Those paths are outside the purpose of a project-level guardrail and can be hard to recover safely.

## What to do if something goes wrong

- Stop editing.
- Review `git status --short` and `git diff`.
- Restore from the `.bak_yyyyMMdd_HHmmss` backup if a safe helper created one.
- Ask the user before deleting untracked files or reverting changes.

<!-- safe-edit-guard-green-tests-note -->

## Green tests do not prove the upstream bug is gone

A green canary result is useful, but it is not proof that the upstream Codex Desktop bug has disappeared.

It only proves that the current safe workflow avoided the risky path during that specific run. Continue to avoid `apply_patch` and built-in file edit helper paths unless the user explicitly disables this guard.

