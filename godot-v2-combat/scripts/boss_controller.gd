extends RefCounted
const TITLES={"charge":"扑阵冲锋","slam":"重砸震地","fan":"妖风扇射","wave":"寒潮来袭","burst":"八方妖弹","fire":"三昧火域","ice":"封路冰阵","poison":"尾针毒雾","web":"盘丝缚地","laser":"金光破阵","gourd":"摄魂吸引","gust":"芭蕉烈风","illusion":"真假幻身","mirror":"双身夹攻","blink":"隐身移形","fog":"山雾伏击","roar":"震山声浪","summon":"唤妖援阵","ward":"护身收兵"}
func configure(c, e: Dictionary) -> void:
 for profile in c.content.tables.get("bosses",[]):
  if profile.name!=e.name:continue
  e.profile=profile
  e.sequence=0;e.boss_cd=1.5;e.action="";e.warning=0.0;e.ward=0.0;e.charging=0.0;e.charge_dir=Vector2.ZERO
  e.form_variant=c.rng.randi_range(0,2);e.form=["凌厉","镇守","狡诈"][e.form_variant]
  e.deck=[];e.followups=[];e.last_action="";e.exposed=0.0;e.transition=0.0
  e.body_scale=c.rng.randf_range(.96,1.08)
  e.boss_skin={"tiger":0,"bear":1,"fire":2,"bone":3,"bull":4,"horn":4,"bird":5,"brow":6,"rhino":7}.get(profile.type,-1)
  return
func hazard(c, center: Vector2, radius: float, kind: String, life: float=1, damage: float=18, warning: float=.95, extra: Dictionary={}) -> void:
 if c.hazards.size()>=24:return
 var h={"pos":c.clamp_actor(center,55),"radius":radius,"kind":kind,"life":life,"warn":warning,"warning":warning,"damage":damage,"tick":0.0}
 h.merge(extra,true)
 if kind=="laser":
  var contact: Dictionary=c.geometry.trace(h.pos,h.end,radius)
  if not contact.is_empty():h.end=contact.pos
 if kind not in ["summon","blink","fog"]:
  var path: PackedVector2Array=preload("res://scripts/escape_planner.gd").find(c,c.hazards+[h])
  if path.is_empty():return
  h.escape_route=Array(path)
 c.hazards.append(h)
func begin(c, e: Dictionary, action: String) -> bool:
 if not preload("res://scripts/attack_director.gd").can_begin(c,e):e.boss_cd=.25;return false
 e.exposed=0
 e.action=action;e.target=c.player.pos;e.warning=maxf(.8,e.profile.warning*(.95 if e.form_variant==0 else 1.1 if e.form_variant==1 else 1))
 e.pose_windup=e.warning;e.pose_release=0.0;e.cast_released=false
 if action in ["charge","fan","wave","burst"]:
  var planned: Array=[];var virtual: Array=[]
  if action=="charge":planned.append({"pos":e.pos,"end":c.geometry.move(e.pos,(e.target-e.pos).normalized()*375,e.radius),"kind":"laser","radius":40.0,"warn":e.warning,"life":.5,"damage":22})
  else:
   for direction in projectile_directions(e):virtual.append({"pos":e.pos,"dir":direction,"speed":200.0 if action=="wave" else 240.0,"radius":7,"life":e.warning+3.5,"delay":e.warning,"friendly":false})
  if preload("res://scripts/escape_planner.gd").find(c,c.hazards+planned,virtual).is_empty():
   e.warning=0;e.action="";e.boss_cd=.4;return false
 var center: Vector2=c.player.pos
 var hazard_start: int=c.hazards.size()
 match action:
  "slam":hazard(c,e.pos,130,"slam",.18,23,e.warning)
  "fire","ice","poison","web":
   for i in (4 if e.phase>=2 else 3):hazard(c,center+Vector2.RIGHT.rotated(i*TAU/(4 if e.phase>=2 else 3))*70,55,action,4,10 if action!="web" else 0,e.warning)
  "laser":hazard(c,e.pos,24,"laser",.4,22,e.warning,{"end":center})
  "roar":
   hazard(c,e.pos,170,"ring",.25,24,e.warning)
   if e.phase>=2:hazard(c,e.pos,280,"ring",.25,24,e.warning+.35)
  "gourd":hazard(c,e.pos,235,"pull",4,8,e.warning)
  "gust":hazard(c,center,160,"gust",3,3,e.warning,{"force":(center-e.pos).normalized()})
  "fog":hazard(c,center,150,"fog",4,0,e.warning)
  "summon","illusion","mirror":
   for i in (3 if e.phase>=2 else 2):hazard(c,e.pos+Vector2.RIGHT.rotated(i*TAU/3)*150,26,"summon",.05,0,e.warning,{"enemy_kind":"charge" if action=="mirror" else "ranged" if action=="illusion" else e.profile.summons})
  "blink":hazard(c,center+Vector2(160,0),60,"blink",.2,15,e.warning,{"boss_uid":e.uid})
 for index in range(hazard_start,c.hazards.size()):c.hazards[index].owner=e.uid
 if action in ["slam","fire","ice","poison","web","laser","roar","gourd","gust"] and c.hazards.size()==hazard_start:
  e.warning=0;e.action="";e.boss_cd=.4
  return false
 c.feedback.emit("warning",e.pos,0)
 return true
