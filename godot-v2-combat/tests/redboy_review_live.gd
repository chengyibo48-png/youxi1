extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=preload("res://tests/environment_main.gd").new();scene.storage.base_path="user://redboy-art-review-only.json";scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 root.add_child(scene);await process_frame;scene.set_process(false);scene.set_physics_process(false);scene.start_demo();scene.role_demo("wukong")
 scene.state="playing";scene.panel.hide();scene.settings.sfx=false;scene.chapter=12;scene.benchmark_environment="ember"
 var c=scene.fight;c.create_layout("combat","ember",12);c.enemies=[];c.hazards=[];c.player.pos=c.arena_bounds().get_center();c.invuln=999
 var enemy: Dictionary=c.spawn("boss",c.player.pos+Vector2(280,0),0,"红孩儿")
 if not c.bosses.begin(c,enemy,"fire"):push_error("Red Boy fire did not start");quit(1);return
 var elapsed: float=0
 for index in 3:
  var time: float=[.16,.75,.98][index]
  while elapsed<time:c.update(1.0/60.0,Vector2.ZERO);elapsed+=1.0/60.0
  scene.update_camera(.2);scene.sync_static_floor();scene.update_hud();scene.queue_redraw()
  await process_frame;await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://tests/redboy-v9-live-%d.png"%index)
 print("REDBOY_LIVE poses=3 normal_play_acceptance=false");scene.queue_free();await process_frame;quit()
