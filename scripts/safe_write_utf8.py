#!/usr/bin/env python3
import argparse
import json
import shutil
import sys
from datetime import datetime
from pathlib import Path

DANGEROUS_PARTS = {".git", ".codex"}
DANGEROUS_ABSOLUTE_MARKERS = (
    "windowsapps",
    "appdata\\local\\openai\\codex",
    "appdata/local/openai/codex",
    "appdata\\roaming\\openai\\codex",
    "appdata/roaming/openai/codex",
    "cursor\\user\\globalstorage",
    "cursor/user/globalstorage",
    "cursor\\extensions",
    "cursor/extensions",
)


def resolve_inside_project(project_root, target):
    root = Path(project_root).resolve()
    path = Path(target)
    resolved = path.resolve() if path.is_absolute() else (root / path).resolve()
    try:
        resolved.relative_to(root)
    except ValueError as exc:
        raise ValueError("Refusing to write outside project root: {}".format(resolved)) from exc
    return root, resolved


def reject_dangerous_path(project_root, target):
    rel = target.relative_to(project_root)
    parts_lower = [part.lower() for part in target.parts]
    full_text = str(target).lower().replace("/", "\\")

    for part in DANGEROUS_PARTS:
        if part in parts_lower or part in [p.lower() for p in rel.parts]:
            raise ValueError("Refusing to write inside {}".format(part))

    for marker in DANGEROUS_ABSOLUTE_MARKERS:
        normalized = marker.lower().replace("/", "\\")
        if normalized in full_text:
            raise ValueError("Refusing dangerous path marker: {}".format(marker))


def backup_existing(path):
    if not path.exists():
        return None
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup = path.with_name(path.name + ".bak_{}".format(timestamp))
    shutil.copy2(path, backup)
    return str(backup)


def main():
    parser = argparse.ArgumentParser(description="Safely write a UTF-8 file inside a project root.")
    parser.add_argument("--path", required=True, help="Target file path.")
    parser.add_argument("--content-file", required=True, help="File containing replacement content, read as UTF-8.")
    parser.add_argument("--project-root", default=".", help="Allowed project root. Defaults to current directory.")
    args = parser.parse_args()

    summary = {
        "path": None,
        "backup_path": None,
        "bytes_written": 0,
        "contains_question_marks": None,
        "success": False,
        "error": None,
    }

    try:
        project_root, target = resolve_inside_project(args.project_root, args.path)
        reject_dangerous_path(project_root, target)
        content_path = Path(args.content_file).resolve()
        content = content_path.read_text(encoding="utf-8")

        target.parent.mkdir(parents=True, exist_ok=True)
        backup_path = backup_existing(target)
        target.write_text(content, encoding="utf-8", newline="")
        read_back = target.read_text(encoding="utf-8")
        encoded = read_back.encode("utf-8")

        summary.update({
            "path": str(target),
            "backup_path": backup_path,
            "bytes_written": len(encoded),
            "contains_question_marks": "???" in read_back,
            "success": "???" not in read_back,
        })
    except Exception as exc:
        summary["error"] = str(exc)

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0 if summary["success"] else 1


if __name__ == "__main__":
    sys.exit(main())