"""Build resource/alpha metadata only; generated PNG originals are never edited."""
from pathlib import Path
import json
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'assets/painterly'
pivots={}
for role in ['wukong','tangseng','bajie','shaseng','bailongma']:
    name=f'action-{role}-v3'
    alpha=Image.open(ART/(name+'.png')).getchannel('A')
    assert alpha.size==(1536,1024)
    lines=['[gd_resource type="SpriteFrames" load_steps=26 format=3]',f'[ext_resource type="Texture2D" path="res://assets/painterly/{name}.png" id="1"]']
    pivots[role]=[]
    for row in range(4):
        anchors=[]
        for col in range(6):
            box=alpha.crop((col*256,row*256,(col+1)*256,(row+1)*256)).point(lambda a:255 if a>30 else 0).getbbox()
            assert box, (role,row,col)
            anchors.append([128,box[3]])
            lines.extend([f'[sub_resource type="AtlasTexture" id="F{row}_{col}"]','atlas = ExtResource("1")',f'region = Rect2({col*256}, {row*256}, 256, 256)','filter_clip = true'])
        pivots[role].append(anchors)
    clips=[]
    for row,direction in enumerate(['front','right','back','left']):
        frames=','.join('{"duration":1.0,"texture":SubResource("F%d_%d")}'%(row,col) for col in range(6))
        clips.append('{"frames":['+frames+'],"loop":false,"name":&"'+direction+'","speed":12.0}')
    lines.extend(['[resource]','animations = ['+','.join(clips)+']'])
    (ROOT/f'animations/painted/{role}_action.tres').write_text('\n'.join(lines)+'\n',encoding='utf-8')
(ROOT/'data/painted_action_pivots.json').write_text(json.dumps(pivots,indent=2),encoding='utf-8')
path=ART/'regions.json'
regions=json.loads(path.read_text(encoding='utf-8'))
for group in range(4):
    name=f'chapter-landmarks-v4-{group}'
    alpha=Image.open(ART/(name+'.png')).getchannel('A')
    w,h=alpha.size
    for row in range(2):
        for col in range(4):
            x,y=col*w//4,row*h//2
            box=alpha.crop((x+2,y+2,x+w//4-2,y+h//2-2)).point(lambda a:255 if a>30 else 0).getbbox()
            assert box,(name,col,row)
            l,t,r,b=box
            regions[f'{name}:{col}:{row}']=[x+2+l,y+2+t,r-l,b-t]
path.write_text(json.dumps(regions,ensure_ascii=False,indent=2),encoding='utf-8')
print('120 attack stance frames and 32 landmark regions registered.')
