from pathlib import Path
import json, shutil
root=Path(__file__).resolve().parents[1]
dest=root/'assets/painterly';dest.mkdir(parents=True,exist_ok=True)
import argparse
parser = argparse.ArgumentParser()
parser.add_argument('--source-directory', required=True)
src = Path(parser.parse_args().source_directory)
for name,file in {'weapons':'exec-34ae0cd3-8e48-40c5-b91b-c06d1aa9be0a.png','relics':'exec-bdb0d80b-6a87-4ec5-b3e4-73913c7a3e2e.png','effects':'exec-bf6c1b7c-4a14-44c4-ad3b-bda2023705f3.png','rooms':'exec-b5c2de12-4023-4b6b-93ac-4b00f0620d26.png'}.items():shutil.copy2(src/file,dest/(name+'.png'))
def edit(name,old,new):
 p=root/'scripts'/name;s=p.read_text(encoding='utf-8');assert old in s,(name,old[:50]);p.write_text(s.replace(old,new,1),encoding='utf-8')
edit('icon_catalog.gd',' var extra: String=', ' var painted=preload("res://scripts/painterly_assets.gd").weapon(id)\n if painted==null:painted=preload("res://scripts/painterly_assets.gd").relic(id)\n if painted!=null:return painted\n var extra: String=')
edit('weapon_visual.gd',' canvas.draw_set_transform_matrix(transform)\n',' canvas.draw_set_transform_matrix(transform)\n var painted=preload("res://scripts/painterly_assets.gd").weapon(id)\n if painted!=null:\n  var extent: Vector2=Vector2(l+35,(l+35)*.8)\n  var flipped: bool=id in ["tangseng_w0","tangseng_w4","bajie_w0","bajie_w1","bajie_w2","bajie_w3","bajie_w4","shaseng_w0","shaseng_w1","shaseng_w3"]\n  var rect: Rect2=Rect2(Vector2(l+15 if flipped else -20,-extent.y*.5),Vector2(-extent.x if flipped else extent.x,extent.y))\n  canvas.draw_texture_rect(painted,rect,false,tint)\n  canvas.draw_set_transform_matrix(base);return\n')
edit('weapon_visual.gd',' canvas.draw_line(p-d*22,p,Color(col,.24),6,true)',' var role: String="wukong"\n for id in Arts.KITS:\n  if Arts.KITS[id][1]==style:role=id.split("_w")[0];break\n var bitmap=preload("res://scripts/painterly_assets.gd").tile("effects",1,preload("res://scripts/painterly_assets.gd").ROLES.find(role),6,5)\n var object=preload("res://scripts/painterly_assets.gd").weapon(b.get("weapon_id",role+"_w0"))\n preload("res://scripts/painterly_assets.gd").stamp(canvas,bitmap,p-d*12,Vector2(60,36),d.angle(),.75)\n if object!=null:preload("res://scripts/painterly_assets.gd").stamp(canvas,object,p,Vector2(42,34),d.angle()+(.8 if type in ["disc","hook","crescent"] else 0),1)\n return true\n')
# Keep old procedural functions available for comparison, remove them from active rendering.
edit('weapon_visual.gd','static func projectile(canvas:', 'static func projectile(canvas:')
p=root/'scripts/weapon_visual.gd';s=p.read_text();start=s.index(' canvas.draw_line(p-d*22') if ' canvas.draw_line(p-d*22' in s else -1
# The replaced projectile returns early; move its retained fallback into a separate function to avoid unreachable warnings.
needle=' return true\n\n match type:'
if needle in s:s=s.replace(needle,' return true\n\nstatic func legacy_projectile(canvas: CanvasItem,b: Dictionary) -> bool:\n var type: String=b.get("visual","");var p: Vector2=b.pos;var d: Vector2=b.dir;var col=Color("d1c49c")\n match type:',1)
else:
 s=s.replace(' return true\n\n match type:',needle) if False else s
 # Actual file has no blank line before match.
 s=s.replace(' return true\n match type:',' return true\n\nstatic func legacy_projectile(canvas: CanvasItem,b: Dictionary) -> bool:\n var type: String=b.get("visual","");var p: Vector2=b.pos;var d: Vector2=b.dir;var col=Color("d1c49c")\n match type:',1)
