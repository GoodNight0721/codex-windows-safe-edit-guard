# codex-windows-safe-edit-guard

这是一个面向 Windows Codex Desktop 用户的项目级 safe-edit guard，用来在 `apply_patch` 或 sandbox helper 失败时，仍然用低风险方式推进项目开发。

本项目不是 OpenAI 官方项目，也不是官方 bug fix。它只是 workaround / guardrail，不修改 Codex Desktop 本体。

## 这是什么

`codex-windows-safe-edit-guard` 提供一组项目级规则、诊断脚本、canary 脚本和 UTF-8 安全写入工具。它的目标是让普通 Windows 用户避开高风险编辑路径，而不是修补 Codex Desktop 或 WindowsApps。

## 什么时候用

适合以下情况：

- 普通 PowerShell / Python 命令可以正常运行。
- Codex 使用 `apply_patch` 或内置文件编辑 helper 时弹出 `codex-windows-sandbox-setup.exe`。
- patch 看起来成功了，但弹窗仍然出现。
- 手机端或远端界面一直显示 running，桌面端出现 sandbox helper 弹窗。
- 项目包含中文路径、中文 Markdown 或其他非 ASCII 内容，需要明确 UTF-8 写入和校验。

## 它做什么

- 提供 `AGENTS.md` 模板，要求 agent 不使用 `apply_patch`。
- 要求编辑前先说明计划、列出文件并等待确认。
- 要求使用 PowerShell 或 Python 显式 UTF-8 写入。
- 提供 safe write / safe replace Python helper。
- 提供只读诊断脚本，帮助识别 sandbox helper 相关失败线索。
- 提供 canary 脚本，测试中文 UTF-8 写入、Python 执行、临时目录清理和 Git 状态。

## 它不做什么

- 不修复 OpenAI Codex Desktop 本体。
- 不修改 `WindowsApps`。
- 不重打包 MSIX。
- 不替换二进制文件或 `app.asar`。
- 不禁用 sandbox。
- 不承诺 100% 修复所有问题。
- 不需要管理员权限。

## 快速开始

```powershell
# 把 safe-edit 规则安装到目标项目
powershell -ExecutionPolicy Bypass -File .\scripts\install-agents-rule.ps1 -ProjectRoot D:\path\to\your-project

# 在当前仓库运行 canary
powershell -ExecutionPolicy Bypass -File .\scripts\codex-sandbox-canary.ps1

# 运行只读诊断
powershell -ExecutionPolicy Bypass -File .\scripts\diagnose-codex-windows-sandbox.ps1
```

写入或替换文本时，可以使用：

```powershell
python .\scripts\safe_write_utf8.py --path .\notes.md --content-file .\draft.txt
python .\scripts\safe_replace_text.py --path .\notes.md --old "旧文本" --new "新文本"
```

## 安全编辑流程

1. 在目标项目中安装或添加 `AGENTS.md` 规则。
2. 让 agent 在编辑前说明计划并列出将修改的文件。
3. 用户确认后再编辑。
4. 只使用 PowerShell 或 Python，并显式指定 UTF-8。
5. 对中文等非 ASCII 内容，写后读回，确认没有变成 `???`。
6. 运行 `git status --short` 和 `git diff --name-only`。
7. 用户 review 后再决定是否 commit。除非用户明确要求，不要 commit 或 push。

## 常见问题

### 这是 OpenAI 官方项目吗？

不是。本项目是独立的项目级 workaround，不代表 OpenAI 官方方案。

### 它会修复 Codex Desktop 吗？

不会。它只是在项目层面规避可能触发问题的编辑方式。

### 为什么不要用 apply_patch？

在部分 Windows 环境中，`apply_patch` 或内置编辑 helper 可能触发 `codex-windows-sandbox-setup.exe` 弹窗或失败。本项目选择用更普通、更可观察的 PowerShell / Python UTF-8 写入方式。

### 会不会修改系统安装目录？

不会。本项目明确禁止修改 `.codex`、`WindowsApps`、Codex Desktop 安装文件、Cursor extension 和 AppData Codex 二进制。

## 故障排查

- 如果桌面弹窗出现，先停止使用 `apply_patch`，改用本项目的 safe edit workflow。
- 如果中文变成 `???`，使用备份恢复，再用显式 UTF-8 重新写入。
- 如果 canary 失败，查看 PASS/FAIL 表，并运行只读诊断脚本。
- 如果 Git 出现意外未跟踪文件，先用 `git status --short` 和 `git diff` review，不要急着删除。

<!-- safe-edit-guard-readme-zh-limitations -->

## 局限性

这个工具不会修复 Codex Desktop 本体。

它不能保证上游 Windows sandbox bug 永远不会再次出现。canary 或集成测试 PASS，只能说明 safe-edit 工作流在本次测试路径中正常工作；这不代表 Codex Desktop 已经被永久修好。

每次修改文件后，仍然应该检查 `git status` 和 `git diff`。

