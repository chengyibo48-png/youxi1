extends RefCounted
const TITLES={"bite":"追击爪击","sweep":"横扫","shot":"瞄准箭","spread":"扇射","volley":"双连射","rush":"冲锋","leap":"跳砸","slam":"重砸","summon":"唤妖","poison":"毒阵"}
const POOLS={"chaser":["bite","sweep"],"ranged":["shot","spread","volley"],"charge":["rush","leap"],"guard":["slam","sweep"],"summoner":["summon","poison"],"elite":["rush","spread","slam","poison"]}
const SKINS={"chaser":[0],"ranged":[2,5],"charge":[4],"guard":[1,6],"summoner":[3,7],"elite":[4,6]}
func configure(c, e: Dictionary) -> void:
 if e.kind not in POOLS:return
 e.name={"chaser":"山野妖卒","ranged":"妖弓斥候","charge":"突阵妖兵","guard":"披甲妖卫","summoner":"唤妖术士","elite":"妖将"}[e.kind]
 e.attack_pool=POOLS[e.kind].duplicate()
 e.attack="";e.last_attack="";e.attack_count=0;e.attack_bag=[]
 e.skin=SKINS[e.kind][c.rng.randi_range(0,SKINS[e.kind].size()-1)]
 e.visual_variant=c.rng.randi_range(0,2);e.body_scale=c.rng.randf_range(.9,1.12)
 e.radius*=e.body_scale
 e.affix=["雷纹","寒甲","毒牙","狂战"][c.rng.randi_range(0,3)] if e.kind=="elite" else ""
 e.rush_time=0.0;e.rush_dir=Vector2.ZERO;e.volley_left=0;e.volley_cd=0.0
 e.speed*=.9+e.body_scale*.1
func choose(c, e: Dictionary) -> String:
 var choices: Array=e.attack_pool.filter(func(action):return action!=e.last_attack)
 if choices.is_empty():choices=e.attack_pool
 var selected: String=choices[c.rng.randi_range(0,choices.size()-1)]
 e.last_attack=selected
 return selected
func begin(c, e: Dictionary, action: String) -> void:
 if not c.visible_bounds.grow(40).has_point(e.pos) or not c.geometry.visible(e.pos,c.player.pos):e.cooldown=.3;return
 if not preload("res://scripts/attack_director.gd").can_begin(c,e) or action=="rush" and c.enemies.any(func(other):return other.get("rush_time",0)>0 or other.get("attack","")=="rush" and other.get("telegraph",0)>0):e.cooldown=.25;return
 e.attack=action;e.target=c.player.pos;e.telegraph=.95 if e.attack_count==0 else .8 if action in ["rush","leap","slam","poison"] else .65
 e.attack_count+=1
 if action in ["slam","sweep","leap","poison"]:
  if action=="leap":e.target=c.geometry.move(e.pos,(e.target-e.pos).limit_length(220),e.radius)
  var center: Vector2=e.target if action in ["leap","poison"] else e.pos
  c.bosses.hazard(c,center,65 if action=="leap" else 75 if action in ["slam","sweep"] else 55,"poison" if action=="poison" else "slam",3 if action=="poison" else .18,8 if action=="poison" else 13,e.telegraph,{"owner":e.uid})
func shoot(c, e: Dictionary, count: int) -> void:
 var direction: Vector2=(e.target-e.pos).normalized()
 for i in count:
  c.shoot(e.pos,direction.rotated((i-(count-1)*.5)*.23),10,{"friendly":false,"trigger":false,"source":e.name,"owner":e.uid,"speed":230.0,"life":3.5,"status":"frost" if e.affix=="寒甲" else "poison" if e.affix=="毒牙" else "","color":Color("9869b3") if e.affix=="雷纹" else Color("b45140")})
func execute(c, e: Dictionary) -> void:
 e.pose_release=.24
 match e.attack:
  "shot":shoot(c,e,1)
  "spread":shoot(c,e,3)
  "volley":shoot(c,e,1);e.volley_left=1;e.volley_cd=.28
  "rush":e.rush_time=.38;e.rush_dir=(e.target-e.pos).normalized()
  "leap":e.pos=c.geometry.move(e.pos,e.target-e.pos,e.radius)
  "bite":
   if e.pos.distance_to(c.player.pos)<75 and c.geometry.visible(e.pos,c.player.pos):c.hurt(10*float(e.get("damage_scale",1)),e.name+"·爪击")
  "summon":
   if c.enemies.size()<40:c.spawn("chaser",c.clamp_actor(e.pos+Vector2(60,0)),int(e.get("tier",0)))
 if e.affix=="雷纹":c.bosses.hazard(c,e.target,38,"slam",.15,9,.8,{"owner":e.uid})
 e.cooldown=1.7 if e.affix=="狂战" else c.rng.randf_range(2.1,3.1)
func interrupt(c, e: Dictionary) -> void:
 e.telegraph=0;e.rush_time=0;e.volley_left=0;e.cooldown=1.3
 c.hazards=c.hazards.filter(func(h):return int(h.get("owner",-1))!=int(e.uid) or h.warn<=0)
func update(c, e: Dictionary, dt: float) -> void:
 if not e.has("attack_pool"):configure(c,e)
 if not e.has("attack_pool"):return
 e.volley_cd-=dt
 if e.volley_left>0 and e.volley_cd<=0:shoot(c,e,1);e.volley_left=0
 if e.rush_time>0:
  var phase: float=clampf(1-e.rush_time/.38,0,1)
  e.rush_time-=dt;e.pos=c.geometry.move(e.pos,e.rush_dir*500*(.4+.6*sin(phase*PI))*dt,e.radius)
  if e.pos.distance_to(c.player.pos)<e.radius+24:c.hurt(14*float(e.get("damage_scale",1)),e.name+"·冲锋")
  return
 if e.telegraph>0:
  if e.attack=="leap" and e.telegraph<=.25:
   e.pos=c.geometry.move(e.pos,(e.target-e.pos).limit_length(900*dt),e.radius)
  e.telegraph=maxf(0,e.telegraph-dt)
  if e.telegraph<=0:execute(c,e)
  return
 var distance: float=e.pos.distance_to(c.player.pos)
 e.cooldown-=dt
 var ranged: bool=e.kind in ["ranged","summoner"]
 if distance>(230 if ranged else 48):c.move_enemy(e,c.player.pos,dt,e.speed*(.4 if e.slow>0 else 1)*(1.5 if c.trial=="fast" else 1))
 elif ranged and distance<150:c.move_enemy(e,c.clamp_actor(e.pos+(e.pos-c.player.pos).normalized()*130,e.radius),dt,e.speed*.75)
 if e.cooldown<=0:
  var action: String=choose(c,e)
  if action in ["bite","sweep","slam"] and distance>100:e.cooldown=.25;return
  begin(c,e,action)
