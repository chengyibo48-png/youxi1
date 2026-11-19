extends SceneTree
var scene
var cases: Array=[]
var local: int=0
var index: int=0
var running: bool=false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false;scene.storage.base_path="user://stage-three-reel.json"
 root.add_child(scene);await process_frame;scene.start_demo()
 for chapter in 37:cases.append({"kind":"chapter","id":chapter,"frames":60})
 for room in ["shop","shrine","event","rest","reward","forge","curse"]:cases.append({"kind":"room","id":room,"frames":90})
 for talent in ["regen","shield","shield_burst","return"]:cases.append({"kind":"preview","id":talent,"frames":150})
 if "--previews" in OS.get_cmdline_user_args():cases=cases.filter(func(item):return item.kind=="preview")
 running=true
func _process(_dt: float) -> bool:
 if not running:return false
 if index>=cases.size():running=false;finish.call_deferred();return false
 var item: Dictionary=cases[index]
 if local==0:
  scene.panel.hide();scene.clear_reward_stage();scene.mode="training";scene.state="playing";scene.role_demo("wukong");scene.chapter=0
  scene.demo_control=true;scene.input_release_guard=false;scene.demo_movement_override=Vector2.ZERO;scene.demo_aim_override=Vector2.RIGHT
  scene.fight.enemies=[];scene.fight.hazards=[];scene.fight.bullets=[]
  if item.kind=="chapter":
   scene.chapter=item.id;scene.fight.create_layout("battle",scene.db.tables.chapters[item.id].biome,item.id)
   var plan: Dictionary=preload("res://scripts/chapter_scenery.gd").composition(item.id)
   var landmark: Array=plan.landmarks[0]
   scene.fight.player.pos=scene.fight.arena_origin+Vector2(landmark[0],landmark[1])+Vector2(-190,-90);scene.camera_initialized=false;scene.update_camera(.2)
   scene.demo_movement_override=Vector2.RIGHT*.4
  elif item.kind=="room":
   scene.chapter=25;scene.kind=item.id;scene.enter_reward_stage();scene.demo_control=true;scene.input_release_guard=false;scene.demo_movement_override=Vector2.RIGHT*.4
  else:
   if item.id=="shield_burst":scene.role_demo("tangseng",2)
   elif item.id=="return":scene.role_demo("bailongma");scene.slot=1;scene.fight.weapon=scene.db.find("weapons","bailongma_w1");scene.sync_sources()
   scene.show_talent_preview(scene.db.find("talents",item.id))
 if local==item.frames-15:capture.call_deferred("res://tests/stage-three-"+item.kind+"-"+str(item.id)+".png")
 local+=1
 if local>=item.frames:index+=1;local=0
 return false
func capture(path: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(path)
func finish() -> void:
 scene.queue_free();await process_frame;quit()