func projectile_directions(e: Dictionary) -> Array[Vector2]:
 var count: int=10 if e.action=="burst" and e.phase==3 else 8 if e.action=="burst" else 9 if e.phase==3 else 7 if e.phase==2 else 5
 var direction: Vector2=(e.target-e.pos).normalized()
 var result: Array[Vector2]=[]
 for i in count:result.append(Vector2.RIGHT.rotated(i*TAU/count) if e.action=="burst" else direction.rotated((i-(count-1)*.5)*.23))
 return result
func execute(c, e: Dictionary) -> void:
 e.cast_released=true
 match e.action:
  "charge":e.charging=.5;e.charge_dir=(e.target-e.pos).normalized()
  "fan","wave","burst":
   for aim in projectile_directions(e):
    c.shoot(e.pos,aim,13,{"friendly":false,"trigger":false,"visual":e.action,"source":e.name+"·"+TITLES[e.action],"owner":e.uid,"return":false,"homing":false,"pierce":0,"bounce":0,"speed":200.0 if e.action=="wave" else 240.0,"life":3.5,"status":"frost" if e.action=="wave" else "","color":Color("b64f42")})
  "ward":e.ward=5
 if e.charging>0:return
 finish_action(e)
func finish_action(e: Dictionary) -> void:
 var tactic: Array=preload("res://scripts/boss_tactics.gd").plan(e.profile.id)
 if not e.followups.is_empty():e.boss_cd=float(tactic[1])
 else:
  e.exposed=float(tactic[2]) if e.action in ["slam","roar","laser","charge"] else float(tactic[2])*.75
  e.boss_cd=maxf(1.4,e.profile.recovery*(.9 if e.phase==3 else 1))
func interrupt(c, e: Dictionary) -> void:
 e.cast_released=false
 e.warning=0;e.charging=0;e.followups=[];e.ward=0;e.action=""
 e.exposed=e.stagger;e.boss_cd=1.4
 c.hazards=c.hazards.filter(func(h):return int(h.get("owner",-1))!=int(e.uid) or h.warn<=0)
func choose(c, e: Dictionary) -> String:
 if not e.followups.is_empty():return e.followups.pop_front()
 if e.phase>=2 and int(e.sequence)%4==3:
  e.followups=preload("res://scripts/boss_tactics.gd").plan(e.profile.id)[0].duplicate() if e.phase==3 else e.profile.signature.duplicate()
  return e.followups.pop_front()
 var moves: Array=e.profile.phase_three if e.phase==3 else e.profile.phase_two if e.phase==2 else e.profile.phase_one
 var valid: Array=moves.filter(func(move):return move!=e.last_action)
 if valid.is_empty():valid=moves
 if e.pos.distance_to(c.player.pos)>260 and "charge" in valid:return "charge"
 return valid[c.rng.randi_range(0,valid.size()-1)]
