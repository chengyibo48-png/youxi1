extends RefCounted
var motion_kit: Resource
var motion_role: String=""
static func attack_movement_factor(hero_id: String) -> float:
 return .30 if hero_id=="bajie" else .45 if hero_id=="tangseng" else .65 if hero_id=="shaseng" else .82
func reset(player: Dictionary) -> void:
 player.foot_contacts={};player.visual_pose_frame=-1;player.erase("visual_pose");player.travel_speed=0.0
 player.recall_charge=0;player.recall_until=0.0
 player.skill_left=0.0;player.skill_hits=[];player.pose_clip="attack";player.velocity=Vector2.ZERO;player.facing=Vector2.RIGHT;player.gait=0.0
 player.attack_left=0.0;player.attack_duration=.2;player.attack_direction=Vector2.RIGHT
 player.attack_heavy=false;player.attack_combo=1;player.action_kind="attack";player.lunge=Vector2.ZERO;player.motion_state="idle"
func commit(player: Dictionary, direction: Vector2, heavy: bool, combo: int, mode: String, interval: float) -> void:
 player.pose_clip="attack"
 player.attack_direction=direction.normalized();player.facing=player.attack_direction
 player.attack_duration=clampf(interval*(1.15 if heavy else .9),.14,.38)
 player.attack_left=player.attack_duration;player.attack_heavy=heavy;player.attack_combo=combo;player.action_kind=mode if mode in ["cast","ultimate"] else "attack"
 if mode=="slash":player.lunge=direction.normalized()*(180 if heavy else 115 if combo==3 else 70)
func step(c, dt: float, movement: Vector2, speed: float, dash_remaining: float) -> void:
 var player: Dictionary=c.player
 player.hurt_left=maxf(0,player.get("hurt_left",0)-dt)
 if not player.has("velocity"):reset(player)
 var target: Vector2=movement.limit_length(1)*speed
 if motion_kit==null or motion_role!=c.hero.id:
  motion_role=c.hero.id;motion_kit=preload("res://scripts/character_combat_kit.gd").for_hero(motion_role)
 var kit: Resource=motion_kit
 var acceleration: float=speed/(kit.braking_time if movement.length()<.05 else kit.acceleration_time)
 if target.dot(player.velocity)<0:acceleration*=1.5
 player.velocity=player.velocity.move_toward(target,acceleration*dt)
 player.attack_left=maxf(0,player.attack_left-dt)
 var movement_factor: float=attack_movement_factor(c.hero.id)
 var desired: Vector2=player.velocity*movement_factor if player.attack_left>0 else player.velocity
 var displacement: Vector2=desired*dt+player.lunge*dt
 player.lunge=player.lunge.move_toward(Vector2.ZERO,1800*dt)
 if dash_remaining>0:
  var dash_delta: float=minf(dt,dash_remaining)
  var before: float=clampf(1-dash_remaining/kit.dash_duration,0,1)
  var after: float=clampf(before+dash_delta/kit.dash_duration,0,1)
  player.dash_pose_phase=after
  var travel: float=(.35*after+.65*smoothstep(0,1,after))-(.35*before+.65*smoothstep(0,1,before))
  displacement=c.dash_direction*kit.dash_speed*kit.dash_duration*travel+player.velocity*(dt-dash_delta)
  player.attack_left=0;player.lunge=Vector2.ZERO
 if player.get("skill_left",0)>0:
  var skill_dt: float=minf(dt,player.skill_left)
  displacement=player.skill_direction*player.skill_speed*skill_dt
  player.skill_left=maxf(0,player.skill_left-dt)
 var previous: Vector2=player.pos
 player.pos=c.geometry.move(player.pos,displacement)
 if movement.length()>.1 and player.attack_left<=0:player.facing=player.facing.slerp(movement.normalized(),minf(1,dt*18)).normalized()
 player.gait+=player.pos.distance_to(previous)*.075
 player.travel_speed=player.pos.distance_to(previous)/maxf(.001,dt)
 player.pose_dt=dt
 preload("res://scripts/foot_contacts.gd").update(player,dt,(player.pos-previous)/maxf(.001,dt))
 player.motion_state="dash" if dash_remaining>0 else "heavy" if player.attack_left>0 and player.attack_heavy else player.get("action_kind","attack") if player.attack_left>0 else "run" if player.velocity.length()>12 else "idle"
