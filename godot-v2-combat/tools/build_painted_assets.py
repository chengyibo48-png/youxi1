"""Create fixed-cell SpriteFrames and merge NEW atlas bounds; never modify PNG pixels.
This only builds this iteration's resource files, not older authored animations/maps.
"""
from pathlib import Path
from PIL import Image
import json

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'assets/painterly'
ROLES = ['wukong','tangseng','bajie','shaseng','bailongma']
pivots = {}
for role in ROLES:
    sheet = f'walk-{role}-v2'
    lines = ['[gd_resource type="SpriteFrames" load_steps=34 format=3]',
             f'[ext_resource type="Texture2D" path="res://assets/painterly/{sheet}.png" id="1"]']
    for row in range(4):
        for col in range(8):
            lines += [f'[sub_resource type="AtlasTexture" id="F{row}_{col}"]',
                      'atlas = ExtResource("1")',
                      f'region = Rect2({col*192}, {row*256}, 192, 256)',
                      'filter_clip = true']
    clips = []
    for row, direction in enumerate(['front','right','back','left']):
        frames = ',\n'.join('{"duration": 1.0, "texture": SubResource("F%d_%d")}' % (row,col) for col in range(8))
        clips.append('{"frames": [%s], "loop": true, "name": &"%s", "speed": 12.0}' % (frames,direction))
    lines += ['[resource]', 'animations = [' + ',\n'.join(clips) + ']']
    destination = ROOT / f'animations/painted/{role}.tres'
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text('\n'.join(lines)+'\n', encoding='utf-8')
    alpha = Image.open(ART/(sheet+'.png')).getchannel('A')
    pivots[role] = []
    for row in range(4):
        direction_pivots=[]
        for col in range(8):
            bbox=alpha.crop((col*192,row*256,(col+1)*192,(row+1)*256)).point(lambda a:255 if a>30 else 0).getbbox()
            if not bbox:raise ValueError(f'Empty walk cell {role}:{col}:{row}')
            direction_pivots.append([96,bbox[3]])
        pivots[role].append(direction_pivots)
(ROOT/'data/painted_frame_pivots.json').write_text(json.dumps(pivots,indent=2)+'\n',encoding='utf-8')

regions_path = ART / 'regions.json'
regions = json.loads(regions_path.read_text(encoding='utf-8'))
sheets = [('hero-facing-v2',8,5),('chapter-landmarks-v3',4,2)]
sheets += [(f'boss-body-v3-{g}',7,6 if g<4 else 2) for g in range(5)]
boss_cuts = {
    0:[0,300,435,625,810,1010,1220,1536],
    1:[0,280,440,630,820,1040,1240,1536],
    2:[0,280,440,630,820,1035,1240,1536],
    3:[0,280,440,630,820,1040,1240,1536],
    4:[0,305,505,670,930,1110,1320,1536],
}
for sheet, columns, rows in sheets:
    path = ART / (sheet+'.png')
    if not path.exists():continue
    image = Image.open(path)
    alpha = image.getchannel('A')
    w, h = image.size
    for row in range(rows):
        for col in range(columns):
            cuts = boss_cuts[int(sheet.rsplit('-',1)[1])] if sheet.startswith('boss-body-v3-') else None
            x0,x1 = (cuts[col],cuts[col+1]) if cuts else (round(col*w/columns),round((col+1)*w/columns))
            y0,y1 = round(row*h/rows),round((row+1)*h/rows)
            # Analyze only: no edited/re-exported images, preserve original generation.
            bbox = alpha.crop((x0+2,y0+2,x1-2,y1-2)).point(lambda a:255 if a>30 else 0).getbbox()
            if not bbox:raise ValueError(f'Empty atlas cell {sheet}:{col}:{row}')
            left,top,right,bottom=bbox
            regions[f'{sheet}:{col}:{row}']=[x0+2+left,y0+2+top,right-left,bottom-top]
regions_path.write_text(json.dumps(regions,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Five fixed-cell SpriteFrames generated; new alpha bounds merged without modifying images.')
