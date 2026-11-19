from pathlib import Path
root=Path(__file__).resolve().parents[1]
def edit(name,old,new):
 p=root/'scripts'/name;s=p.read_text(encoding='utf-8');assert old in s,(name,old[:70]);p.write_text(s.replace(old,new,1),encoding='utf-8')
# Replace the active skill/ultimate billboard paths, retain previous renderers for comparison.
edit('role_presentation.gd','func draw(canvas: CanvasItem,v: Dictionary,reduced_flash: bool=false)','func bitmap_skill_draw(canvas: CanvasItem,v: Dictionary,reduced_flash: bool=false)')
p=root/'scripts/role_presentation.gd';s=p.read_text(encoding='utf-8');start=s.index('func draw_projectile(');end=s.index('\nfunc legacy_draw(',start)
s=s[:start]+'''func draw_projectile(canvas: CanvasItem,shot: Dictionary) -> bool:
 if preload("res://scripts/weapon_visual.gd").projectile(canvas,shot):return true
 if not shot.get("friendly",true):return false
 var W=preload("res://scripts/weapon_effects.gd")
 var color: Color=Color(COLORS.get(shot.get("role","wukong"),"cbb279"))
 var type: String=shot.get("visual","")
 var ids: Dictionary={"crescent":"shaseng_w1","sword":"bailongma_w4","bead":"tangseng_w3"}
 if ids.has(type):preload("res://scripts/painterly_assets.gd").stamp(canvas,preload("res://scripts/painterly_assets.gd").weapon(ids[type]),shot.pos,Vector2(22,13),shot.dir.angle(),.9)
 else:W.shard(canvas,shot.pos,6,shot.dir.angle(),color)
 W.ribbon(canvas,PackedVector2Array([shot.pos-shot.dir*17,shot.pos-shot.dir*8,shot.pos]),1.5,Color(color,.45))
 return true
'''+s[end:]
s+='''\nfunc draw(canvas: CanvasItem,v: Dictionary,reduced_flash: bool=false) -> void:
 if v.effect=="weapon":preload("res://scripts/weapon_effects.gd").effect(canvas,v,reduced_flash)
 elif v.effect=="ultimate_stage":preload("res://scripts/abilities_visual.gd").ultimate(canvas,v,reduced_flash)
 else:preload("res://scripts/abilities_visual.gd").draw(canvas,v,reduced_flash)
''';s=s.replace(' for seal in seals:preload("res://scripts/painterly_assets.gd").burst(canvas,"tangseng",seal.pos,Vector2.ZERO,seal.radius,.32+sin(clock)*.04,.38,2)',' for seal in seals:\n  preload("res://scripts/painterly_assets.gd").stamp(canvas,preload("res://scripts/painterly_assets.gd").relic("relic_13"),seal.pos,Vector2(26,29),sin(clock)*.03,.36)')
p.write_text(s,encoding='utf-8')
p=root/'scripts/main.gd';s=p.read_text(encoding='utf-8');start=s.index('func current_environment()');end=s.index('func _draw()',start)
s=s[:start]+'''func current_biome() -> String:
 if mode=="short":return ["forest","temple","river"][mini(2,route_index)]
 if mode=="training":
  for enemy in fight.enemies:
   if enemy.has("profile"):return enemy.profile.biome
 return db.tables.chapters[chapter].get("biome","wild")
func current_environment() -> Texture2D:
 return preload("res://scripts/journey_scene_art.gd").texture(current_biome())
'''+s[end:]
s=s.replace('if environment!=null:draw_texture_rect(environment,fight.arena_bounds(),false,Color(.9,.93,.9))','if environment!=null:preload("res://scripts/journey_scene_art.gd").floor_art(self,fight.arena_bounds(),environment,current_biome(),chapter)',1)
s=s.replace('if environment!=null:draw_texture_rect(environment,Rect2(0,115,1280,535),false,Color(.9,.93,.9))','if environment!=null:preload("res://scripts/journey_scene_art.gd").floor_art(self,Rect2(0,115,1280,535),environment,current_biome(),chapter)',1)
start=s.index('  for f in fight.fields:',s.index('func _draw()'));end=s.index('  role_art.draw_seals',start)
s=s[:start]+'''  for f in fight.fields:
   var style: String={"fire":"flame","water":"wave_sword","wave":"wave_sword","waterwall":"wave_sword","sanctuary":"lotus_lantern","lotus":"lotus_lantern","ink":"stamp","rake_wall":"rake"}.get(f.kind,"sand_seal")
   var weapon_id: String=f.get("weapon_id","")
   if preload("res://scripts/weapon_arts.gd").KITS.has(weapon_id):style=preload("res://scripts/weapon_arts.gd").KITS[weapon_id][1]
   var field_visual: Dictionary={"weapon_style":style,"weapon_id":weapon_id,"pos":f.pos,"dir":Vector2.RIGHT,"radius":f.radius,"life":.65+.1*sin(fight.time*2),"max":1.0}
   preload("res://scripts/weapon_effects.gd").effect(self,field_visual,not settings.effects)
'''+s[end:]
s=s.replace('preload("res://scripts/painterly_assets.gd").stamp(self,preload("res://scripts/painterly_assets.gd").tile("rooms",3,1,4,2),gate-Vector2(0,30),Vector2(100,125),0,1.0 if fight.player.get("room_cleared",false) else .45)','preload("res://scripts/journey_scene_art.gd").gate(self,gate,fight.player.get("room_cleared",false))\n   preload("res://scripts/journey_scene_art.gd").gate(self,fight.arena_origin+Vector2(110,fight.arena_size.y*.5),true,true)',1)
s=s.replace('if fight.player.shield>0:preload("res://scripts/painterly_assets.gd").burst(self,"tangseng",fight.player.pos,Vector2.ZERO,42,.35,.28,2)','if fight.player.shield>0:preload("res://scripts/painterly_assets.gd").stamp(self,preload("res://scripts/painterly_assets.gd").relic("relic_7"),fight.player.pos-Vector2(0,28),Vector2(38,38),0,.22)',1)
s=s.replace('preload("res://scripts/painterly_assets.gd").burst(self,fight.hero.id,v["from"]+delta*.25,delta.normalized(),delta.length()*.65,1-v.life/v.max,.65,1)','preload("res://scripts/abilities_visual.gd").stream(self,v["from"]-Vector2(0,20),delta.normalized(),delta.length(),1-v.life/v.max,Color("c7bd86",v.life/v.max),1.8)',1)
s=s.replace('else:preload("res://scripts/painterly_assets.gd").burst(self,fight.hero.id,v.pos,Vector2.RIGHT.rotated(v.get("angle",0)),v.get("radius",60),1-v.life/v.max,.55,0)','else:preload("res://scripts/weapon_effects.gd").grains(self,v.pos,Vector2.RIGHT.rotated(v.get("angle",0)),minf(45,v.get("radius",60)),1-v.life/v.max,["baa47a","dust",5,3.0],.6)',1)
s=s.replace('art.stamp(self,art.tile("effects",0,0,6,5),b.pos-b.dir*20,Vector2(60,25),b.dir.angle(),1,Color(1,.35,.25))','preload("res://scripts/enemy_effects.gd").projectile(self,b)',1)
s=s.replace(' reward_stage.environment=current_environment()',' reward_stage.environment=current_environment();reward_stage.biome=current_biome();reward_stage.place=db.tables.chapters[chapter].place;reward_stage.chapter_index=chapter',1)
p.write_text(s,encoding='utf-8')
p=root/'scripts/reward_room.gd';s=p.read_text(encoding='utf-8').replace('var environment: Texture2D','var biome: String="wild"\nvar place: String="西行路"\nvar chapter_index: int=0\nvar environment: Texture2D',1)
s=s.replace('if environment!=null:draw_texture_rect(environment,bounds,false,Color(.9,.93,.9))','if environment!=null:preload("res://scripts/journey_scene_art.gd").floor_art(self,bounds,environment,biome,chapter_index)',1)
s=s.replace('words(TITLES[room_kind],p+Vector2(-90,-210),28,Color("ead6a4"))','preload("res://scripts/journey_scene_art.gd").room_extras(self,room_kind,p,biome,clock)\n words(place+" · "+TITLES[room_kind],p+Vector2(-145,-210),23,Color("ead6a4"))',1)
s=s.replace('art.stamp(self,art.tile("rooms",3,1,4,2),exit+Vector2(0,-32),Vector2(105,140))','preload("res://scripts/journey_scene_art.gd").gate(self,exit)\n preload("res://scripts/journey_scene_art.gd").gate(self,combat.arena_origin+Vector2(120,combat.arena_size.y*.5),true,true)',1)
p.write_text(s,encoding='utf-8')
print('Natural abilities, weapon-specific fields, eight terrain themes and pilgrimage room details connected.')
