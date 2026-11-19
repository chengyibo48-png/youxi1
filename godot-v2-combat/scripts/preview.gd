extends Control
var spell_art=preload("res://scripts/skill_presentation.gd").new()
var role_art=preload("res://scripts/role_presentation.gd").new()
var rig=preload("res://scripts/layered_rig.gd").new()
const Combat=preload("res://scripts/combat.gd")
var before
var after
var elapsed: float=0
var interval: float=0
var talent: Dictionary={}
var baseline: Array=[]
var skills: Array=[]
var branches: Array=[]
var demonstration_ok: bool=false
var step: int=0
var arena_intervals: Array[float]=[0.0,0.0]
var arena_steps: Array[int]=[0,0]
var arenas: Array=[]
var stimulus_done: bool=false
var recalled: bool=false
var scenario: String="木桩 · 普攻、神通、重击与闪避"
func configure(db, hero: Dictionary, weapon: Dictionary, item: Dictionary, current=null, equipped: Array=[], upgrades: Array=[]) -> void:
 talent=item
 if item.effect in ["regen","heal_power","hero_heal_gain"]:scenario="半血状态 · 对比真实回复速度"
 elif item.effect in ["shield","shield_burst","hero_shield_gain"]:scenario="进房护盾 · 2秒后承受一次20伤害"
 elif item.effect=="kill_heal":scenario="中毒小妖 · 击杀后观察生命回复"
 elif item.effect in ["return","return_damage","return_speed"]:scenario="御器往返 · 3秒后执行召回"
 clip_contents=true
 before=Combat.new(db)
 after=Combat.new(db)
 for c in [before,after]:
  c.reset(hero,weapon)
  if current!=null:
   c.active_effects=current.active_effects.duplicate()
   c.restore(current.snapshot().duplicate(true))
  c.rng.seed=91
 demonstration_ok=after.take(item.id)
 skills=[]
 for id in equipped:skills.append(db.find("skills",id))
 branches=upgrades.duplicate()
 baseline=[before.snapshot().duplicate(true),after.snapshot().duplicate(true)]
 for index in 2:
  var arena=preload("res://scripts/preview_arena.gd").new()
  arena.position=Vector2(12+index*370,44);arena.size=Vector2(350,135);arena.clip_contents=true;arena.mouse_filter=Control.MOUSE_FILTER_IGNORE
  arena.combat=before if index==0 else after;add_child(arena);arenas.append(arena)
 restart()
func restart() -> void:
 for index in 2:
  var c=before if index==0 else after
  c.restore(baseline[index].duplicate(true))
  c.clear_room()
  c.player.pos=Vector2(640,370)
  c.player.hp=c.player.max_hp*.5
  c.player.resource=100
  c.player.shield=minf(150,c.player.shield+c.value("shield")*(1+c.value("hero_shield_gain")))
  if talent.effect=="shield_burst":c.player.shield=12
  c.skill_cd=[0.0,0.0];c.dash_cd=0;c.dash_stock=2
  c.dealt=0
  for i in 4:
   var target=c.spawn("dummy",Vector2(700+i*35,370+(i%2)*20),0)
   target.hp=25 if talent.effect=="kill_heal" else 5000;target.max_hp=target.hp;target.marks=3
   if talent.effect=="kill_heal":target.poison=8
 interval=0
 elapsed=0
 step=0
 arena_intervals=[0.0,0.0];arena_steps=[0,0]
 stimulus_done=false;recalled=false
func _process(dt: float) -> void:
 if before==null:return
 elapsed+=dt
 interval-=dt
 if elapsed>8:restart()
 for c in [before,after]:
  c.update(dt,Vector2.ZERO)
 if elapsed>=2 and not stimulus_done:
  stimulus_done=true
  if talent.effect in ["shield","shield_burst","hero_shield_gain"]:
   for c in [before,after]:c.invuln=0;c.hurt(20,"预览：普通敌人打击")
 if elapsed>=3 and not recalled:
  recalled=true
  if talent.effect in ["return","return_damage","return_speed"]:
   for c in [before,after]:c.recall()
 for index in 2:
  var c=before if index==0 else after
  arena_intervals[index]-=dt
  if arena_intervals[index]<=0 and not c.role.busy(c):
   var action_step: int=arena_steps[index]
   if action_step<skills.size():c.skill(skills[action_step],action_step,Vector2.RIGHT,int(branches[action_step]) if action_step<branches.size() else 0)
   elif action_step==skills.size()+4:c.dash(Vector2.UP)
   else:c.attack(Vector2.RIGHT,action_step==skills.size()+3)
   arena_intervals[index]=.12;arena_steps[index]+=1
 step=arena_steps[0]
 for arena in arenas:arena.queue_redraw()
 queue_redraw()
func _draw() -> void:
 if before==null:return
 for index in 2:
  var origin=Vector2(12+index*370,12)
  var c=before if index==0 else after
  draw_rect(Rect2(origin,Vector2(350,193)),Color("213b36"))
  draw_string(get_theme_default_font(),origin+Vector2(12,22),"选择前" if index==0 else "选择后 · "+talent.name,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("eed49b"))
  draw_string(get_theme_default_font(),origin+Vector2(12,183),"伤害 %.0f · 生命 %.0f · 护盾 %.0f"%[c.dealt,c.player.hp,c.player.shield],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("eed49b"))
 if not demonstration_ok:draw_string(get_theme_default_font(),Vector2(16,216),"此候选已不可选择：请返回候选刷新条件。",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("e8b690"))
 else:draw_string(get_theme_default_font(),Vector2(16,216),scenario,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("31483f"))
