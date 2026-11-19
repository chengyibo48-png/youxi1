extends Control
var combat
var rig=preload("res://scripts/layered_rig.gd").new()
var role_art=preload("res://scripts/role_presentation.gd").new()
var spell_art=preload("res://scripts/skill_presentation.gd").new()
var material_draw_base: Transform2D=Transform2D.IDENTITY
func art_draw_base() -> Transform2D:return material_draw_base
func _draw() -> void:
 if combat==null:return
 var c=combat
 var transform=Transform2D(0,Vector2.ONE*.43,0,Vector2(120,100)-c.player.pos*.43)
 material_draw_base=transform
 draw_set_transform_matrix(transform)
 for f in c.fields:preload("res://scripts/combat_presentation.gd").field(self,f,c.time)
 role_art.draw_seals(self,c.player.seals,c.time)
 for e in c.enemies:
  if not e.dead:
   if e.kind=="dummy":
    preload("res://scripts/painterly_assets.gd").stamp(self,preload("res://scripts/painterly_assets.gd").tile("rooms",1,0,4,2),e.pos-Vector2(0,30),Vector2(36,60))
   else:preload("res://scripts/enemy_rig.gd").draw(self,e)
   if e.burn>0:draw_arc(e.pos,23,PI,TAU,16,Color("ed9562"),5,true)
   if e.slow>0:draw_arc(e.pos,26,0,TAU,24,Color("8cd1d5"),4,true)
 for b in c.bullets:
  if not role_art.draw_projectile(self,b):draw_line(b.pos-b.dir*18,b.pos,Color("e8c174"),8,true)
 var index: int=["wukong","tangseng","bajie","shaseng","bailongma"].find(c.hero.id)
 for summon in c.summons:
  rig.draw(self,index,c.player,Color(1,1,1,.4),c.time,transform*Transform2D(0,summon.pos),c.hero.id)
 rig.draw(self,index,c.player,Color.WHITE,c.time,transform*Transform2D(0,c.player.pos),c.hero.id)
 draw_set_transform_matrix(transform)
 preload("res://scripts/weapon_effects.gd").action_trail(self,c.player.get("action",{}),c.player.pos)
 for v in c.visuals:
  if v.kind=="role_fx":role_art.draw(self,v)
  elif v.kind=="spell":spell_art.draw(self,v)
  elif v.kind=="material_hit":
   var material: Array=preload("res://scripts/weapon_effects.gd").MATERIALS.get(v.weapon_style,["c7b78d","metal",4,2.0])
   preload("res://scripts/weapon_effects.gd").grains(self,v.pos,v.dir,v.radius,1-v.life/v.max,material,.8)
  elif v.has("pos"):preload("res://scripts/weapon_effects.gd").grains(self,v.pos,Vector2.RIGHT,minf(45,v.get("radius",60)),1-v.life/v.max,["baa47a","dust",5,3.0],.6)
 draw_set_transform(Vector2.ZERO)
