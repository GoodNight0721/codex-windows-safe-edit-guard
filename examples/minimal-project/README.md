# Minimal Project Example

This example shows the smallest intended use case.

You have a normal project, and Codex Desktop on Windows can run shell commands, but file edits may trigger `codex-windows-sandbox-setup.exe`.

Recommended steps:

1. Copy `templates/AGENTS.md.template` into the target project's `AGENTS.md`, or install it with PowerShell.
2. Ask Codex to explain planned edits and list files before editing.
3. Confirm the plan.
4. Have Codex write files with PowerShell or Python using explicit UTF-8.
5. Review `git status --short` and `git diff --name-only`.

The goal is not to change how the project builds. The goal is to make file edits predictable on Windows when `apply_patch` or sandbox helpers are unreliable.