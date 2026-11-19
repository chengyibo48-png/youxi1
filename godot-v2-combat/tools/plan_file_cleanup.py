"""Build a reviewable, hash-checked plan. Deletion is performed by native PowerShell."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
audit = json.loads((ROOT / "tests/file-cleanup-audit-before.json").read_text("utf-8"))
media = json.loads((ROOT / "tests/file-cleanup-media-verified.json").read_text("utf-8"))
references = []
for path in ROOT.rglob("*"):
    if path.is_file() and path.suffix in {".md", ".gd", ".py", ".ps1", ".tscn", ".tres", ".cfg", ".mjs"}:
        if path.relative_to(ROOT).parts[0] not in {".godot", "exports", "build"}:
            references.append(path.read_text("utf-8-sig", errors="replace"))
reference_text = "\n".join(references)

def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()

items = {}
retained = []
def add(relative, reason, keeper=None):
    path = (ROOT / relative).resolve()
    if not path.is_relative_to(ROOT) or not path.is_file() or path.is_symlink():
        raise ValueError("Unsafe cleanup target: " + relative)
    entry = {"path": relative, "bytes": path.stat().st_size, "sha256": digest(path), "reason": reason}
    if keeper:
        entry["retained"] = keeper
        entry["retained_sha256"] = digest(ROOT / keeper)
    items[relative] = entry

for relative in audit["zero_byte"]:
    if relative.startswith("tests/") and relative.endswith(".log"):
        add(relative, "empty generated log; test output may regenerate it")
for group in audit["exact_duplicates"]:
    files = group["files"]
    if all(p.startswith("tests/") and p.endswith(".log") for p in files):
        protected = [p for p in files if p in reference_text or Path(p).name in reference_text]
        keeper = protected[0] if protected else max(files, key=lambda p: ("final" in p, "v11" in p, (ROOT / p).stat().st_mtime))
        for relative in files:
            if relative != keeper and relative not in protected:
                add(relative, "unreferenced byte-identical generated log", keeper)
    else:
        retained.append({"files": files, "reason": "licensed distribution copy, before/after evidence, historical stage record or category-specific document"})
for row in media:
    if row.get("safe_intermediate") and row["avi"] not in reference_text:
        add(row["avi"], "encoded intermediate: verified video timing, sampled picture and complete MP4 decode; compressed playback recording retained", row["retained"])
for frame in range(4):
    relative = "tests/export-home-smoke%08d.png" % frame
    keeper = "tests/export-home-smoke00000004.png"
    if digest(ROOT / relative) == digest(ROOT / keeper):
        add(relative, "identical home recording frame; final documented screenshot retained", keeper)
for folder in ["enemies", "effects", "scenes"]:
    directory = ROOT / "assets" / folder
    if list(directory.iterdir()) == [directory / "README.md"]:
        add("assets/" + folder + "/README.md", "placeholder-only category; no runtime resources in this directory")
for path in (ROOT / ".godot/exported").rglob("*"):
    if path.is_file():
        add(path.relative_to(ROOT).as_posix(), "regenerable export conversion cache; imported runtime assets kept")
archive_items = [entry for path, entry in items.items() if path.endswith(".avi")]
delete_items = [entry for path, entry in items.items() if not path.endswith(".avi")]
plan = {"root": str(ROOT), "files": delete_items, "archive_media": archive_items, "archive_root": str(ROOT.parent / "工程清理归档-20261011" / ROOT.name), "bytes_to_remove": sum(v["bytes"] for v in delete_items), "bytes_to_archive": sum(v["bytes"] for v in archive_items), "preserved_duplicate_groups": retained,
        "constraints": "Keep source code, original art, all MP4 history, unique AVI history, imported runtime assets, export template, licenses, current EXE and ZIP."}
(ROOT / "tests/file-cleanup-plan.json").write_text(json.dumps(plan, ensure_ascii=False, indent=2), "utf-8")
print(json.dumps({"files_to_delete": len(delete_items), "bytes_to_remove": plan["bytes_to_remove"], "files_to_archive": len(archive_items), "bytes_to_archive": plan["bytes_to_archive"]}, ensure_ascii=True))
