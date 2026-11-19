extends SceneTree
var scene
var frame: int=0
var running: bool=false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 scene.storage.base_path="user://art-motion-demo-only.json";root.add_child(scene);await process_frame;scene.start_demo();running=true
func press(action: String) -> void:
 var event=InputEventAction.new();event.action=action;event.pressed=true;scene._unhandled_input(event)
func _process(_dt: float) -> bool:
 if not running:return false
 if frame<1500:
  var index: int=frame/300;var local: int=frame%300;var role: String=["wukong","tangseng","bajie","shaseng","bailongma"][index]
  if local==0:
   scene.role_demo(role);scene.fight.enemies=[];scene.demo_control=true;scene.demo_aim_override=Vector2.RIGHT;scene.input_release_guard=false;scene.fight.player.hp=10000
   scene.fight.player.pos=scene.fight.arena_bounds().get_center()-Vector2(180,0)
   for i in 6:
    var e=scene.fight.spawn(["chaser","ranged","charge","guard","summoner","elite"][i],scene.fight.player.pos+Vector2(150+i*45,(i%2)*140-70),0);e.hp=100000;e.max_hp=100000
  scene.demo_movement_override=Vector2.RIGHT if local<65 else Vector2.UP if local<95 else Vector2.ZERO
  if local==66:press("dash")
  if local in [82,110,138]:press("attack")
  if local==190:scene.fight.player.resource=100;press("skill1")
  if local==225:scene.fight.player.resource=100;press("ultimate")
  if local in [45,90,145,240]:capture.call_deferred("res://tests/art-"+role+"-"+str(local)+".png")
 else:
  var index: int=(frame-1500)/90;var local: int=(frame-1500)%90
  if index>=7:running=false;finish.call_deferred();return false
  var kind: String=["shop","shrine","event","rest","reward","forge","curse"][index]
  if local==0:
   scene.cinematics_enabled=true;scene.visited=[];scene.state="route";scene.options=[kind];scene.room_id="art-room-"+kind;scene.enter_room(kind);scene.demo_movement_override=Vector2.RIGHT
  if local==75:scene.demo_movement_override=Vector2.ZERO;capture.call_deferred("res://tests/art-room-"+kind+".png")
 frame+=1;return false
func capture(path: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(path)
func finish() -> void:
 scene.queue_free();await create_timer(.1).timeout;quit()
