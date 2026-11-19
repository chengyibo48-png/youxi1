"""Read-only C: metadata inventory. Never follow junctions or inspect file contents."""
from pathlib import Path
import collections
import heapq
import json
import os
import shutil
import time

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "tests/c-drive-audit.json"
start = time.time()
groups = collections.defaultdict(lambda: [0, 0])
largest = []
recent = []
errors = collections.Counter()
skipped_links = 0
file_count = 0
empty_count = 0
cutoff = time.time() - 3 * 86400
last_progress = start
queue = ["C:\\"]
while queue:
    directory = queue.pop()
    try:
        with os.scandir(directory) as entries:
            for item in entries:
                try:
                    info = item.stat(follow_symlinks=False)
                    if getattr(info, "st_file_attributes", 0) & 0x400 or item.is_symlink():
                        skipped_links += 1
                        continue
                    if item.is_dir(follow_symlinks=False):
                        queue.append(item.path)
                        continue
                    file_count += 1
                    empty_count += info.st_size == 0
                    relative = Path(item.path).relative_to("C:\\")
                    for depth in range(1, min(7, len(relative.parts))):
                        group = "C:\\" + "\\".join(relative.parts[:depth])
                        groups[group][0] += info.st_size
                        groups[group][1] += 1
                    record = (info.st_size, item.path, info.st_mtime)
                    heapq.heappush(largest, record)
                    if len(largest) > 100:
                        heapq.heappop(largest)
                    if info.st_mtime >= cutoff:
                        heapq.heappush(recent, record)
                        if len(recent) > 100:
                            heapq.heappop(recent)
                except OSError as error:
                    errors[type(error).__name__] += 1
    except OSError as error:
        errors[type(error).__name__] += 1
    if time.time() - last_progress > 15:
        print(json.dumps({"scanned_files": file_count, "elapsed_seconds": round(time.time() - start), "directory": directory}, ensure_ascii=True), flush=True)
        last_progress = time.time()
usage = shutil.disk_usage("C:\\")
report = {"disk": {"total_bytes": usage.total, "used_bytes": usage.used, "free_bytes": usage.free}, "elapsed_seconds": round(time.time() - start, 1), "scanned_files": file_count, "zero_byte_files": empty_count,
          "skipped_junctions_and_links": skipped_links, "access_errors": dict(errors),
          "directory_sizes": [{"path": path, "logical_bytes": size, "files": count} for path, (size, count) in sorted(groups.items(), key=lambda pair: pair[1][0], reverse=True)],
          "largest_files": [{"bytes": size, "path": path, "mtime": modified} for size, path, modified in sorted(largest, reverse=True)],
          "recent_large_files": [{"bytes": size, "path": path, "mtime": modified} for size, path, modified in sorted(recent, reverse=True)],
          "limits": "Metadata only. Logical directory totals overlap and count hardlinks separately; unreadable/protected files and reparse points excluded. Never treat empty or byte-identical system/application files as disposable."}
OUT.write_text(json.dumps(report, ensure_ascii=False, indent=2), "utf-8")
print(json.dumps({"disk": report["disk"], "files": file_count, "top_directories": report["directory_sizes"][:20], "recent_large_files": report["recent_large_files"][:15]}, ensure_ascii=True), flush=True)
