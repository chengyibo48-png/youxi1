from pathlib import Path
import json,ast
R=Path(__file__).resolve().parents[1]
def edit(n,o,v):
 p=R/n;s=p.read_text(encoding='utf-8');assert o in s,(n,o[:50]);p.write_text(s.replace(o,v,1),encoding='utf-8')
edit('scripts/content_extension.gd','a.branch==0','a.definition.get("branch",0)==1')
for o,v in [('"梵钟",false,28','"梵钟",false'),('"铜钟",false,30','"铜钟",false'),('"铜钟共鸣",false,12','"铜钟共鸣",false')]:edit('scripts/content_extension.gd',o,v)
edit('scripts/relic_synergy.gd','"shield":"释放绝技额外获得12护盾，至少间隔2秒"','"shield":"释放绝技额外获得12护盾，至少间隔2秒",\n "relic_recall":"第三连击追加一枚回旋环，至少间隔1秒",\n "relic_lotus":"施术额外回复2生命，至少间隔1秒",\n "relic_bell":"护盾受击反震，至少间隔2秒",\n "relic_hourglass":"重击为附近敌人追加流沙印，至少间隔1秒",\n "relic_quiver":"闪避追加穿透水箭，至少间隔1秒"')
edit('scripts/relic_synergy.gd','"shield":"ultimate"}','"shield":"ultimate","relic_recall":"third","relic_lotus":"skill","relic_bell":"shield_hit","relic_hourglass":"heavy","relic_quiver":"dash"}')
edit('scripts/relic_synergy.gd','"barrier","root","shield"]','"barrier","root","shield","relic_bell"]')
edit('scripts/relic_synergy.gd',' match kind:\n',' preload("res://scripts/content_extension.gd").passive(c,kind,direction)\n match kind:\n')
edit('scripts/weapon_visual.gd','"stars":"d4c680"}','"stars":"d4c680","disc":"e8bb5c","lotus_lantern":"e0c4a0","gate_shield":"aabbb0","tether":"c9b082","tide_bow":"8ed5df"}')
held='''  "disc":canvas.draw_arc(Vector2(30,0),24,0,TAU,24,color,6,true);canvas.draw_circle(Vector2(30,0),5,color)
  "lotus_lantern":
   canvas.draw_line(Vector2(10,0),Vector2(50,0),color,3,true)
   for i in 5:crystal(canvas,Vector2(50,0)+Vector2.RIGHT.rotated(i*TAU/5)*10,11,color)
  "gate_shield":canvas.draw_colored_polygon(PackedVector2Array([Vector2(10,-28),Vector2(45,-22),Vector2(50,20),Vector2(25,35),Vector2(6,20)]),color);canvas.draw_line(Vector2(26,-20),Vector2(26,25),Color("465b50")*tint,5,true)
  "tether":
   var points=PackedVector2Array()
   for i in 15:points.append(Vector2(i*4,sin(i*.7)*12))
   canvas.draw_polyline(points,color,3,true);crystal(canvas,Vector2(60,0),10,color)
  "tide_bow":canvas.draw_arc(Vector2(15,0),32,-PI/2,PI/2,24,color,5,true);canvas.draw_line(Vector2(15,-32),Vector2(15,32),color,1,true);canvas.draw_line(Vector2(0,0),Vector2(62,0),color,3,true)
'''
edit('scripts/weapon_visual.gd',' canvas.draw_set_transform_matrix(base)\n',held+' canvas.draw_set_transform_matrix(base)\n')
edit('scripts/weapon_visual.gd','  _:return false','  "disc":canvas.draw_arc(p,13,0,TAU,24,col,4,true);canvas.draw_line(p-d*8,p+d*8,col,2,true)\n  "tether":canvas.draw_line(p-d*40,p,col,3,true);canvas.draw_arc(p,10,d.angle()-2,d.angle()+2,14,col,3,true)\n  "water_arrow":canvas.draw_line(p-d*22,p+d*17,col,3,true);canvas.draw_polyline(PackedVector2Array([p+d*6-d.orthogonal()*7,p+d*17,p+d*6+d.orthogonal()*7]),col,3,true)\n  _:return false')
p=R/'scripts/weapon_visual.gd';s=p.read_text(encoding='utf-8');s+='''  "disc":
   for i in 3:canvas.draw_arc(p+d*r*.4+side*(i-1)*24,r*.2,0,TAU,24,col,3,true)
  "lotus_lantern":
   for i in 8:crystal(canvas,p+Vector2.RIGHT.rotated(i*TAU/8)*r*.45,r*.2,col)
   canvas.draw_circle(p,r*.1,col)
  "gate_shield":
   canvas.draw_colored_polygon(PackedVector2Array([p+d*20-side*r*.4,p+d*50-side*r*.3,p+d*70,p+d*50+side*r*.3,p+d*20+side*r*.4]),Color(col,.2))
   canvas.draw_line(p+d*45-side*r*.4,p+d*45+side*r*.4,col,6,true)
  "tether":
   var points=PackedVector2Array()
   for i in 20:points.append(p+d*i*r/20+side*sin(i*.7-t*10)*10)
   canvas.draw_polyline(points,col,3,true);canvas.draw_arc(p+d*r,r*.12,0,TAU,20,col,3,true)
  "tide_bow":
   canvas.draw_arc(p,r*.25,d.angle()-PI/2,d.angle()+PI/2,24,col,3,true)
   for i in 5:
    var axis=d.rotated((i-2)*.15);var end=p+axis*r*(.3+t*.6)
    canvas.draw_line(end-axis*22,end,col,3,true);canvas.draw_line(end-axis*10-axis.orthogonal()*5,end,col,2,true)
''';p.write_text(s,encoding='utf-8')
edit('scripts/layered_rig.gd','"stars": [-0.1, -1.2, -1.5, 0.2, -0.1, -4.0]}','"stars": [-0.1, -1.2, -1.5, 0.2, -0.1, -4.0],"disc":[-.2,-1.6,-.7,.2,-.1,-2.0],"lotus_lantern":[.1,-.6,-1.7,.1,0,-1.0],"gate_shield":[.5,-.4,-.8,.8,-.3,4.0],"tether":[-.3,-2.2,.1,.5,-.3,-3.0],"tide_bow":[-.15,-1.4,-2.0,.3,-.1,-2.0]}')
extra='''  "ring_storm":
   for i in 12:canvas.draw_arc(p+Vector2.RIGHT.rotated(i*TAU/12+t)*r*(.15+sin(t*PI)*.7),18,0,TAU,20,col,4,true)
  "golden_city":
   canvas.draw_rect(Rect2(p-Vector2.ONE*r*.6,Vector2.ONE*r*1.2),Color(col,.15));canvas.draw_rect(Rect2(p-Vector2.ONE*r*.6,Vector2.ONE*r*1.2),col,false,4)
   for axis in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:canvas.draw_line(p+axis*r*.25,p+axis*r*.55,col,6,true)
  "mountain_rake":
   for row in 3:
    for i in 9:canvas.draw_line(p+d*(60+row*85)+side*(i-4)*20-Vector2(0,60*(1-t)),p+d*(60+row*85)+side*(i-4)*20,col,4,true)
  "mark_collapse":
   for i in 8:
    var point=p+Vector2.RIGHT.rotated(i*TAU/8)*r*(1-t)
    canvas.draw_rect(Rect2(point-Vector2.ONE*13,Vector2.ONE*26),col,false,3);canvas.draw_line(point,p,Color(col,.2),2,true)
  "sky_bow":
   for i in 9:
    var axis=d.rotated((i-4)*.16);var end=p+axis*r*(.2+sin(t*PI)*.8)
    canvas.draw_line(end-axis*35,end,col,5,true);canvas.draw_line(end-axis*14-axis.orthogonal()*8,end,col,3,true)
'''
edit('scripts/ultimate_visual.gd','\nstatic func emit', '\n'+extra+'\nstatic func emit')
edit('scripts/ultimate_visual.gd','else 230','else 400 if effect=="sky_bow" else 300 if effect=="mountain_rake" else 230')
# Distinct extension skill gesture/FX also drives the old preview drawing path.
edit('scripts/role_presentation.gd',' var t: float=clampf(1-v.life/v.max,0,1)',' var extension_styles={"windwheel":"disc","wake_bell":"bell","rake_wall":"gate_shield","sand_guardian":"sand_seal","arrow_rain":"tide_bow"}\n if extension_styles.has(v.effect):\n  var image: Dictionary=v.duplicate();image.weapon_style=extension_styles[v.effect]\n  preload("res://scripts/weapon_visual.gd").effect(canvas,image,reduced_flash);return\n var t: float=clampf(1-v.life/v.max,0,1)')
edit('scripts/main.gd','if f.kind=="waterwall":','if f.kind in ["waterwall","rake_wall"]:')
edit('scripts/combat.gd','"summon","convert","avatars","wind","needles"','"summon","convert","avatars","wind","needles","sand_guardian"')
edit('scripts/combat.gd','"sanctuary","sand","wave","pagoda","chant","quakes","sandstorm"','"sanctuary","sand","wave","pagoda","chant","quakes","sandstorm","rake_wall","golden_city","relic_lotus"')
edit('scripts/combat.gd','"beam","fan","breath","dragon","pursue"','"beam","fan","breath","dragon","pursue","windwheel","arrow_rain"')
edit('scripts/combat.gd','"freeze","root"','"freeze","root","wake_bell","relic_hourglass"')
# Keep displayed attack cadence consistent with its timeline.
edit('scripts/combat.gd','rate*={"slash":.8,"bolt":.9,"field":.85,"orbit":1.1,"return":.8}.get(weapon.mode,1.0)','rate*=.88')
edit('scripts/combat.gd','rate*={"slash":1.15,"bolt":1.2,"field":1.2,"orbit":1.15,"return":1.2}.get(weapon.mode,1.0)','rate*=1.12')
kits=ast.literal_eval((R/'scripts/weapon_arts.gd').read_text(encoding='utf-8').split('const KITS=',1)[1].split('\n\nstatic',1)[0])
p=R/'data/weapons.json';data=json.loads(p.read_text(encoding='utf-8'))
for w in data:
 w['interval']=sum(kits[w['id']][2])
 if w['mode']=='projectile':w['mode']='bolt'
