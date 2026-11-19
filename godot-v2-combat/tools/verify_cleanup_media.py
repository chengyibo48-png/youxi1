"""Read-only verification of already encoded test recordings; no media edits."""
from pathlib import Path
import json
import subprocess
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
rows = json.loads((ROOT / "tests/file-cleanup-media-before.json").read_text("utf-8"))
results = []
for row in rows:
    raw = next(s for s in row["raw"]["streams"] if s["codec_type"] == "video")
    encoded = next(s for s in row["encoded"]["streams"] if s["codec_type"] == "video")
    equal = all(raw.get(k) == encoded.get(k) for k in ["width", "height", "avg_frame_rate", "nb_frames"])
    equal = equal and abs(float(row["raw"]["format"]["duration"]) - float(row["encoded"]["format"]["duration"])) < .035
    equal = equal and [s["codec_type"] for s in row["raw"]["streams"]] == [s["codec_type"] for s in row["encoded"]["streams"]]
    result = {"avi": row["avi"], "retained": row["mp4"], "bytes": row["bytes_avi"], "same_stream_layout_and_video_timing": equal, "gray_thumbnail_mean_abs_error": []}
    if equal:
        fps = float(raw["avg_frame_rate"].split("/")[0]) / float(raw["avg_frame_rate"].split("/")[1])
        duration = float(row["raw"]["format"]["duration"])
        for when in [0, int(duration * fps * .5) / fps, max(0, duration - 2 / fps)]:
            images = []
            for key in ["avi", "mp4"]:
                response = subprocess.run(["ffmpeg", "-v", "error", "-ss", str(when), "-i", str(ROOT / row[key]), "-frames:v", "1", "-vf", "scale=320:180", "-pix_fmt", "gray", "-f", "rawvideo", "-"], capture_output=True, check=True)
                if len(response.stdout) != 320 * 180:
                    raise ValueError("Missing sampled video frame: " + row[key])
                images.append(np.frombuffer(response.stdout, np.uint8).astype(np.float32))
            result["gray_thumbnail_mean_abs_error"].append(float(np.abs(images[0] - images[1]).mean()))
        decoded = subprocess.run(["ffmpeg", "-v", "error", "-xerror", "-i", str(ROOT / row["mp4"]), "-map", "0", "-f", "null", "-"], capture_output=True)
        result["full_mp4_decode_ok"] = decoded.returncode == 0 and not decoded.stderr.strip()
        result["safe_intermediate"] = result["full_mp4_decode_ok"] and max(result["gray_thumbnail_mean_abs_error"]) < 3
    else:
        result["safe_intermediate"] = False
    results.append(result)
    (ROOT / "tests/file-cleanup-media-verified.json").write_text(json.dumps(results, ensure_ascii=False, indent=2), "utf-8")
    print(json.dumps(result), flush=True)
