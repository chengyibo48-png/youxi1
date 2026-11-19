"""Read original alpha; identify complete silhouettes without editing any bitmap."""
import json
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ROLES = ['wukong', 'tangseng', 'bajie', 'shaseng', 'bailongma']

def components(mask):
    parents, bounds, previous = [], [], []
    def find(i):
        while parents[i] != i:
            parents[i] = parents[parents[i]]
            i = parents[i]
        return i
    for y, row in enumerate(mask):
        edges = np.flatnonzero(np.diff(np.r_[False, row, False].astype(np.int8)))
        current = []
        start_index = 0
        for left, right in zip(edges[::2], edges[1::2]):
            i = len(parents); parents.append(i)
            bounds.append([int(left), y, int(right), y+1, int(right-left)])
            while start_index < len(previous) and previous[start_index][1] < left:
                start_index += 1
            j = start_index
            while j < len(previous) and previous[j][0] <= right:
                parents[find(previous[j][2])] = find(i)
                j += 1
            current.append((left, right, i))
        previous = current
    merged = {}
    for i, box in enumerate(bounds):
        key = find(i)
        if key not in merged: merged[key] = box.copy()
        else:
            old = merged[key]
            old[:4] = [min(old[0], box[0]), min(old[1], box[1]), max(old[2], box[2]), max(old[3], box[3])]
            old[4] += box[4]
    outlines = {key: {} for key, b in merged.items() if b[4] > 2000}
    for i, (left, y, right, _, _) in enumerate(bounds):
        key = find(i)
        if key not in outlines: continue
        row = outlines[key].setdefault(y, [left, right])
        row[0], row[1] = min(row[0], left), max(row[1], right)
    return [{'box': merged[key], 'spans': [[y, max(0, l-1), min(mask.shape[1], r+1)] for y,(l,r) in sorted(rows.items())]} for key, rows in outlines.items()]

result = {}
for role in ROLES:
    path = ROOT/'assets/painterly'/f'{role}-fullbody-walk-v10-draft.png'
    image = Image.open(path).convert('RGBA')
    boxes = components(np.asarray(image)[:, :, 3] > 25)
    rows = []
    for row in range(4):
        candidates = [b for b in boxes if int(((b['box'][1]+b['box'][3])/2)/(image.height/4)) == row]
        candidates.sort(key=lambda b: (b['box'][0]+b['box'][2])/2)
        if len(candidates) != 8:
            raise ValueError(f'{role} row {row}: expected eight independent silhouettes, found {len(candidates)}')
        rows.append(candidates)
    max_height = max(b['box'][3]-b['box'][1] for row in rows for b in row)
    frames = []
    for row in rows:
        records = []
        for component in row:
            left, top, right, bottom, area = component['box']
            # Source-region margin only. Scale remains constant across every frame.
            x, y = max(0, left-2), max(0, top-2)
            endx, endy = min(image.width, right+2), min(image.height, bottom+2)
            records.append({'region': [x,y,endx-x,endy-y],
                            'pivot': [(left+right)/2-x,bottom-y], 'alpha_area': area,
                            'spans':component['spans']})
        frames.append(records)
    result[role] = {'asset': f'res://assets/painterly/{path.name}', 'scale': 110/max_height,
                    'frames': frames, 'origin': 'AI-assisted draft; user authorized provisional integration',
                    'professional_accepted': False, 'gait_continuity': 'needs redraw'}
(ROOT/'data/fullbody_regions_v11.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({r: {'frames':32, 'scale':result[r]['scale']} for r in ROLES}))
