# Codex Safe Edit Rules for Windows

These rules are for Windows Codex Desktop projects where file editing may trigger `codex-windows-sandbox-setup.exe` errors.

They are a workaround / guardrail, not an official OpenAI fix and not a root fix. They do not guarantee that the upstream bug is solved.

## The short version

If normal PowerShell or Python commands work, but Codex file edits trigger a sandbox helper dialog, avoid the risky edit path. Ask Codex to write files with explicit PowerShell or Python UTF-8 operations instead.

## What these rules never do

- They do not modify WindowsApps.
- They do not repackage MSIX.
- They do not edit app.asar.
- They do not replace OpenAI binaries.
- They do not disable the sandbox.
- They do not require administrator permissions.

## Rule details

### Do not use apply_patch

`apply_patch` can be convenient, but on affected Windows setups it may trigger the sandbox helper failure path. Use PowerShell or Python scripts instead.

### Do not use built-in file edit helpers

Use plain scripts where the exact write operation is visible. This makes it easier to audit what changed and recover from a bad edit.

### Plan before editing

Before changing files, the agent should explain the intended changes, list the files to be modified, and wait for confirmation.

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