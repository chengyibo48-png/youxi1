extends SceneTree
# Real legal equipment/prerequisites; observations are not visual/human certification.
var db=preload("res://scripts/content.gd").new()
var records: Array=[]
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("run")
func prerequisite(c,id: String,seen: Array=[]) -> bool:
 if id in seen:return false
 if c.owned.has(id):return true
 var t: Dictionary=db.find("talents",id)
 if t.is_empty():return false
 var chain: Array=seen+[id]
 for parent in t.get("requires",[]):
  if not prerequisite(c,parent,chain):return false
 var alternatives: Array=t.get("requires_any",[])
 if not alternatives.is_empty() and not alternatives.any(func(parent):return c.owned.has(parent)):
  var satisfied: bool=false
  for parent in alternatives:
   if prerequisite(c,parent,chain):satisfied=true;break
  if not satisfied:return false
 if t.get("needs_shield",false) and "shield_source" not in c.tags() and not c.owned.has("shield"):
  if not c.take("shield"):return false
 return c.take(id)
func context(t: Dictionary) -> Dictionary:
 for hero in db.tables.heroes:
  if t.hero!="" and t.hero!=hero.id:continue
  var skills: Array=db.for_hero("skills",hero.id)
  for weapon in db.for_hero("weapons",hero.id):
   for first in skills.size():
    for second in range(first+1,skills.size()):
     for ultimate in db.for_hero("ultimates",hero.id):
      var c=preload("res://scripts/combat.gd").new(db);c.reset(hero,weapon);c.active_effects=[skills[first].effect,skills[second].effect,ultimate.effect]
      if prerequisite(c,t.id):
       c.owned.erase(t.id);c.rebuild_effects()
       return {"combat":c,"skills":[skills[first],skills[second]],"ultimate":ultimate}
 return {}
func observe(c,equipment: Dictionary) -> Dictionary:
 c.configure_arena(Vector2(2400,1400));c.player.pos=c.arena_bounds().get_center();c.rng.seed=438;c.player.resource=100;c.player.hp=c.player.max_hp*.5;c.player.shield+=25
 for offset in [Vector2(80,0),Vector2(130,30),Vector2(190,-30),Vector2(260,0)]:
  var target: Dictionary=c.spawn("dummy",c.player.pos+offset,0);target.hp=1000;target.max_hp=1000;target.marks=3;target.root=.4
 var attacks: int=0
 var peak_control: float=0
 var peak_visuals: int=0
 for frame in 360:
  if frame==90:c.invuln=0;c.hurt(40,"修行审核：盾破/受击")
  if frame==120 or frame==240:c.skill(equipment.skills[0 if frame==120 else 1],0 if frame==120 else 1,Vector2.RIGHT)
  if not c.role.busy(c) and c.dash_time<=0:
   if frame>180 and frame<210:c.dash(Vector2.UP)
   elif c.attack(Vector2.RIGHT,attacks%4==3):attacks+=1
  c.update(1.0/60,Vector2.ZERO)
  var control: float=0
  for enemy in c.enemies:control+=enemy.slow+enemy.root+enemy.burn+enemy.poison
  peak_control=maxf(peak_control,control);peak_visuals=maxi(peak_visuals,c.visuals.size())
 # Separate deterministic lethal-hit fixture: economy/kill recovery need actual deaths.
 c.player.resource=25
 for enemy in c.enemies.duplicate():
  if enemy.dead:continue
  enemy.hp=1;enemy.poison=1;enemy.burn=1;enemy.root=1;c.hit(enemy,10,"attack",true)
 var coins_dropped: int=0
 for drop in c.loot:coins_dropped+=int(drop.coins)
 var states: Array=[]
 for enemy in c.enemies:states.append({"hp":enemy.hp,"slow":enemy.slow,"root":enemy.root,"marks":enemy.marks,"burn":enemy.burn,"poison":enemy.poison})
 return {"damage":c.dealt,"sources":c.damage_sources.duplicate(),"hp":c.player.hp,"max_hp":c.player.max_hp,"shield":c.player.shield,"resource":c.player.resource,"attacks":attacks,"bullets":c.bullets.size(),"fields":c.fields.size(),"summons":c.summons.size(),"marks":states,"kills":c.deaths,"xp":c.player.xp,"coins_dropped":coins_dropped,"cooldowns":c.skill_cd.duplicate(),"peak_control":peak_control,"peak_visuals":peak_visuals}
func run() -> void:
 for t in db.tables.talents:
  var setup: Dictionary=context(t)
  if setup.is_empty():failures.append("No legal equipment/prerequisites: "+t.id);records.append({"id":t.id,"status":"无合法测试配装"});continue
  var c=setup.combat
  var initial: Dictionary=c.snapshot().duplicate(true)
  var before: Dictionary=observe(c,setup)
  var levels: Array=[]
  for level in range(1,int(t.max_level)+1):
   c.reset(c.hero,c.weapon);c.restore(initial.duplicate(true))
   var accepted: bool=true
   for upgrade in level:
    if not c.take(t.id):accepted=false
   if not accepted:failures.append("Upgrade rejected: "+t.id+"/"+str(level))
   var parameter: float=c.value(t.effect)
   var active: bool=c.owns(t.id)
   var saturated: bool=not c.can_take(t.id) if level==int(t.max_level) else false
   var after: Dictionary=observe(c,setup)
   if c.dealt<0 or not is_finite(c.dealt):failures.append("Invalid damage: "+t.id)
   levels.append({"level":level,"accepted":accepted,"active":active,"effect_parameter":parameter,"max_level_blocked":saturated,"observation":after,"observed_change":JSON.stringify(before)!=JSON.stringify(after)})
  records.append({"id":t.id,"name":t.name,"description":t.description,"hero":c.hero.id,"weapon":c.weapon.id,"skills":setup.skills.map(func(s):return s.id),"ultimate":setup.ultimate.id,"prerequisites":initial.owned,"baseline":before,"levels":levels,"status":"已跑合法配装及升级；机制、代价和视觉仍需专项核对","visual_review":"未验收","human_tradeoff_review":"未验收"})
  if records.size()%8==0:await process_frame
 var file=FileAccess.open("res://tests/talent-runtime-matrix.json",FileAccess.WRITE)
 file.store_string(JSON.stringify({"count":records.size(),"failures":failures,"scope":"Six-second legal-loadout runtime observations plus explicit lethal-hit fixture (1 HP, poison/burn/frozen targets, resource reset to 25); zero observed change requires a specialized trigger, not a claim that all talents are complete.","talents":records},"  "));file.close()
 print("TALENT_RUNTIME_MATRIX count=%d failures=%d"%[records.size(),failures.size()]);print(failures)
 quit(1 if not failures.is_empty() else 0)
