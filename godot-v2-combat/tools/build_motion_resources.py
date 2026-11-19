"""Build editable animation/rig resources. PNG pixel data is never altered."""
from pathlib import Path
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
roles = ['wukong', 'tangseng', 'bajie', 'shaseng', 'bailongma']
# Keys: normalized timeline, waist counter-rotation, body compression, elbow bias.
# 0.32 = first live collision frame; 0.57 = last live collision frame.
clips = {
 'sweep1': [(0,0,0,0),(.08,-.04,1,-.08),(.23,-.18,2,-.3),(.32,-.15,1,-.18),(.42,.22,-2,.24),(.57,.1,2,.1),(.74,-.04,1,-.04),(1,0,0,0)],
 'sweep2': [(0,0,0,0),(.1,.08,1,.1),(.25,.2,2,.28),(.32,.12,0,.12),(.43,-.23,-1,-.24),(.57,-.1,2,-.1),(.78,.03,1,.03),(1,0,0,0)],
 'sweep3': [(0,0,0,0),(.1,-.05,2,-.1),(.24,-.22,-4,-.3),(.32,-.18,-3,-.2),(.4,.28,5,.25),(.57,.15,4,.15),(.76,-.03,1,-.04),(1,0,0,0)],
 'heavy': [(0,0,0,0),(.08,-.02,2,-.06),(.2,-.22,4,-.3),(.32,-.27,2,-.25),(.39,.3,7,.3),(.57,.22,6,.22),(.76,-.04,2,-.06),(1,0,0,0)],
 'thrust': [(0,0,0,0),(.1,-.06,1,-.1),(.25,-.18,2,-.25),(.32,-.08,1,-.08),(.4,.25,-2,.15),(.57,.18,0,.2),(.8,-.03,1,-.08),(1,0,0,0)],
 'throw': [(0,0,0,0),(.12,-.05,1,-.1),(.25,-.23,1,-.32),(.32,-.13,0,-.15),(.4,.2,-1,.3),(.57,.1,1,.2),(.8,-.02,0,.05),(1,0,0,0)],
 'cast': [(0,0,0,0),(.1,-.02,0,-.08),(.25,-.05,-2,-.25),(.32,0,-3,-.18),(.45,.07,-4,.18),(.57,.04,-2,.12),(.82,0,-1,.02),(1,0,0,0)],
 'bow': [(0,0,0,0),(.1,-.03,1,-.1),(.26,-.15,1,-.35),(.32,-.16,1,-.38),(.36,.06,-1,.2),(.57,.03,0,.06),(.8,-.01,0,0),(1,0,0,0)],
 'walk': [(0,0,0,0),(.125,.025,-1,.08),(.25,.04,-2,.1),(.375,.02,-1,.05),(.5,0,0,0),(.625,-.025,-1,-.08),(.75,-.04,-2,-.1),(1,0,0,0)],
 'dash': [(0,0,0,0),(.08,-.03,1,-.08),(.2,.06,-2,.1),(.32,.12,-4,.2),(.45,.14,-4,.25),(.57,.09,-2,.18),(.8,.03,1,.08),(1,0,0,0)],
}
(ROOT/'animations').mkdir(exist_ok=True)
header = '[gd_resource type="AnimationLibrary" load_steps=%d format=3]\n' % (len(roles)*len(clips)+1)
parts = [header]
entries=[]
for role in roles:
 for family, keys in clips.items():
  name=f'{role}_{family}'
  weight={'wukong':1.15,'tangseng':.55,'bajie':1.3,'shaseng':.85,'bailongma':1.0}[role]
  values=', '.join('Vector3(%s, %s, %s)' % (round(x*weight,4),round(y*weight,4),round(z*weight,4)) for _,x,y,z in keys)
  times=', '.join(str(key[0]) for key in keys)
  parts.append(f'\n[sub_resource type="Animation" id="{name}"]\nresource_name = "{name}"\nlength = 1.0\ntracks/0/type = "value"\ntracks/0/path = NodePath("Pose:pose")\ntracks/0/interp = 1\ntracks/0/keys = {{"times": PackedFloat32Array({times}), "transitions": PackedFloat32Array(1,1,1,1,1,1,1,1), "update": 0, "values": [{values}]}}\n')
  entries.append(f'&"{name}": SubResource("{name}")')