p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
edit('tools/compose_role_audio.py',"['summon','dash','freeze','lunge','mark','orbit']","['summon','dash','freeze','lunge','mark','orbit','windwheel']")
for old,new in [('counter','pull'),('pull','resource'),('blink','detonate'),('waterwall','pursue')]:
 effect={'counter':'wake_bell','pull':'rake_wall','blink':'sand_guardian','waterwall':'arrow_rain'}[old]
 edit('tools/compose_role_audio.py',f"'{old}','{new}']",f"'{old}','{new}','{effect}']")
for old,new in [('giant','avatars'),('purification','chant'),('marshal','quakes'),('sandstorm','sandburst'),('dragonflight','tide')]:
 effect={'giant':'ring_storm','purification':'golden_city','marshal':'mountain_rake','sandstorm':'mark_collapse','dragonflight':'sky_bow'}[old]
 edit('tools/compose_role_audio.py',f"['{old}','{new}']",f"['{old}','{new}','{effect}']")
edit('tools/compose_role_audio.py','64 original','74 original')
edit('tools/compose_weapon_audio.py','50 original','60 original')
edit('tests/role_visual.gd','scene.set_physics_process(false);scene.start_demo()', 'scene.set_physics_process(false);scene.home()\n await process_frame;await RenderingServer.frame_post_draw\n root.get_texture().get_image().save_png("res://tests/weapon-home.png")\n scene.start_demo()')
print('Integrated extension visuals, audio, passives and cadence.')
