extends SceneTree
var db=preload("res://scripts/content.gd").new()
var failures: Array[String]=[]
var records: Array=[]
var passed: int=0
func _initialize() -> void:call_deferred("run")
func check(ok: bool,label: String) -> void:
 if ok:passed+=1
 else:failures.append(label);push_error(label)
func advance(c,seconds: float) -> void:
 for frame in ceili(seconds*120):c.update(1.0/120,Vector2.ZERO)
func run() -> void:
 for profile in db.tables.bosses:
  var c=preload("res://scripts/combat.gd").new(db)
  c.reset(db.find("heroes","wukong"),db.find("weapons","wukong_w0"));preload("res://scripts/journey_balance.gd").activate(c)
  c.configure_arena(Vector2(1000,600));c.player.pos=c.arena_bounds().get_center();c.rng.seed=872
  var boss: Dictionary=c.spawn("boss",c.player.pos+Vector2(280,0),12,profile.name)
  var transitions: Array=[]
  for stage in [2,3]:
   boss.warning=2;boss.action="fan";boss.charging=.5
   c.shoot(boss.pos,Vector2.LEFT,10,{"friendly":false,"owner":boss.uid,"life":4.0})
   c.hazards.append({"pos":boss.pos,"kind":"fire","radius":30.0,"warn":4.0,"warning":4.0,"life":5.0,"damage":10.0,"tick":0.0,"owner":boss.uid})
   # Cause an actual hit at the threshold, without overriding HP, phase or invulnerability.
   var attack_seed: int=0
   var probe=RandomNumberGenerator.new()
   while true:
    probe.seed=attack_seed
    if probe.randf()>=.08:break
    attack_seed+=1
   c.rng.seed=attack_seed
   var required: float=boss.hp-boss.max_hp*(.49 if stage==2 else .24)
   c.hit(boss,required/c.scale_damage(1),"阶段连续性测试命中",false,0)
   c.update(1.0/120,Vector2.ZERO)
   check(boss.phase==stage and boss.transition>0,profile.id+" actual damage enters phase "+str(stage))
   check(boss.warning==0 and boss.charging==0 and boss.followups.is_empty(),profile.id+" old action stops")
   check(not c.hazards.any(func(h):return int(h.get("owner",-1))==boss.uid),profile.id+" old hazard removed")
   check(not c.bullets.any(func(b):return not b.get("friendly",true) and int(b.get("owner",-1))==boss.uid),profile.id+" old projectile removed")
   var hp: float=boss.hp;var dealt: float=c.dealt
   c.hit(boss,50,"过场中命中",true)
   check(boss.hp==hp and c.dealt==dealt,profile.id+" transition damage/statistics rejected")
   advance(c,.6)
   check(boss.transition>0 and boss.warning==0,profile.id+" no attack halfway through transition")
   advance(c,.7)
   check(boss.transition<=0 and boss.boss_cd>0,profile.id+" preparation window after transition")
   transitions.append({"phase":stage,"hp":boss.hp,"max_hp":boss.max_hp,"post_transition_recovery":boss.boss_cd})
  records.append({"boss":profile.id,"transitions":transitions})
  await process_frame
 var file=FileAccess.open("res://tests/boss-phase-continuity.json",FileAccess.WRITE)
 file.store_string(JSON.stringify({"passed":passed,"failures":failures,"records":records,"scope":"26 normal-profile bosses, actual scripted threshold damage and live combat clock; action cancellation, danger cleanup, transition immunity and recovery. Not full normal play or human fairness/visual acceptance."},"  "));file.close()
 print("BOSS_PHASE_CONTINUITY passed=%d failed=%d"%[passed,failures.size()]);quit(1 if not failures.is_empty() else 0)
