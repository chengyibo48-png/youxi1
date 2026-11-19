"""Read-only pixel inspection of AI-assisted candidate atlases, not manual approval."""
import json
from pathlib import Path
from PIL import Image, ImageChops, ImageStat

ROOT = Path(__file__).resolve().parents[1]
ROLES = ("wukong", "tangseng", "bajie", "shaseng", "bailongma")

def audit():
    reports = []
    for role in ROLES:
        path = ROOT / "assets" / "painterly" / (role + "-fullbody-walk-v10-draft.png")
        if not path.exists():
            reports.append({"role": role, "asset": str(path.name), "missing": True})
            continue
        image = Image.open(path).convert("RGBA")
        cw, ch = image.width // 8, image.height // 4
        cells = []
        for row in range(4):
            frames = []
            for column in range(8):
                cell = image.crop((column*cw, row*ch, (column+1)*cw, (row+1)*ch))
                bounds = cell.getchannel("A").point(lambda a: 255 if a > 25 else 0).getbbox()
                frames.append(cell)
                cells.append({"direction": row, "frame": column, "region": [column*cw, row*ch, cw, ch],
                              "bounds": bounds, "clear_edges": bool(bounds and bounds[0] > 0 and bounds[1] > 0 and bounds[2] < cw and bounds[3] < ch),
                              "foot_pivot": [cw/2, bounds[3] if bounds else ch]})
            for column in range(4):
                difference = ImageChops.difference(frames[column], frames[column+4])
                cells[row*8+column]["opposite_half_rgba_mean_difference"] = sum(ImageStat.Stat(difference).mean)/4
        reports.append({"role": role, "asset": path.name, "size": image.size,
                        "cell_size": [cw, ch], "corner_alpha": image.getpixel((0, 0))[3], "cells": cells,
                        "manual_review": "pending", "runtime_approved": False,
                        "professional_hand_drawn_acceptance": False})
    report = {"schema": 1, "scope": "Crop and pixel differences only. Distinct pixels do not prove distinct gait, anatomy or continuity.", "assets": reports}
    (ROOT / "tests" / "fullbody-walk-v10-audit.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"assets": len(reports), "missing": [r["role"] for r in reports if r.get("missing")],
                      "edge_failures": {r["role"]: sum(not c["clear_edges"] for c in r.get("cells", [])) for r in reports},
                      "manual_approved": 0}))
    return report

if __name__ == "__main__":
    audit()