func update(c, e: Dictionary, dt: float) -> void:
 if e.stagger>0 or e.root>0:return
 var phase: int=3 if e.hp<=e.max_hp*.25 else 2 if e.hp<=e.max_hp*.5 else 1
 if phase>e.phase:
  e.cast_released=false
  e.phase=phase;e.sequence=0;e.deck=[];e.followups=[];e.warning=0;e.charging=0;e.transition=1.2;e.boss_cd=1.2;e.exposed=0
  c.hazards=c.hazards.filter(func(h):return int(h.get("owner",-1))!=int(e.uid))
  c.bullets=c.bullets.filter(func(b):return b.get("friendly",true) or int(b.get("owner",-1))!=int(e.uid))
  c.invuln=maxf(c.invuln,1.2)
  c.feedback.emit("phase",e.pos,phase)
 if e.transition>0:return
 if e.charging>0:
  var travel: float=minf(dt,e.charging)
  var before: float=clampf(1-e.charging/.5,0,1)
  var after: float=clampf(before+travel/.5,0,1)
  var fraction: float=(.35*after+.65*smoothstep(0,1,after))-(.35*before+.65*smoothstep(0,1,before))
  e.charging=maxf(0,e.charging-dt);e.pos=c.geometry.move(e.pos,e.charge_dir*375*fraction,e.radius)
  if e.pos.distance_to(c.player.pos)<60:c.hurt(22*float(e.get("damage_scale",1)),e.name+"·冲锋")
  if e.charging<=0:finish_action(e)
  return
 if e.warning>0:
  e.warning-=dt
  if e.warning<=0:execute(c,e)
  return
 e.boss_cd-=dt
 if e.boss_cd<=0:
  if not preload("res://scripts/attack_director.gd").can_begin(c,e):e.boss_cd=.25;return
  if not c.visible_bounds.grow(100).has_point(e.pos):c.move_enemy(e,c.player.pos,dt,95);return
  var queued: Array=e.followups.duplicate()
  var action: String=choose(c,e)
  if action=="slam" and e.pos.distance_to(c.player.pos)>190:
   e.followups=queued;c.move_enemy(e,c.player.pos,dt,95);return
  if begin(c,e,action):e.sequence+=1;e.last_action=action
  else:e.followups=queued
  return
 var delta: Vector2=c.player.pos-e.pos
 if delta.length()>200:c.move_enemy(e,c.player.pos,dt,65)
 if delta.length()<60:c.hurt(12*float(e.get("damage_scale",1)),e.name)
func update_hazards(c, dt: float) -> void:
 for h in c.hazards:
  if h.has("owner") and not c.enemies.any(func(enemy):return not enemy.dead and int(enemy.uid)==int(h.owner)):h.life=0;continue
  if h.warn>0:h.warn=maxf(0,h.warn-dt);continue
  h.life-=dt;h.tick-=dt
  if h.kind=="summon":
   var owner_tier: int=0
   for owner in c.enemies:
    if int(owner.uid)==int(h.get("owner",-1)):owner_tier=int(owner.get("tier",0));break
   if c.enemies.size()<40:c.spawn(h.enemy_kind,h.pos,owner_tier)
   h.life=0;continue
  if h.kind=="blink":
   for e in c.enemies:
    if e.uid==h.boss_uid:e.pos=h.pos
   h.kind="slam"
  var distance: float=c.player.pos.distance_to(h.pos)
  var inside: bool=hazard_contains(h,c.player.pos)
  if inside and (h.kind!="laser" or c.geometry.visible(h.pos,c.player.pos)):
   if h.kind in ["ice","web","fog"]:c.player.slow=.5
   if h.kind=="pull":c.player.pos=c.geometry.move(c.player.pos,(h.pos-c.player.pos).normalized()*minf(120*dt,c.player.pos.distance_to(h.pos)))
   if h.kind=="gust":c.player.pos=c.geometry.move(c.player.pos,h.force*140*dt)
   if h.tick<=0 and h.damage>0:
    c.hurt(h.damage*preload("res://scripts/journey_balance.gd").damage_multiplier(c,int(h.get("owner",-1))),TITLES.get(h.kind,"妖阵"),"element_dot" if h.kind in ["fire","poison","ice"] else "");h.tick=.7
    if h.kind=="poison":c.player.poison=3
    if h.kind=="fire":c.player.burn=2
 c.hazards=c.hazards.filter(func(h):return h.life>0)
static func hazard_contains(h: Dictionary,point: Vector2) -> bool:
 if h.kind=="ring":return absf(point.distance_to(h.pos)-h.radius)<28
 if h.kind=="laser":return point.distance_to(Geometry2D.get_closest_point_to_segment(point,h.pos,h.end))<h.radius
 return point.distance_to(h.pos)<h.radius
