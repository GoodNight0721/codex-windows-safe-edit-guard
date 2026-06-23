# Chinese Path Project Example

这个示例用于说明中文路径和中文内容场景。

建议测试内容：

- 中文 Markdown 文件名。
- 中文正文。
- PowerShell 使用 `[System.Text.UTF8Encoding]::new($false)` 写入。
- Python 使用 `encoding="utf-8"` 读写。
- 写入后搜索是否出现意外的 `???`。

推荐流程：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\codex-sandbox-canary.ps1
```

如果中文内容出现 `???`，先停止继续编辑，恢复备份，再用显式 UTF-8 重新写入。