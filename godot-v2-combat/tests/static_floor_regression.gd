extends SceneTree
var failures: Array=[]
func _initialize() -> void:call_deferred("run")
func check(value: bool,label: String) -> void:
 if not value:failures.append(label)
func run() -> void:
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://static-floor-regression-only.json";scene.pause_on_focus_loss=false;root.add_child(scene);await process_frame
 scene.set_physics_process(false);scene.start_demo();scene.cinematic.skip();scene.panel.hide();scene.sync_static_floor()
 await process_frame;await process_frame
 var count: int=scene.static_floor.redraw_count
 for i in 12:
  scene.camera_focus+=Vector2(3,1);scene.queue_redraw();await process_frame
 check(scene.static_floor.redraw_count==count,"Camera and live actors must not redraw static ground")
 check(scene.static_floor.position==scene.camera_offset(),"Ground follows camera")
 var original_chapter: int=scene.chapter;scene.chapter=original_chapter+1;scene.sync_static_floor();await process_frame;await process_frame
 check(scene.static_floor.redraw_count==count+1,"Chapter change invalidates ground")
 scene.room_id="static-floor-shop";scene.state="route";scene.options=["shop"];scene.enter_room("shop");scene.cinematic.skip();scene.sync_static_floor()
 await process_frame;await process_frame
 check(not scene.static_floor.visible,"Battle floor hidden in reward room")
 var reward_count: int=scene.reward_stage.static_floor.redraw_count
 for i in 12:scene.reward_stage.queue_redraw();await process_frame
 check(scene.reward_stage.static_floor.redraw_count==reward_count,"Reward floor independent from animated props")
 scene.home();scene.sync_static_floor();check(not scene.static_floor.visible,"Home has no battle ground")
 var report={"failures":failures,"passed":6-failures.size(),"scope":"Retained static commands across camera, chapter, animated reward props and home"}
 var file=FileAccess.open("res://tests/static-floor-regression.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();print(JSON.stringify(report))
 scene.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