s=s.replace('static func effect(canvas:','static func legacy_effect(canvas:',1)
s+='''\nstatic func effect(canvas: CanvasItem,v: Dictionary,reduced: bool=false) -> void:
 var style: String=v.weapon_style;var role: String="wukong";var id: String="wukong_w0"
 for key in Arts.KITS:
  if Arts.KITS[key][1]==style:role=key.split("_w")[0];id=key;break
 var t: float=clampf(1-v.life/v.max,0,1);var r: float=v.radius;var d: Vector2=v.dir;var p: Vector2=v.pos
 var alpha: float=.48 if reduced else .82
 var art=preload("res://scripts/painterly_assets.gd")
 var stage: int=int(v.get("combo",1))
 if style in ["disc","rosary","twin_moon","stars","meteor"]:
  for i in (3 if stage==3 else 2):
   var axis: Vector2=d.rotated((i-.5)*.65+t*.3)
   art.stamp(canvas,art.weapon(id),p+axis*r*.55,Vector2(55,44),axis.angle()+t*TAU,alpha)
   art.burst(canvas,role,p+axis*r*.3,axis,r*.42,t,alpha*.6,1)
 elif style in ["pin","flame","furrow","ice_hammer","sand_seal","lotus_lantern"]:
  for i in (3 if stage==3 else 1):art.burst(canvas,role,p+d*r*(.2+i*.24),d,r*.62,clampf(t-i*.07,0,1),alpha,2)
 elif style in ["dual","shards"]:
  for sign in [-1,1]:art.burst(canvas,role,p+d.orthogonal()*sign*12,d.rotated(sign*.28),r*.8,t,alpha,1)
 else:art.burst(canvas,role,p,d.rotated(-.25 if stage==2 else .16 if stage==3 else 0),r,t,alpha,1 if v.get("shape","")=="thrust" else 0)
'''
p.write_text(s,encoding='utf-8')
edit('role_presentation.gd','func draw_seals(', 'func legacy_draw_seals(')
edit('role_presentation.gd','func draw(canvas:', 'func legacy_draw(canvas:')
p=root/'scripts/role_presentation.gd';p.write_text(p.read_text()+'''\nfunc draw_seals(canvas: CanvasItem,seals: Array,clock: float) -> void:
 for seal in seals:preload("res://scripts/painterly_assets.gd").burst(canvas,"tangseng",seal.pos,Vector2.ZERO,seal.radius,.32+sin(clock)*.04,.38,2)
func draw(canvas: CanvasItem,v: Dictionary,reduced_flash: bool=false) -> void:
 if v.effect=="weapon":preload("res://scripts/weapon_visual.gd").effect(canvas,v,reduced_flash);return
 if v.effect=="ultimate_stage":preload("res://scripts/ultimate_visual.gd").draw(canvas,v,reduced_flash);return
 var t: float=clampf(1-v.life/v.max,0,1)
 var alpha: float=.4 if reduced_flash else .8
 if v.effect=="anticipation":alpha*=.4
 preload("res://scripts/painterly_assets.gd").burst(canvas,v.role,v.pos,v.dir,v.radius,t,alpha,1 if v.effect in ["link","lunge","beam","breath"] else 2 if v.effect in ["shield","guard","sanctuary"] else 0)
''',encoding='utf-8')
edit('ultimate_visual.gd','static func draw(', 'static func legacy_draw(')
p=root/'scripts/ultimate_visual.gd';p.write_text(p.read_text()+'''\nstatic func draw(canvas: CanvasItem,v: Dictionary,reduced: bool=false) -> void:
 var t: float=clampf(1-v.life/v.max,0,1);var role: String=v.get("role","wukong")
 var art=preload("res://scripts/painterly_assets.gd");var r: float=v.radius
 var count: int=3 if reduced else 5
 for i in count:
  var d: Vector2=v.dir.rotated((i-(count-1)*.5)*.38)
  var p: Vector2=v.pos+d*r*(.12+i*.08)
  art.burst(canvas,role,p,d,r*.62,clampf(t-i*.05,0,1),.35 if reduced else .62,i%3)
''',encoding='utf-8')
edit('main.gd','func _draw() -> void:\n if state=="home":return\n var environment: Texture2D=bg','func current_environment() -> Texture2D:\n var environment: Texture2D=bg')
edit('main.gd',' draw_set_transform(camera_offset())\n if is_instance_valid(reward_stage):pass',' return environment\nfunc _draw() -> void:\n if state=="home":return\n var environment: Texture2D=current_environment()\n draw_set_transform(camera_offset())\n if is_instance_valid(reward_stage):pass')
edit('main.gd',' reward_stage.configure(fight,font,fresh);',' reward_stage.environment=current_environment()\n reward_stage.configure(fight,font,fresh);')
p=root/'scripts/reward_room.gd';s=p.read_text(encoding='utf-8');s=s.replace('var typeface: Font','var environment: Texture2D\nvar typeface: Font');s=s.replace('func _draw() -> void:','func legacy_draw() -> void:',1)
s+='''\nfunc _draw() -> void:
 if combat==null:return
 var bounds: Rect2=combat.arena_bounds();var p: Vector2=interaction
 draw_rect(bounds.grow(100),Color("b9b398"))
 if environment!=null:draw_texture_rect(environment,bounds,false,Color(.9,.93,.9))
 var art=preload("res://scripts/painterly_assets.gd")
 var index: int=["shop","shrine","event","rest","reward","forge","curse"].find(room_kind)
 art.stamp(self,art.tile("rooms",index%4,index/4,4,2),p+Vector2(0,-92),Vector2(340,280))
 # The obstacle shapes stay aligned with the three visible supports.
 for i in 3:art.stamp(self,art.tile("rooms",7%4,7/4,4,2),p+Vector2((i-1)*65,-135),Vector2(68,94),0,.7)
 words(TITLES[room_kind],p+Vector2(-90,-250),28,Color("ead6a4"))
 words("走近后按 G / Enter / 手柄确认",p+Vector2(-145,85),16,Color("f3dcb0"))
 var exit: Vector2=combat.exit_position()
 art.stamp(self,art.tile("rooms",3,1,4,2),exit+Vector2(0,-32),Vector2(105,140))
 words("继续西行",exit+Vector2(-35,55),17,Color("f3dcb0"))
''';p.write_text(s,encoding='utf-8')
# Fields use material effects rather than abstract painted circles.
p=root/'scripts/main.gd';s=p.read_text(encoding='utf-8');start=s.index('  for f in fight.fields:\n',s.index('func _draw()'));end=s.index('  role_art.draw_seals',start)
s=s[:start]+'''  for f in fight.fields:
   var field_role: String="bailongma" if f.kind in ["water","wave","waterwall"] else "tangseng" if f.kind in ["sanctuary","lotus","ink"] else "bajie" if f.kind=="rake_wall" else "shaseng"
   preload("res://scripts/painterly_assets.gd").burst(self,field_role,f.pos,Vector2.ZERO,f.radius,.3+sin(clock*2)*.06,.22,2)
'''+s[end:];p.write_text(s,encoding='utf-8')
manifest=root/'assets/manifest.json';m=json.loads(manifest.read_text(encoding='utf-8'));m['painterly_2026_10_09']={'source':'Original built-in image generation; no reference images from third-party games','files':['painterly/'+n+'.png' for n in ['weapons','relics','effects','rooms']],'runtime':'AtlasTexture, transparent bitmap sprites','notes':'AI-assisted artwork; sprite illustrations, not 3D meshes'};manifest.write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding='utf-8')
print('Painterly assets installed in live render paths.')
