# Project Rules

This repository is being developed on Windows with Codex Desktop.

Do not use apply_patch.

When creating or modifying files, use PowerShell or Python scripts with explicit UTF-8 encoding.

Before editing files:
1. Explain the planned changes.
2. List files to be modified.
3. Wait for confirmation.

After editing files:
1. Run git status --short.
2. Run git diff --name-only.
3. Verify non-ASCII text is not corrupted into ???.

Do not modify .codex, WindowsApps, Codex Desktop installation files, Cursor extension files, or AppData Codex binaries.