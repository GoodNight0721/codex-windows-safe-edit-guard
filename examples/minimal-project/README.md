# Minimal Project Example

This example shows the intended use in a small repository.

1. Copy or install the safe-edit guard block into the target project's `AGENTS.md`.
2. Ask Codex to explain planned edits and list files before editing.
3. Confirm the plan.
4. Have Codex write files with PowerShell or Python using explicit UTF-8.
5. Review `git status --short` and `git diff --name-only`.

The goal is not to change how the project builds. The goal is to make file edits predictable on Windows when `apply_patch` or sandbox helpers are unreliable.