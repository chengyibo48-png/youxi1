extends SceneTree
var scene
var frame: int=0
var running: bool=false
var report: Dictionary={"clips":[],"source":"Native Main.tscn with automated input; not a human playtest."}
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 scene.storage.base_path="user://weapon-showcase-only.json";root.add_child(scene);await process_frame;scene.start_demo();running=true
func press(action: String) -> void:
 var event=InputEventAction.new();event.action=action;event.pressed=true;scene._unhandled_input(event)
func setup_targets() -> void:
 scene.fight.enemies=[];scene.fight.player.pos=scene.fight.arena_bounds().get_center();scene.camera_initialized=false
 for offset in [Vector2(70,0),Vector2(140,0),Vector2(230,0),Vector2(90,55),Vector2(90,-55),Vector2(-90,0)]:
  var target=scene.fight.spawn("dummy",scene.fight.player.pos+offset,0);target.hp=100000;target.max_hp=100000;target.marks=3
 scene.demo_control=true;scene.demo_aim_override=Vector2.RIGHT;scene.demo_movement_override=Vector2.ZERO;scene.input_release_guard=false
func _process(_dt: float) -> bool:
 if not running:return false
 if frame<4500:
  var index: int=int(frame/150);var local: int=frame%150;var weapon: Dictionary=scene.db.tables.weapons[index]
  if local==0:
   scene.role_demo(weapon.hero);scene.weapon_ids=[weapon.hero+"_w"+str((int(weapon.id.right(1))+1)%6),weapon.id];scene.slot=0;scene.fight.weapon=scene.db.find("weapons",scene.weapon_ids[0]);setup_targets();scene.switch_cd=0;press("switch");scene.sync_sources()
   report.clips.append({"weapon":weapon.id,"combo":weapon.combo,"start_seconds":index*5,"duration_seconds":5,"actual_switch":scene.fight.weapon.id==weapon.id})
  if local in [10,30,55]:press("attack")
  if local==86:scene.heavy_buffer=.12;scene.heavy_power=1;scene.heavy_aim=Vector2.RIGHT;scene.fight.player.resource=100
  if local in [23,45,70,106]:capture.call_deferred("res://tests/weapon-"+weapon.id+"-"+str(local)+".png")
 elif frame<5400:
  var index: int=int((frame-4500)/180);var local: int=(frame-4500)%180;var role: String=["wukong","tangseng","bajie","shaseng","bailongma"][index]
  if local==0:
   scene.role_demo(role);scene.weapon_ids=[role+"_w5",role+"_w0"];scene.slot=0;scene.fight.weapon=scene.db.find("weapons",scene.weapon_ids[0]);scene.skill_ids=[role+"_s6",role+"_s1"];scene.ultimate_id=role+"_u2";scene.relic_ids=["relic_"+str(18+index),"relic_17"];scene.relic_slot=0;scene.sync_sources();setup_targets();scene.fight.player.hp=scene.fight.player.max_hp*.5
   report.clips.append({"hero":role,"skill":role+"_s6","ultimate":role+"_u2","relic":scene.relic_ids[0],"start_seconds":150+index*6,"duration_seconds":6})
  if local==10:scene.fight.player.resource=100;press("skill1")
  if local==68:scene.fight.player.resource=100;press("ultimate")
  if local==135:
   if index==0:scene.fight.shoot(scene.fight.player.pos,Vector2.RIGHT,10,{"return":true,"weapon_style":"disc","visual":"disc"})
   press("relic")
 else:
  var index: int=int((frame-5400)/90);var local: int=(frame-5400)%90
  if index>=7:
   var file=FileAccess.open("res://tests/weapon-showcase.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();running=false;finish.call_deferred();return false
  var kind: String=["shop","shrine","event","rest","reward","forge","curse"][index]
  if local==0:
   scene.cinematics_enabled=true;scene.visited=[];scene.state="route";scene.options=[kind];scene.room_id="showcase-room-"+kind;scene.enter_room(kind);scene.demo_control=true;scene.demo_movement_override=Vector2.RIGHT
   report.clips.append({"room":kind,"start_seconds":180+index*3,"duration_seconds":3})
  if local==60:scene.demo_movement_override=Vector2.ZERO;scene.fight.player.pos=scene.reward_stage.interaction-Vector2(55,0);press("interact")
 frame+=1;return false
func capture(path: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(path)
func finish() -> void:
 scene.queue_free();await create_timer(.1).timeout;await process_frame;quit()
