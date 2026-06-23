# codex-windows-safe-edit-guard

Language: [中文](README.md) | English

Codex Desktop on Windows may sometimes show an error like this while editing files:

```text
C:\Program Files\WindowsApps\OpenAI.Codex_...\app\resources\codex-windows-sandbox-setup.exe
The specified module could not be found.
```

![codex-windows-sandbox-setup.exe 找不到指定的模块](assets/codex-windows-sandbox-setup-dialog-zh.png)

This project does not fix Codex Desktop itself. Until the upstream issue is fixed, it helps Windows users avoid the high-risk `apply_patch` / built-in file edit helper path and continue working through a more observable PowerShell/Python UTF-8 write workflow.

It is a workaround / guardrail, not an official fix. It does not modify WindowsApps, repack MSIX, replace OpenAI binaries, disable the sandbox, or promise a 100% fix.

## What is the problem?

Common symptoms include:

- Normal PowerShell, Python, or Node commands may work.
- Codex file edits, especially through `apply_patch` or a built-in file edit helper, may trigger `codex-windows-sandbox-setup.exe`.
- The dialog may say `The specified module could not be found` or show the Chinese equivalent.
- A phone or web client may keep showing `running`, while the Windows desktop is actually waiting on a dialog.
- A patch may appear to succeed while the dialog still appears, making the next state hard to trust.

This repository gives the project a rule set and small helper scripts so Codex avoids the edit path that often triggers the dialog.

## Why does this happen?

Based on public issues and user reproductions, this problem often appears when Codex Desktop on Windows uses `apply_patch` or its built-in file editing helper. Ordinary PowerShell/Python/Node commands may still work, but the file edit path can trigger `codex-windows-sandbox-setup.exe`.

This looks more like an upstream Windows Desktop / AppX / sandbox helper launch-chain problem than a project-code bug or malware. This repository does not claim a confirmed root cause or an official diagnosis.

## Why not fix it at the root?

A real fix should come from the Codex Desktop upstream owner. Modifying WindowsApps, repacking MSIX, editing `app.asar`, or replacing OpenAI binaries is risky:

- It may require administrator permissions or break Windows app integrity.
- It may interfere with Codex Desktop updates.
- It can be hard to roll back safely.
- Normal project development should not depend on patching installed application files.

This project chooses a project-level guardrail instead. The rules live in your project, the scripts work inside your project, no administrator permissions are required, and the setup is easy to remove.

## How does this work around the issue?

It tells Codex to follow these rules:

- Do not use `apply_patch`.
- Do not use the built-in file edit helper.
- Before editing, list the plan and files, then wait for user confirmation.
- Create or modify files only through PowerShell or Python with explicit UTF-8.
- After writing non-ASCII content, read it back and check that it did not become `???`.
- After editing, run `git status --short` and `git diff --name-only`.
- Do not commit or push unless the user explicitly asks.

## File layout

```text
README.md                                  Chinese README
README.en.md                               English README
README.zh-CN.md                            Compatibility redirect
SKILL.md                                   Agent Skill instructions
agents/openai.yaml                         Basic metadata
templates/AGENTS.md.template               Copyable project rule template
templates/CODEX_SAFE_EDIT_RULES.md         Beginner-friendly rule explanation
scripts/install-agents-rule.ps1            Install AGENTS.md rules
scripts/diagnose-codex-windows-sandbox.ps1 Read-only diagnostics
scripts/codex-sandbox-canary.ps1           UTF-8 / Python / git canary
scripts/safe_write_utf8.py                 Safe UTF-8 file writer
scripts/safe_replace_text.py               Safe UTF-8 text replacer
references/known-issues.md                 Known issue keywords
references/failure-patterns.md             Common symptoms
references/why-not-patch-windowsapps.md    Why this does not patch WindowsApps
examples/                                  Example project notes
assets/                                    Screenshot assets
```

## Three ways to use it

### A. Manually copy the AGENTS.md template

Copy `templates/AGENTS.md.template` into the target project's `AGENTS.md`. If the project already has an `AGENTS.md`, merge the rules into it.

Then tell Codex to follow `AGENTS.md` and not use `apply_patch`.

### B. Install into a target project with PowerShell

Run this from this repository:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-agents-rule.ps1 -ProjectRoot D:\path\to\your-project
```

The script only modifies the target project's `AGENTS.md`. If `AGENTS.md` already exists, it creates a backup named `AGENTS.md.bak_yyyyMMdd_HHmmss`.

### C. Paste a prompt into Codex

If you do not want to run scripts yourself, paste this prompt into Codex. The important part is that Codex still must not use `apply_patch`.

Chinese prompt:

```text
当前 Windows Codex Desktop 可能在 apply_patch / file edit helper 时触发 codex-windows-sandbox-setup.exe 找不到指定模块。请不要使用 apply_patch。请把 codex-windows-safe-edit-guard 的 AGENTS.md 规则安装到当前项目。所有写文件都通过 PowerShell 或 Python UTF-8 完成。写前列计划和文件清单，等待我确认；写后检查 git status --short 和 git diff --name-only，并检查非 ASCII 内容没有变成 ???。不要 commit，不要 push。
```

English prompt:

```text
This Windows Codex Desktop project may trigger a codex-windows-sandbox-setup.exe "The specified module could not be found" error when using apply_patch or the built-in file edit helper. Do not use apply_patch. Install the codex-windows-safe-edit-guard AGENTS.md rules into the current project. Write files only through PowerShell or Python with explicit UTF-8. Before editing, list the plan and files and wait for my confirmation. After editing, run git status --short and git diff --name-only, and verify non-ASCII text did not become ???. Do not commit or push.
```

## Quick start for beginners

1. Download or clone this repository.
2. Open PowerShell in this repository.
3. Install the rules into your project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-agents-rule.ps1 -ProjectRoot D:\path\to\your-project
```

4. In the target project, ask Codex to continue while following `AGENTS.md`.
5. To test the safe write path on this machine, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\codex-sandbox-canary.ps1
```

6. To collect read-only diagnostic information, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\diagnose-codex-windows-sandbox.ps1
```

## FAQ

### Is this an official OpenAI project?

No. This is not an official OpenAI project and is not endorsed as an official fix.

### Does it fix Codex Desktop?

No. It only helps your project avoid an edit path that may trigger the problem. The root fix should come from the Codex Desktop upstream owner.

### Does it modify WindowsApps?

No. It does not modify WindowsApps, repack MSIX, edit `app.asar`, or replace OpenAI binaries.

### Does it disable the sandbox?

No. It does not disable or bypass the sandbox. It changes the project file editing workflow to plain PowerShell/Python UTF-8 writes.

### Why check for `???`?

When Chinese or other non-ASCII text is written with the wrong encoding, it may become `???`. The workflow asks agents to read files back and check for that.

### Should Codex commit automatically?

Usually no. Review `git status --short` and `git diff` first, then decide whether to commit.

## Limitations

- Not official.
- Not a root fix.
- Not guaranteed to solve every Codex Windows issue.
- Cannot stop Codex Desktop itself from showing dialogs.
- Cannot repair upstream Windows/AppX/MSIX/sandbox helper bugs.
- Only reduces project-level file edit risk and makes the workflow more observable.

## License

MIT. See [LICENSE](LICENSE).
