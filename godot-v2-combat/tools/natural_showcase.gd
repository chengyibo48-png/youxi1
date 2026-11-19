extends SceneTree
var scene
var frame: int=0
var running: bool=false
var boss_actions: Array=[]
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 scene.storage.base_path="user://natural-showcase-only.json";root.add_child(scene);await process_frame;scene.start_demo()
 boss_actions=preload("res://scripts/boss_controller.gd").TITLES.keys();running=true
func press(action: String) -> void:
 var event=InputEventAction.new();event.action=action;event.pressed=true;scene._unhandled_input(event)
func _process(_dt: float) -> bool:
 if not running:return false
 if frame<4500:
  var index: int=frame/150;var local: int=frame%150;var weapon: Dictionary=scene.db.tables.weapons[index]
  if local==0:
   scene.role_demo(weapon.hero);scene.weapon_ids=[weapon.id,weapon.hero+"_w0"];scene.slot=0;scene.fight.weapon=weapon;scene.sync_sources()
   scene.fight.enemies=[];scene.demo_control=true;scene.demo_aim_override=Vector2.RIGHT;scene.input_release_guard=false
   scene.fight.player.pos=scene.fight.arena_bounds().get_center()-Vector2(160,0)
   for i in 4:
    var e=scene.fight.spawn(["chaser","ranged","guard","elite"][i],scene.fight.player.pos+Vector2(150+i*45,(i%2)*130-65),0);e.hp=100000;e.max_hp=100000
  scene.demo_movement_override=Vector2.RIGHT*.25 if local<22 else Vector2.ZERO;scene.fight.invuln=999;scene.fight.player.resource=100
  if local in [5,28,52]:press("attack")
  if local==78:scene.heavy_buffer=.12;scene.heavy_aim=Vector2.RIGHT;scene.heavy_power=.8
  if local==125:scene.fight.player.action={};scene.fight.player.skill_left=0;scene.fight.skill_cd[0]=0;press("skill1")
  if local in [60,98]:capture.call_deferred("res://tests/natural-"+weapon.id+"-"+str(local)+".png")
 elif frame<4500+boss_actions.size()*110:
  var index: int=(frame-4500)/110;var local: int=(frame-4500)%110;var attack: String=boss_actions[index]
  if local==0:
   scene.role_demo("wukong");scene.fight.enemies=[];scene.fight.hazards=[];scene.fight.bullets=[];scene.demo_control=true;scene.demo_movement_override=Vector2.ZERO
   scene.fight.player.pos=scene.fight.arena_bounds().get_center()-Vector2(150,0);scene.fight.invuln=999
   var profile: Dictionary=scene.db.tables.bosses[0]
   for candidate in scene.db.tables.bosses:
    if attack in candidate.phase_one or attack in candidate.phase_two or attack in candidate.phase_three:profile=candidate;break
   var e=scene.fight.spawn("boss",scene.fight.player.pos+Vector2(270,0),0,profile.name);e.hp=100000;e.max_hp=100000;e.boss_cd=999;e.phase=3
   scene.fight.bosses.begin(scene.fight,e,attack)
  if local in [22,58,95]:capture.call_deferred("res://tests/natural-boss-"+attack+"-"+str(local)+".png")
 else:
  var offset: int=frame-4500-boss_actions.size()*110;var index: int=offset/90;var local: int=offset%90
  if index>=7:running=false;finish.call_deferred();return false
  var kind: String=["shop","shrine","event","rest","reward","forge","curse"][index]
  if local==0:
   scene.chapter=[0,4,8,13,20,28,33][index];scene.mode="campaign";scene.cinematics_enabled=true;scene.visited=[];scene.state="route";scene.options=[kind];scene.room_id="natural-room-"+kind;scene.enter_room(kind);scene.demo_movement_override=Vector2.RIGHT
  if local==75:scene.demo_movement_override=Vector2.ZERO;capture.call_deferred("res://tests/natural-room-"+kind+".png")
 frame+=1;return false
func capture(path: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(path)
func finish() -> void:
 scene.queue_free();await create_timer(.1).timeout;quit()
