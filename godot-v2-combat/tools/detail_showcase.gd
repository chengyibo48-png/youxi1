extends SceneTree
var scene
var frame: int=0
var running: bool=false
const CASES=["wukong_w3","tangseng_w2","shaseng_w4","bailongma_w5","wukong_w0","wukong_w5","ring","fire","shop"]
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 scene.storage.base_path="user://detail-showcase-only.json";root.add_child(scene);await process_frame;scene.start_demo();running=true
func press(action: String) -> void:
 var event=InputEventAction.new();event.action=action;event.pressed=true;scene._unhandled_input(event)
func _process(_dt: float) -> bool:
 if not running:return false
 var index: int=frame/180;var local: int=frame%180
 if index>=CASES.size():running=false;finish.call_deferred();return false
 var item: String=CASES[index]
 if local==0:
  scene.mode="training";scene.role_demo(item.split("_w")[0] if "_w" in item else "wukong")
  scene.demo_control=true;scene.demo_movement_override=Vector2.ZERO;scene.demo_aim_override=Vector2.RIGHT;scene.fight.enemies=[];scene.fight.bullets=[];scene.fight.hazards=[];scene.input_release_guard=false
  scene.fight.player.pos=scene.fight.arena_bounds().get_center()-Vector2(160,0);scene.settings.effects=true
  if "_w" in item:
   scene.weapon_ids=[item,scene.hero_id+"_w0"];scene.slot=0;scene.fight.weapon=scene.db.find("weapons",item);scene.sync_sources()
   var enemy=scene.fight.spawn("guard",scene.fight.player.pos+Vector2(155,0),0);enemy.hp=100000;enemy.max_hp=100000;enemy.speed=0;enemy.cooldown=999
  elif item in ["ring","fire"]:
   var profile: Dictionary=scene.db.tables.bosses[0]
   for candidate in scene.db.tables.bosses:
    if ("roar" if item=="ring" else "fire") in candidate.phase_two or ("roar" if item=="ring" else "fire") in candidate.phase_three:profile=candidate;break
   var enemy=scene.fight.spawn("boss",scene.fight.player.pos+Vector2(270,0),0,profile.name);enemy.hp=100000;enemy.max_hp=100000;enemy.boss_cd=999
   scene.fight.bosses.begin(scene.fight,enemy,"roar" if item=="ring" else "fire")
  else:
   scene.mode="campaign";scene.chapter=4;scene.visited=[];scene.state="route";scene.options=[item];scene.room_id="detail-shop";scene.cinematics_enabled=true;scene.enter_room(item);scene.demo_movement_override=Vector2.RIGHT
 if "_w" in item:
  scene.fight.player.resource=100;scene.fight.invuln=999
  if local in [5,32,59]:press("attack")
  if local==100 and scene.hero_id=="wukong":scene.fight.skill_cd[0]=0;press("skill1")
  if local==94 and item=="wukong_w0":scene.settings.effects=false
 elif item in ["ring","fire"]:scene.fight.invuln=999
 if local in [16,25,33,60,118,136]:capture.call_deferred("res://tests/detail-"+item+"-"+str(local)+".png")
 frame+=1;return false
func capture(path: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(path)
func finish() -> void:
 scene.queue_free();await create_timer(.1).timeout;quit()