parts.append('\n[resource]\n_data = {\n'+',\n'.join(entries)+'\n}\n')
(ROOT/'animations/combat_motion.tres').write_text(''.join(parts),encoding='utf8')

profiles=json.loads((ROOT/'data/bosses.json').read_text(encoding='utf8'))
(ROOT/'data/boss_rigs').mkdir(exist_ok=True)
(ROOT/'scenes/boss_rigs').mkdir(exist_ok=True)
for i,p in enumerate(profiles):
 t=p['type'];caster=t in ['wind','bone','robe','fan','brow','mouse','rabbit']
 width=[30,38,23,20,25,32,28,19,29,30,40,23,26,22,44,34,38,21,31,23,21,28,36,42,41,20][i]
 height=[47,46,55,57,58,51,55,36,55,52,49,56,47,59,50,58,47,54,53,58,57,46,51,52,50,57][i]
 row=4 if caster or t in ['spider','scorpion'] else 7 if t=='fire' else 1 if t in ['fish','bird'] else 5 if t in ['tiger','leopard','lion','beast'] else 0 if t=='monkey' else 6
 arms=4 if t=='spider' else 1;tails=6 if t=='scorpion' else 4 if t in ['fish','monkey','mouse','tiger','leopard'] else 0;wings=1 if t=='bird' else 0
 heads=9 if i==23 else 1
 weapon='tangseng_w3' if caster else 'bailongma_w0' if t in ['bird','rabbit'] else 'shaseng_w1' if t=='fish' else 'wukong_w0' if t=='monkey' else 'bajie_w0'
 stance='weaver' if t=='spider' else 'stinger' if t=='scorpion' else 'winged' if wings else 'scribe' if caster else 'nimble' if t in ['monkey','rabbit','leopard'] else 'brute'
 names=['root','pelvis','spine','neck','head']
 for side in ['left','right']:
  names += [f'{side}_thigh',f'{side}_shin']
  for pair in range(arms):names += [f'{side}_arm_{pair}',f'{side}_forearm_{pair}']
  for pair in range(wings):names += [f'{side}_wing_{pair}',f'{side}_wing_tip_{pair}']
 names += [f'tail_{j}' for j in range(tails)]
 for j in range(1,heads):names += [f'neck_{j}',f'head_{j}']
 names += ['weapon_socket']
 resource='[gd_resource type="Resource" script_class="BossRigDefinition" load_steps=2 format=3]\n[ext_resource type="Script" path="res://scripts/boss_rig_definition.gd" id="1"]\n[resource]\nscript = ExtResource("1")\n'
 values=dict(stable_id=p['id'],title=p['name'],atlas_index=i,body_row=row,shoulder_width=width,torso_height=height,thigh_length=23+i%4,shin_length=25+i%3,arm_length=24+i%5,arm_pairs=arms,tail_segments=tails,wing_pairs=wings,head_count=heads,crouch=8 if stance in ['weaver','stinger'] else 0,weapon_id=weapon,stance=stance)
 for k,v in values.items():resource+=f'{k} = '+(json.dumps(v,ensure_ascii=False) if isinstance(v,str) else str(v))+'\n'
 resource+=f'head_size = Vector2({64 if heads==9 else 55+i%4*3}, {48+i%5*3})\n'
 (ROOT/f'data/boss_rigs/{p["id"]}.tres').write_text(resource,encoding='utf8')
 # Actual independently editable Bone2D hierarchy; runtime uses the same resource.
 scene=f'[gd_scene load_steps=2 format=3]\n[ext_resource type="Resource" path="res://data/boss_rigs/{p["id"]}.tres" id="1"]\n[node name="{p["id"]}" type="Node2D"]\nmetadata/rig = ExtResource("1")\n[node name="Skeleton2D" type="Skeleton2D" parent="."]\n'
 paths={}
 for name in names:
  parent='root' if name=='pelvis' else 'pelvis' if name in ['spine','left_thigh','right_thigh'] else 'spine' if name=='neck' or '_arm_' in name or '_wing_' in name else 'neck' if name=='head' else name.replace('_shin','_thigh') if name.endswith('_shin') else name.replace('_forearm_','_arm_') if '_forearm_' in name else name.replace('_wing_tip_','_wing_') if '_wing_tip_' in name else 'pelvis' if name.startswith('tail_') and name=='tail_0' else f'tail_{int(name[5:])-1}' if name.startswith('tail_') else 'spine' if name.startswith('neck_') else name.replace('head_','neck_') if name.startswith('head_') else 'right_forearm_0'
  path='Skeleton2D' if name=='root' else paths[parent]
  offset=(0,-height) if name=='spine' else (0,-18) if name.startswith('neck') else (-width if name.startswith('left') else width,8) if '_arm_' in name else (0,values['arm_length']) if '_forearm_' in name else (0,-36) if name=='pelvis' else (0,values['thigh_length']) if name.endswith('_shin') else (0,0)
  scene+=f'[node name="{name}" type="Bone2D" parent="{path}"]\nposition = Vector2({offset[0]}, {offset[1]})\nlength = 24.0\nautocalculate_length_and_angle = false\n'
  paths[name]=path+'/'+name
 (ROOT/f'scenes/boss_rigs/{p["id"]}.tscn').write_text(scene,encoding='utf8')

