extends SceneTree
var scene
var cases: Array=[]
var frame: int=0
var local: int=0
var index: int=0
var running: bool=false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false;scene.storage.base_path="user://stage-two-reel.json";root.add_child(scene);await process_frame;scene.start_demo()
 for role in ["wukong","tangseng","bajie","shaseng","bailongma"]:
  for build in 3:cases.append({"kind":"build","role":role,"build":build,"frames":180})
 for boss in scene.db.tables.bosses:cases.append({"kind":"boss","id":boss.id,"frames":240})
 running=true
func _process(_dt: float) -> bool:
 if not running:return false
 if index>=cases.size():running=false;finish.call_deferred();return false
 var item: Dictionary=cases[index]
 if local==0:
  scene.clear_reward_stage();scene.mode="training";scene.role_demo(item.role if item.kind=="build" else "wukong",item.build if item.kind=="build" else -1)
  scene.demo_control=true;scene.input_release_guard=false;scene.fight.enemies=[];scene.fight.hazards=[];scene.fight.bullets=[];scene.fight.player.pos=scene.fight.arena_bounds().get_center()-Vector2(140,0)
  if item.kind=="build":
   for i in 5:
    var e: Dictionary=scene.fight.spawn("dummy",scene.fight.player.pos+Vector2(100+i*35,(i%2)*70-35),0);e.hp=10000;e.max_hp=10000;e.marks=3
  else:
   var profile: Dictionary=scene.db.find("bosses",item.id)
   var e: Dictionary=scene.fight.spawn("boss",scene.fight.player.pos+Vector2(270,0),0,profile.name)
   e.phase=3;e.hp=e.max_hp*.24;e.followups=preload("res://scripts/boss_tactics.gd").plan(profile.id)[0].duplicate()
   e.boss_cd=.1
   scene.fight.create_layout("boss",profile.biome)
 scene.demo_aim_override=Vector2.RIGHT;scene.demo_movement_override=Vector2.ZERO
 if item.kind=="build":
  scene.fight.invuln=999;scene.fight.player.resource=100
  if local%22==0:scene.input_attack=.12
  if local==85:scene.heavy_buffer=.12;scene.heavy_power=.8;scene.heavy_aim=Vector2.RIGHT
  if local==120:scene.pending_command={"slot":0,"left":.12,"aim":Vector2.RIGHT}
  if local==150:scene.input_dash=.12
 else:
  var path: PackedVector2Array=preload("res://scripts/escape_planner.gd").find(scene.fight,scene.fight.hazards)
  if path.size()>1:scene.demo_movement_override=(path[1]-scene.fight.player.pos).normalized()*.65
  if scene.fight.player.hp<=0:scene.demo_movement_override=Vector2.ZERO
 if local in [60,140]:capture.call_deferred("res://tests/stage-two-"+(item.role+"-"+str(item.build) if item.kind=="build" else item.id)+"-"+str(local)+".png")
 frame+=1;local+=1
 if local>=item.frames:local=0;index+=1
 return false
func capture(path: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(path)
func finish() -> void:
 scene.queue_free();await process_frame;quit()
