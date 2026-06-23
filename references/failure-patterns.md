# Failure Patterns

Use this page to recognize common symptoms and choose a safer next step.

## Phone or remote client keeps running

Symptom: the remote UI continues to show `running`, but no useful progress appears.

Suggested action: check the desktop. If a sandbox helper popup is waiting, stop the risky edit path and use the safe edit workflow.

## Desktop popup appears

Symptom: Windows shows a `codex-windows-sandbox-setup.exe` popup or a module-related error.

Suggested action: do not retry the same edit helper repeatedly. Use PowerShell or Python scripts with explicit UTF-8 and keep changes project-local.

## Git shows untracked files

Symptom: `git status --short` shows new files that were not expected.

Suggested action: review paths carefully. Do not delete untracked files unless the user confirms.

## Chinese text becomes ???

Symptom: Chinese or other non-ASCII text is replaced by question marks.

Suggested action: restore from backup if available, then rewrite with explicit UTF-8. Search the changed Markdown, YAML, Python, and PowerShell files for `???` before continuing.

## Patch succeeds but popup still appears

Symptom: the file content changed, but the Codex Desktop popup still appears.

Suggested action: treat the edit path as unreliable. Continue using the safe edit workflow and inspect Git state after every edit.

## Accidental delete or modification risk

Symptom: an agent wants to clean generated files, remove untracked files, or revert broad paths.

Suggested action: ask the user first. Keep recovery simple and avoid touching protected app or configuration paths.