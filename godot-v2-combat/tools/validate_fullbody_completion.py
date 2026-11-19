"""Fail-closed artwork delivery check. Does not grant review or professional status."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def validate(clip):
    errors = []
    asset = clip.get("asset", "")
    path = ROOT / asset.removeprefix("res://")
    if not asset or not path.is_file():
        errors.append("missing_asset")
    frames = clip.get("frames", [])
    if len(frames) < clip["minimum_distinct_drawings"]:
        errors.append("insufficient_frames")
    fingerprints = set()
    for frame in frames:
        # Frame image hash is recorded by the production importer, never by a status button.
        digest = frame.get("pixel_sha256", "")
        if len(digest) != 64:
            errors.append("missing_frame_fingerprint")
        else:
            fingerprints.add(digest)
        if not all(k in frame for k in ("region", "foot_anchor", "hand_anchors", "duration")):
            errors.append("missing_timing_or_anchors")
        if frame.get("duration", 0) <= 0:
            errors.append("invalid_frame_duration")
    if len(fingerprints) < clip["minimum_distinct_drawings"]:
        errors.append("insufficient_distinct_drawings")
    review = clip.get("manual_review", "pending")
    if not isinstance(review, dict) or not review.get("reviewer") or review.get("verdict") != "approved":
        errors.append("manual_review_pending")
    elif asset and path.is_file() and review.get("asset_sha256") != hashlib.sha256(path.read_bytes()).hexdigest():
        errors.append("review_for_different_asset")
    if clip.get("art_origin") != "human_hand_drawn":
        errors.append("not_professional_hand_drawn_source")
    return sorted(set(errors))

def main(require_complete=False):
    inventory = json.loads((ROOT / "data/fullbody_production.json").read_text(encoding="utf-8"))
    results = [{"id": c["id"], "issues": validate(c)} for c in inventory["clips"]]
    counts = {h["id"]: {"required_sequences": h["clips"],
                         "accepted_sequences": sum(not r["issues"] for r in results if r["id"].startswith(h["id"] + "/"))}
              for h in inventory["roles"]}
    report = {"scope": "Technical delivery gate only; cannot perform or substitute artist work or human slow-motion review.",
              "roles": counts, "complete": all(not r["issues"] for r in results), "clips": results}
    (ROOT / "tests/fullbody-completion-v10.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"roles": counts, "complete": report["complete"]}, ensure_ascii=False))
    return 1 if require_complete and not report["complete"] else 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--require-complete", action="store_true")
    args = parser.parse_args()
    raise SystemExit(main(args.require_complete))
