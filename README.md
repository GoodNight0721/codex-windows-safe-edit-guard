# codex-windows-safe-edit-guard

Project-level safe-edit guard for Codex Desktop on Windows when `apply_patch` or sandbox helper failures interrupt normal editing.

This is not an official OpenAI project. It is a low-risk workaround and guardrail set for ordinary Windows Codex users. It does not fix Codex Desktop itself.

## When to use this

Use this project when:

- Normal PowerShell or Python commands work, but Codex file edits trigger a `codex-windows-sandbox-setup.exe` popup.
- `apply_patch` or a built-in file edit helper hangs, fails, or appears to work while still showing a sandbox helper error.
- You need a repeatable project-level rule set that tells agents to avoid risky edit paths.
- You work with non-ASCII text, such as Chinese paths or Markdown, and want explicit UTF-8 checks.

## What it does

- Provides an `AGENTS.md` template that forbids `apply_patch` and unsafe edit helpers.
- Provides safe UTF-8 write and replace helpers for project files.
- Provides a canary script to test safe file writes, Chinese text, Python execution, cleanup, and `git status`.
- Provides a read-only diagnostic script for common Codex Windows sandbox failure signals.
- Documents known symptoms, safer workflows, and why this project avoids patching protected app files.

## What it does NOT do

- It does not patch OpenAI Codex Desktop.
- It does not modify `WindowsApps`.
- It does not repackage MSIX files.
- It does not replace app binaries or `app.asar`.
- It does not disable sandboxing.
- It does not claim to be a complete or guaranteed fix.

## Quick start

From this repository:

```powershell
# Install the safe-edit AGENTS.md rules into another project
powershell -ExecutionPolicy Bypass -File .\scripts\install-agents-rule.ps1 -ProjectRoot D:\path\to\your-project

# Run a local canary in this repository
powershell -ExecutionPolicy Bypass -File .\scripts\codex-sandbox-canary.ps1

# Run read-only diagnostics
powershell -ExecutionPolicy Bypass -File .\scripts\diagnose-codex-windows-sandbox.ps1
```

Use the Python helpers directly when an agent needs to write or replace text without `apply_patch`:

```powershell
python .\scripts\safe_write_utf8.py --path .\notes.md --content-file .\draft.txt
python .\scripts\safe_replace_text.py --path .\notes.md --old "old text" --new "new text"
```

## Safe edit workflow

1. Add the guard block to the target project `AGENTS.md`.
2. Ask the agent to explain planned changes and list files before editing.
3. Confirm the plan.
4. Write files only through PowerShell or Python with explicit UTF-8.
5. Read back non-ASCII content and verify it did not become `???`.
6. Run `git status --short` and `git diff --name-only`.
7. Review changes before committing. Do not commit or push unless explicitly requested.

## Scripts overview

| Script | Purpose |
| --- | --- |
| `scripts/install-agents-rule.ps1` | Appends or creates a safe-edit guard block in a target project's `AGENTS.md`. |
| `scripts/diagnose-codex-windows-sandbox.ps1` | Read-only diagnostic report for Windows, Codex AppX, sandbox helper files, and sandbox logs. |
| `scripts/codex-sandbox-canary.ps1` | Creates a temporary directory in the current repo, verifies UTF-8 Chinese text and Python execution, cleans up, and shows git status. |
| `scripts/safe_write_utf8.py` | Safely writes UTF-8 content inside a project root, with backup and danger-path checks. |
| `scripts/safe_replace_text.py` | Safely replaces text inside a UTF-8 file, with backup and danger-path checks. |

## FAQ

### Is this an official OpenAI fix?

No. This is an independent project-level workaround. It is not affiliated with or endorsed by OpenAI.

### Does this remove the sandbox?

No. It avoids edit paths that are known to trigger failures for some users. It does not disable or bypass sandboxing.

### Why forbid `apply_patch`?

On some Windows setups, `apply_patch` or related file edit helpers may trigger `codex-windows-sandbox-setup.exe` failures even when normal shell commands work. This project chooses a simpler path: write with explicit PowerShell or Python UTF-8 operations.

### Can I still use Git normally?

Yes. The workflow asks agents to report `git status --short` and `git diff --name-only` after edits, but it does not commit or push unless the user explicitly asks.

## Troubleshooting

- If a Codex Desktop popup appears, stop using `apply_patch` for that project and install the guard rules.
- If Chinese text becomes `???`, restore the backup file and rewrite using explicit UTF-8.
- If `scripts/codex-sandbox-canary.ps1` fails, inspect the PASS/FAIL table and run the read-only diagnostic script.
- If a file was modified unexpectedly, use `git diff` to review it before taking any further action.

## License

MIT. See [LICENSE](LICENSE).

<!-- safe-edit-guard-readme-limitations -->

## Limitations

This tool does not fix Codex Desktop itself.

It cannot guarantee that the upstream Windows sandbox bug will not appear again. A PASS result from the canary or integration tests means the safe-edit workflow worked in the tested path. It does not mean Codex Desktop is permanently fixed.

You should still review `git status` and `git diff` after every edit.

