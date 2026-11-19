extends RefCounted
const Geometry=preload("res://scripts/action_geometry.gd")
static func start(c,definition: Dictionary,pos: Vector2,damage: float) -> void:
 var a: Dictionary=definition.duplicate(true)
 a.merge({"kind":"attack","clip":"weapon_"+a.get("weapon_style","extend"),"width":18.0,"role":"wukong","sweep_scale":1.0},false)
 a.elapsed=0.0;a.windup=.05;a.active=.18;a.duration=.38;a.previous_tip=pos;a.hits=[]
 var serial: int=int(c.player.get("clone_serial",0))+1;c.player.clone_serial=serial
 var actor: Dictionary={"pos":pos,"weapon_id":a.weapon_id,"facing":a.direction,"action":a.duplicate(true),"pose_clip":a.clip,"attack_combo":a.combo,"hp":1.0,"pose_dt":.016}
 c.visuals.append({"kind":"role_fx","role":"wukong","effect":"clone_replay","replay_id":serial,"melee":a.shape!="seal","actor":actor,"pos":pos,"dir":a.direction,"radius":a.reach,"life":a.duration,"max":a.duration,"color":Color(c.hero.color)})
 if a.shape!="seal" and c.player.delayed.size()<32:c.player.delayed.append({"kind":"clone_melee","replay_id":serial,"left":a.duration,"pos":pos,"action":a,"damage":damage})
static func tick(c,task: Dictionary,dt: float) -> void:
 var a: Dictionary=task.action;var previous: float=a.elapsed;a.elapsed+=dt
 for v in c.visuals:
  if v.get("effect","")=="clone_replay" and v.get("replay_id",-1)==task.replay_id:v.actor.action.elapsed=a.elapsed
 if a.elapsed<a.windup or previous>=a.windup+a.active:return
 var progress: float=clampf((a.elapsed-a.windup)/a.active,0,1)
 var tip: Vector2=Geometry.sample(a,task.pos,progress).tip
 for e in c.enemies.duplicate():
  if e.dead or e.uid in a.hits or not c.geometry.visible(task.pos,e.pos):continue
  var contact: bool=Geometry2D.get_closest_point_to_segment(e.pos,task.pos,tip).distance_to(e.pos)<e.radius+a.width or Geometry2D.get_closest_point_to_segment(e.pos,a.previous_tip,tip).distance_to(e.pos)<e.radius+a.width
  if contact:a.hits.append(e.uid);c.hit(e,task.damage,"分身复招",false,8,a.get("weapon_style","extend"),a.direction)
 a.previous_tip=tip