palettes={'wild':[0,1,7,3],'forest':[0,1,2,3],'temple':[2,3,6,10],'river':[4,5,2,3],'desert':[6,7,3,2],'ember':[8,7,6,3],'moon':[9,2,6,3],'city':[10,3,2,6],'night':[1,3,2,10],'grave':[6,2,11,1],'cave':[11,7,6,2],'web':[1,11,3,2]}
chapters=json.loads((ROOT/'data/chapters.json').read_text(encoding='utf8'))
art=[]
for i,c in enumerate(chapters):
 art.append(dict(chapter=i,place=c['place'],props=palettes[c['biome']],landmark=palettes[c['biome']][i%2],setback=170+i%3*18,road_width=340,composition=['paired_gate','ridge','grove','courtyard','riverbank'][i%5]))
(ROOT/'data/chapter_art.json').write_text(json.dumps(art,ensure_ascii=False,indent=2),encoding='utf8')
# Only inspect alpha to record atlas cells; do not transform PNGs.
regions=json.loads((ROOT/'assets/painterly/regions.json').read_text())
for sheet,cols,rows,count in [('chapter-props-v2',4,3,12),('boss-heads-v2',6,5,26),('boss-heads-v3',6,5,26),('boss-parts-v2',4,3,12),('boss-lion-head',1,1,1)]:
 image=Image.open(ROOT/f'assets/painterly/{sheet}.png');w,h=image.size
 for index in range(count):
  col=index%cols;row=index//cols;x0=round(col*w/cols)+2;y0=round(row*h/rows)+2;x1=round((col+1)*w/cols)-2;y1=round((row+1)*h/rows)-2
  alpha=image.getchannel('A').crop((x0,y0,x1,y1));box=alpha.point(lambda v:255 if v>40 else 0).getbbox()
  if box:
   a,b,c,d=box;regions[f'{sheet}:{col}:{row}']=[x0+a,y0+b,c-a,d-b]
(ROOT/'assets/painterly/regions.json').write_text(json.dumps(regions,indent=2),encoding='utf8')
print('Built 50 authored clips, 26 rig resources/scenes, 37 chapter briefs; source PNGs unchanged.')
