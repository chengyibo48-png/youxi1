extends SceneTree
var scene
var frame: int=0
var running: bool=false
var shots: Array=[]
var report: Dictionary={"clips":[],"source":"Actual Main.tscn physics and role combat. Automated input, not human playtest."}
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 scene.storage.base_path="user://role-showcase-only.json";root.add_child(scene)
 await process_frame
 scene.start_demo();running=true
func press(action: String) -> void:
 var event=InputEventAction.new();event.action=action;event.pressed=true;scene._unhandled_input(event)
func _process(_dt: float) -> bool:
 if not running:return false
 var clip: int=int(frame/300)
 if clip>=15:
  var file=FileAccess.open("res://tests/role-showcase.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
  running=false;call_deferred("finish");return false
 var local: int=frame%300;var role: String=["wukong","tangseng","bajie","shaseng","bailongma"][int(clip/3)]
 var build: int=clip%3
 if local==0:
  scene.role_demo(role,build);scene.demo_movement_override=Vector2.ZERO;scene.demo_control=true;scene.demo_aim_override=Vector2.RIGHT
  scene.input_release_guard=false;scene.settings.hold_attack=false
  scene.fight.player.pos=scene.fight.arena_bounds().get_center();scene.fight.enemies=[]
  for offset in [Vector2(80,0),Vector2(180,0),Vector2(250,55),Vector2(-80,0)]:
   var e=scene.fight.spawn("dummy",scene.fight.player.pos+offset,0);e.hp=100000;e.max_hp=100000;e.marks=3
  scene.notify(scene.fight.hero.name+" · "+preload("res://scripts/build_modifier.gd").BUILDS[role][build][0])
  scene.toast_time=11.0
  report.clips.append({"role":role,"build":build,"start_seconds":clip*10,"duration_seconds":10})
 if local<18:scene.demo_movement_override=Vector2.RIGHT*.28
 else:scene.demo_movement_override=Vector2.ZERO
 if local in [20,43,69]:press("attack")
 if local==100:
  scene.charging=true;scene.charge=.9
 if local==115:
  scene.charging=false;scene.heavy_buffer=.12;scene.heavy_power=.9;scene.heavy_aim=Vector2.RIGHT
 if local==149:scene.fight.player.resource=100;press("skill1")
 if local==176:scene.fight.player.resource=100;press("skill2")
 if local==225:scene.fight.player.resource=100;press("ultimate")
 if local==137:
  shots.append({"file":"res://tests/role-"+role+"-"+str(build)+".png"})
  call_deferred("capture")
 frame+=1
 return false
func capture() -> void:
 if shots.is_empty():return
 var output: String=shots.pop_front().file
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(output)
func finish() -> void:
 scene.queue_free();scene=null
 await create_timer(.1).timeout;await process_frame
 quit()
