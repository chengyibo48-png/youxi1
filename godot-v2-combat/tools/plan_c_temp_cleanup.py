"""Hash only generated test fixtures inside the current user's Temp. Read-only plan."""
from pathlib import Path
import collections
import hashlib
import json
import os
import time
import sys

ROOT = Path(__file__).resolve().parents[1]
TEMP = Path.home() / "AppData/Local/Temp"
fixtures = []
groups = collections.defaultdict(list)
for directory in TEMP.glob("zrz-verify-*"):
    if not directory.is_dir() or directory.is_symlink():
        continue
    path = directory / "fixture.json"
    if not path.is_file() or path.is_symlink():
        continue
    stat = path.stat()
    with path.open("rb") as stream:
        sha = hashlib.file_digest(stream, "sha256").hexdigest()
    entry = {"path": str(path), "bytes": stat.st_size, "mtime": stat.st_mtime, "sha256": sha}
    fixtures.append(entry)
    groups[sha].append(entry)
    if len(fixtures) % 30 == 0:
        print(json.dumps({"hashed_fixtures": len(fixtures)}, ensure_ascii=True), flush=True)
archive_mode = "--archive-recent-duplicates" in sys.argv
cutoff = time.time() - (2 * 3600 if archive_mode else 86400)
delete = []
retained = []
for sha, entries in groups.items():
    entries.sort(key=lambda row: row["mtime"], reverse=True)
    keeper = entries[0]
    retained.append(keeper)
    for entry in entries[1:]:
        if entry["mtime"] < cutoff:
            entry["retained"] = keeper["path"]
            entry["reason"] = "byte-identical generated verification fixture, older than %s; latest matching fixture retained" % ("2h; reversible D: archive only" if archive_mode else "24h")
            delete.append(entry)
        else:
            retained.append(entry)
plan = {"temp_root": str(TEMP), "files": delete, "retained": retained, "bytes_to_remove": sum(row["bytes"] for row in delete), "hashed_count": len(fixtures), "fixture_total_bytes": sum(row["bytes"] for row in fixtures), "age_cutoff": cutoff,
        "scope": "Only zrz-verify-*/fixture.json duplicates in user Temp. No session history, originals, saves, installed programs, NVIDIA or Windows update files."}
(ROOT / ("tests/c-temp-archive-plan.json" if archive_mode else "tests/c-temp-cleanup-plan.json")).write_text(json.dumps(plan, ensure_ascii=False, indent=2), "utf-8")
print(json.dumps({"fixtures": len(fixtures), "fixture_gib": plan["fixture_total_bytes"] / 1024**3, "duplicate_files": len(delete), "candidate_gib": plan["bytes_to_remove"] / 1024**3, "unique_hashes": len(groups), "action": "reversible archive" if archive_mode else "delete stale duplicate"}, ensure_ascii=True), flush=True)
