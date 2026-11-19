"""Derive the actual five-role animation workload, without certifying artwork."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIRECTIONS = ("front", "right", "back", "left")
BASE = {"idle": 4, "walk": 8, "run": 8, "start": 4, "stop": 4,
        "turn": 4, "dash": 8, "equip": 6, "hurt": 4, "death": 8,
        "attack_1": 8, "attack_2": 8, "attack_3": 8, "charge": 6, "heavy": 10}

def read(name):
    return json.loads((ROOT / "data" / (name + ".json")).read_text(encoding="utf-8-sig"))

def build():
    heroes, weapons, skills, ultimates = map(read, ("heroes", "weapons", "skills", "ultimates"))
    target = ROOT / "data" / "fullbody_production.json"
    previous = json.loads(target.read_text(encoding="utf-8")) if target.exists() else {}
    existing = {c["id"]: c for c in previous.get("clips", [])}
    clips = []
    for hero in heroes:
        for weapon in [w for w in weapons if w["hero"] == hero["id"]]:
            definitions = [(key, frames, key) for key, frames in BASE.items()]
            definitions += [(s["id"], 12, s["name"]) for s in skills if s["hero"] == hero["id"]]
            definitions += [(s["id"], 16, s["name"]) for s in ultimates if s["hero"] == hero["id"]]
            for action, minimum, label in definitions:
                if action.startswith("attack_"):
                    label = weapon.get("combo", ["", "", ""])[int(action[-1]) - 1]
                for direction in DIRECTIONS:
                    key = "/".join((hero["id"], weapon["id"], action, direction))
                    old = existing.get(key, {})
                    clips.append({"id": key, "hero": hero["id"], "weapon": weapon["id"],
                                  "weapon_style": weapon.get("attack_style", weapon["mode"]),
                                  "action": action, "label": label, "direction": direction,
                                  "minimum_distinct_drawings": minimum,
                                  "art_origin": old.get("art_origin", "not_produced"),
                                  "asset": old.get("asset", ""), "frames": old.get("frames", []),
                                  "manual_review": old.get("manual_review", "pending"),
                                  "review_notes": old.get("review_notes", []),
                                  "runtime_approved": old.get("runtime_approved", False)})
    result = {"schema": 1, "directions": DIRECTIONS,
              "scope": "Full-body, weapon-specific sequences. Draft poses and skeletal previews are not completed clips.",
              "roles": [{"id": h["id"], "name": h["name"],
                         "clips": sum(c["hero"] == h["id"] for c in clips)} for h in heroes],
              "clips": clips}
    target.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    total = sum(c["minimum_distinct_drawings"] for c in clips)
    print(json.dumps({"roles": len(heroes), "weapons": len(weapons), "clips": len(clips),
                      "minimum_drawings_before_reuse": total,
                      "runtime_approved": sum(bool(c["runtime_approved"]) for c in clips)}, ensure_ascii=False))
    return result

if __name__ == "__main__":
    build()
