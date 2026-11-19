extends SceneTree
var scene
var frame: int=0
var running: bool=false
var cases: Array=[]
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 scene.storage.base_path="user://rig-chapter-showcase-only.json";root.add_child(scene);await process_frame;scene.start_demo()
 for role in ["wukong","tangseng","bajie","shaseng","bailongma"]:cases.append({"kind":"hero","id":role})
 for boss in scene.db.tables.bosses:cases.append({"kind":"boss","id":boss.id})
 for chapter in [0,4,6,7,12,22,35]:cases.append({"kind":"chapter","id":chapter})
 for room in ["shop","shrine","forge"]:cases.append({"kind":"reward","id":room})
 if "--fire-smoke" in OS.get_cmdline_user_args():cases=cases.filter(func(item):return item.id in ["boss_7","boss_16","boss_23"])
 running=true
func press(action: String) -> void:
 var event=InputEventAction.new();event.action=action;event.pressed=true;scene._unhandled_input(event)
func _process(_dt: float) -> bool:
 if not running:return false
 var index: int=frame/90;var local: int=frame%90
 if index>=cases.size():running=false;finish.call_deferred();return false
 var item: Dictionary=cases[index]
 if local==0:
  scene.clear_reward_stage();scene.mode="training";scene.role_demo(item.id if item.kind=="hero" else "wukong")
  scene.demo_control=true;scene.demo_movement_override=Vector2.ZERO;scene.demo_aim_override=Vector2.RIGHT;scene.input_release_guard=false
  scene.fight.enemies=[];scene.fight.hazards=[];scene.fight.bullets=[];scene.fight.player.pos=scene.fight.arena_bounds().get_center()-Vector2(140,0)
  if item.kind=="boss":
   var profile: Dictionary=scene.db.find("bosses",item.id)
   var enemy: Dictionary=scene.fight.spawn("boss",scene.fight.player.pos+Vector2(250,75),0,profile.name)
   enemy.hp=100000;enemy.max_hp=100000;enemy.boss_cd=999
   scene.fight.create_layout("boss",profile.biome)
   scene.fight.bosses.begin(scene.fight,enemy,profile.signature[0])
  elif item.kind=="chapter":
   scene.mode="campaign";scene.chapter=item.id
   scene.fight.create_layout("battle",scene.db.tables.chapters[item.id].biome,item.id)
   scene.demo_movement_override=Vector2.RIGHT
  elif item.kind=="reward":
   scene.mode="campaign";scene.chapter=6;scene.kind=item.id;scene.enter_reward_stage();scene.demo_movement_override=Vector2.RIGHT
  else:
   var enemy: Dictionary=scene.fight.spawn("guard",scene.fight.player.pos+Vector2(170,0),0);enemy.hp=100000;enemy.max_hp=100000;enemy.cooldown=999;enemy.speed=0
 if item.kind=="hero":
  scene.demo_movement_override=Vector2.RIGHT if local<17 else Vector2.ZERO
  if local in [19,36,53]:press("attack")
  if local==72:scene.fight.skill_cd[0]=0;press("skill1")
 scene.fight.invuln=999;scene.fight.player.resource=100
 if local in [23,40,60]:capture.call_deferred("res://tests/rig-view-"+str(item.id)+"-"+str(local)+".png")
 frame+=1;return false
func capture(path: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(path)
func finish() -> void:
 scene.queue_free();await create_timer(.1).timeout;quit()
