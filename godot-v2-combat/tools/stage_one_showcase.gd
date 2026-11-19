extends SceneTree
var scene
var frame: int=0
var running: bool=false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false;scene.storage.base_path="user://stage-one-reel.json"
 root.add_child(scene);await process_frame;scene.start_demo();Engine.time_scale=.65;running=true
func _process(_dt: float) -> bool:
 if not running:return false
 var index: int=frame/240;var local: int=frame%240
 if index>=30:running=false;finish.call_deferred();return false
 var weapon: Dictionary=scene.db.tables.weapons[index]
 if local==0:
  scene.role_demo(weapon.hero);scene.weapon_ids=[weapon.id,weapon.hero+"_w0" if not weapon.id.ends_with("w0") else weapon.hero+"_w1"];scene.slot=0;scene.fight.weapon=weapon;scene.sync_sources();scene.demo_control=true;scene.input_release_guard=false
  scene.fight.enemies=[];scene.fight.obstacles=[];scene.fight.geometry.configure(scene.fight.arena_bounds(),[])
  for i in 4:scene.fight.spawn("dummy",scene.fight.player.pos+Vector2(120+i*40,i%2*60-30),0)
 var directions: Array=[Vector2.DOWN,Vector2.RIGHT,Vector2.UP,Vector2.LEFT]
 scene.demo_movement_override=directions[mini(3,local/12)] if local<48 else Vector2.ZERO
 scene.demo_aim_override=scene.demo_movement_override if local<48 else Vector2.RIGHT
 scene.fight.player.resource=100;scene.fight.invuln=999
 if local in [50,85,120]:scene.input_attack=.12
 if local==160:scene.heavy_buffer=.12;scene.heavy_power=.8;scene.heavy_aim=Vector2.RIGHT
 if local==213:scene.input_dash=.12
 if local==228:
  var event=InputEventAction.new();event.action="switch";event.pressed=true;scene._unhandled_input(event)
 if local in [62,132,183]:capture.call_deferred("res://tests/stage-one-"+weapon.id+"-"+str(local)+".png")
 frame+=1;return false
func capture(path: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(path)
func finish() -> void:
 Engine.time_scale=1;scene.queue_free();await process_frame;quit()
