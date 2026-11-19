extends SceneTree
var scene
var frame: int=0
var running: bool=false
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.storage.base_path="user://stage-three-flow-reel.json"
 root.add_child(scene);await process_frame;scene.start_demo();running=true
func _process(_dt: float) -> bool:
 if not running:return false
 if frame>=840:running=false;finish.call_deferred();return false
 if frame in [0,120]:
  scene.mode="training";scene.role_demo("wukong");scene.mode="campaign";scene.chapter=0;scene.route=[0];scene.route_index=0
  scene.step=2 if frame==0 else 4;scene.new_route()
 if frame in [100,220]:scene.enter_room("combat")
 if frame>=240 and (frame-240)%150==0:
  var item: String=["regen","shield","shield_burst","return"][int((frame-240)/150)]
  scene.mode="training";scene.state="playing";scene.role_demo("tangseng",2) if item=="shield_burst" else scene.role_demo("bailongma" if item=="return" else "wukong")
  if item=="return":scene.slot=1;scene.fight.weapon=scene.db.find("weapons","bailongma_w1");scene.sync_sources()
  scene.show_talent_preview(scene.db.find("talents",item))
 if frame in [80,200,370,520,670,820]:capture.call_deferred("res://tests/stage-three-flow-"+str(frame)+".png")
 frame+=1;return false
func capture(path: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(path)
func finish() -> void:
 scene.queue_free();await process_frame;quit()
