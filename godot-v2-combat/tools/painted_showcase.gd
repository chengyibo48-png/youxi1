extends SceneTree
var scene
var frame: int=0
var local: int=0
var index: int=0
var running: bool=false
var cases: Array=[]
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 scene.storage.base_path="user://painted-showcase-only.json";root.add_child(scene);await process_frame;scene.start_demo()
 for role in ["wukong","tangseng","bajie","shaseng","bailongma"]:cases.append({"kind":"hero","id":role,"frames":180})
 for boss in scene.db.tables.bosses:cases.append({"kind":"boss","id":boss.id,"frames":60})
 for chapter in [0,1,3,4,6,7,19,22]:cases.append({"kind":"chapter","id":chapter,"frames":90})
 for room in ["shop","shrine","forge"]:cases.append({"kind":"reward","id":room,"frames":90})
 if "--smoke" in OS.get_cmdline_user_args():cases=cases.filter(func(c):return c.id in ["wukong","boss_0","boss_13",4])
 running=true
func press(action: String) -> void:
 var event=InputEventAction.new();event.action=action;event.pressed=true;scene._unhandled_input(event)
func _process(_dt: float) -> bool:
 if not running:return false
 if index>=cases.size():running=false;finish.call_deferred();return false
 var item: Dictionary=cases[index]
 if local==0:
  scene.clear_reward_stage();scene.mode="training";scene.role_demo(item.id if item.kind=="hero" else "wukong")
  scene.demo_control=true;scene.demo_movement_override=Vector2.ZERO;scene.demo_aim_override=Vector2.RIGHT;scene.input_release_guard=false
  scene.fight.enemies=[];scene.fight.hazards=[];scene.fight.bullets=[]
  scene.fight.player.pos=scene.fight.arena_bounds().get_center()-Vector2(140,0)
  if item.kind=="boss":
   var profile: Dictionary=scene.db.find("bosses",item.id)
   var enemy: Dictionary=scene.fight.spawn("boss",scene.fight.player.pos+Vector2(250,75),0,profile.name)
   enemy.hp=100000;enemy.max_hp=100000;enemy.boss_cd=999
   scene.fight.create_layout("boss",profile.biome);scene.fight.bosses.begin(scene.fight,enemy,profile.signature[0])
  elif item.kind=="chapter":
   scene.mode="campaign";scene.chapter=item.id
   scene.fight.create_layout("battle",scene.db.tables.chapters[item.id].biome,item.id)
   var plan: Dictionary=preload("res://scripts/chapter_scenery.gd").composition(item.id)
   var landmark: Array=plan.landmarks[0]
   scene.fight.player.pos=scene.fight.arena_origin+Vector2(landmark[0],landmark[1])+Vector2(-190,-140)
   scene.demo_movement_override=Vector2.RIGHT
  elif item.kind=="reward":
   scene.mode="campaign";scene.chapter=6;scene.kind=item.id;scene.enter_reward_stage();scene.demo_movement_override=Vector2.RIGHT
 if item.kind=="hero":
  var directions: Array=[Vector2.DOWN,Vector2.RIGHT,Vector2.UP,Vector2.LEFT]
  scene.demo_movement_override=directions[mini(3,local/22)] if local<88 else Vector2.ZERO
  scene.demo_aim_override=scene.demo_movement_override if local<88 else Vector2.RIGHT
  if local in [96,117,138]:press("attack")
  if local==157:scene.fight.skill_cd[0]=0;press("skill1")
 scene.fight.invuln=999;scene.fight.player.resource=100
 if (item.kind=="hero" and local in [18,40,62,84,125]) or (item.kind!="hero" and local==40):capture.call_deferred("res://tests/painted-view-"+str(item.id)+"-"+str(local)+".png")
 local+=1;frame+=1
 if local>=item.frames:local=0;index+=1
 return false
func capture(path: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(path)
func finish() -> void:
 scene.queue_free();await create_timer(.1).timeout;quit()
