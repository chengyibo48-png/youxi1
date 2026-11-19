extends SceneTree
var passed: int=0
var failed: int=0
var db=preload("res://scripts/content.gd").new()
const Director=preload("res://scripts/attack_director.gd")
const Planner=preload("res://scripts/escape_planner.gd")
func check(value: bool,message: String) -> void:
 if value:passed+=1
 else:failed+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func fresh():
 var c=preload("res://scripts/combat.gd").new(db);c.reset(db.find("heroes","wukong"),db.find("weapons","wukong_w0"));c.configure_arena(Vector2(2400,1400));c.geometry.configure(c.arena_bounds(),[]);c.player.pos=c.arena_bounds().get_center();return c
func run() -> void:
 var random=RandomNumberGenerator.new();random.seed=420
 var c=fresh();c.owned={"return":1};c.rebuild_effects()
 for i in 100:
  var offered: Array=db.choices("wukong",["melee","projectile","journey_mid","journey_late"],c.owned,[],random)
  check(offered.size()==3 and offered.duplicate().all(func(id):return offered.count(id)==1),"Distinct, full candidate group")
  check(preload("res://scripts/talent_selection.gd").linked(db.find("talents",offered[0]),c.owned),"Related option when available")
  check(not preload("res://scripts/talent_selection.gd").linked(db.find("talents",offered[2]),c.owned),"New direction when available")
 c=fresh()
 var boss: Dictionary=c.spawn("boss",c.player.pos+Vector2(280,0),0,db.tables.bosses[0].name);boss.warning=1
 var first: Dictionary=c.spawn("guard",c.player.pos+Vector2(80,0),0);first.telegraph=1
 var second: Dictionary=c.spawn("guard",c.player.pos+Vector2(-80,0),0)
 check(not Director.can_begin(c,second),"Boss plus one ordinary uses all three slots")
 boss.warning=0;check(Director.can_begin(c,second),"Quota released when windup ends")
 c.hazards=[{"owner":boss.uid,"life":2,"damage":10}];check(not Director.can_begin(c,second),"Persistent boss damage retains quota")
 boss.dead=true;check(Director.can_begin(c,second),"Death releases boss quota")
 c=fresh();var center: Vector2=c.player.pos
 var laser: Dictionary={"pos":center-Vector2(120,0),"end":center+Vector2(250,0),"radius":24,"kind":"laser","warn":.9,"life":.4,"damage":22}
 var path: PackedVector2Array=Planner.find(c,[laser])
 check(path.size()>1 and Planner.valid(c,path,[laser]),"Laser escape has a physically reachable timed route")
 var engulf: Dictionary={"pos":center,"radius":500,"kind":"fire","warn":.1,"life":4,"damage":10}
 check(Planner.find(c,[engulf]).is_empty(),"Do not accept a safe endpoint reached only after damage")
 for profile in db.tables.bosses:
  var plan: Array=preload("res://scripts/boss_tactics.gd").plan(profile.id)
  check(plan[0].size()==3 and plan[0].all(func(action):return action in profile.phase_three),"Authored existing third-phase sequence: "+profile.id)
  c=fresh();var enemy: Dictionary=c.spawn("boss",center+Vector2(280,0),0,profile.name);enemy.phase=3
  for action in plan[0]:
   enemy.warning=0;c.hazards=[];c.bullets=[];c.bosses.begin(c,enemy,action)
   for hazard in c.hazards:
    if hazard.has("escape_route"):check(Planner.valid(c,PackedVector2Array(hazard.escape_route),[hazard]),"Recorded escape route remains valid")
 print("STAGE_TWO passed=%d failed=%d"%[passed,failed]);quit(1 if failed else 0)
