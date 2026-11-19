extends SceneTree
var failures: Array=[]
var checks: int=0
func check(value: bool,label: String) -> void:
 checks+=1
 if not value:failures.append(label)
func render(scene) -> void:
 scene._process(1.0/60.0);scene.queue_redraw()
 await process_frame;await RenderingServer.frame_post_draw
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://Main.tscn").instantiate()
 scene.storage.base_path="user://visual-motion-freeze-only.json";scene.pause_on_focus_loss=false
 root.add_child(scene);await process_frame
 scene.set_process(false);scene.set_physics_process(false);scene.cinematics_enabled=false;scene.start_demo();scene.cinematic.skip()
 scene.demo_control=true;scene.demo_aim_override=Vector2.RIGHT;scene.demo_movement_override=Vector2.ZERO
 for role in ["wukong","tangseng","bajie","shaseng","bailongma"]:
  scene.role_demo(role);scene.state="playing";scene.panel.hide();scene.fight.enemies=[]
  scene._physics_process(1.0/60.0);await render(scene)
  scene.fight.attack(Vector2.RIGHT);scene._physics_process(1.0/60.0);await render(scene)
  var pose: Array=scene.fight.player.visual_pose.duplicate()
  var time: float=scene.fight.time
  scene.state="paused"
  for i in 4:scene._physics_process(1.0/60.0);await render(scene)
  check(scene.fight.player.visual_pose==pose,role+": pause preserves displayed pose")
  check(scene.fight.time==time,role+": pause preserves combat clock")
  scene.state="playing";scene.hitstop=.01
  scene._physics_process(1.0/60.0);await render(scene)
  check(scene.hitstop==0 and scene.fight.player.visual_pose==pose,role+": final hitstop frame remains frozen")
  check(scene.fight.time==time,role+": hitstop does not advance combat clock")
  scene._physics_process(1.0/60.0);await render(scene)
  check(scene.fight.time>time and scene.fight.player.visual_dt>0,role+": combat and smoothing resume together")
 var report={"checks":checks,"passed":checks-failures.size(),"failures":failures,"scope":"Five roles: pause, final hitstop tick and resumed display pose; not human animation review"}
 var file=FileAccess.open("res://tests/visual-motion-freeze.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();print(JSON.stringify(report))
 scene.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
