"""Read-only bitmap analysis. Keeps original pixels; produces crop metadata only."""
import json
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
assets = root / "assets" / "painterly"
cases = {
    "redboy-fire-fullbody-v9.png": [(0, 0, 768, 500), (768, 0, 768, 496), (0, 512, 840, 512), (840, 496, 696, 528)],
    "tangseng-prayer-fullbody-v9.png": [(x, y, w, h) for y, h in [(0, 338), (338, 344), (682, 342)] for x, w in [(165, 260), (425, 335), (760, 310), (1070, 340)]],
}
reports = []
for name, rectangles in cases.items():
    image = Image.open(assets / name).convert("RGBA")
    alpha = image.getchannel("A")
    frames = []
    for index, (x, y, w, h) in enumerate(rectangles):
        bounds = alpha.crop((x, y, x + w, y + h)).point(lambda a: 255 if a > 25 else 0).getbbox()
        clear = bounds is not None and bounds[0] > 0 and bounds[1] > 0 and bounds[2] < w and bounds[3] < h
        frames.append({"index": index, "atlas_region": [x, y, w, h], "visible_alpha_bounds": bounds, "clear_of_crop_edges": clear})
    reports.append({"asset": name, "size": image.size, "corner_alpha": image.getpixel((0, 0))[3], "frames": frames})
report = {"assets": reports, "human_slow_motion_review": "pending", "professional_hand_drawn_acceptance": False, "scope": "Alpha crop boundaries only; no bitmap edits, no certification of anatomy, gait or animation continuity."}
(root / "tests" / "art-v9-alpha-audit.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
failures = [(r["asset"], f["index"]) for r in reports for f in r["frames"] if not f["clear_of_crop_edges"]]
print(json.dumps({"frames": sum(len(r["frames"]) for r in reports), "crop_edge_failures": failures, "human_approved": 0}))
raise SystemExit(1 if failures else 0)
