extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var prefix: String="art-v6"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--prefix="):prefix=arg.trim_prefix("--prefix=").get_file()
 var scene=preload("res://tests/environment_main.gd").new();scene.storage.base_path="user://art-v6-visual-only.json";scene.pause_on_focus_loss=false;scene.cinematics_enabled=false;root.add_child(scene);await process_frame
 scene.set_physics_process(false);scene.start_demo();scene.role_demo("wukong");scene.panel.hide()
 var biomes: Array=["forest","temple","river","ember"]
 if "--all-themes" in OS.get_cmdline_user_args():biomes=["forest","temple","river","ember","desert","snow","city","cave"]
 for biome in biomes:
  var chapter_scene: bool="--chapter-scenes" in OS.get_cmdline_user_args()
  if chapter_scene:scene.chapter={"forest":3,"temple":14,"river":6,"ember":12,"desert":5,"snow":15,"city":11,"cave":10}[biome]
  scene.benchmark_environment=biome;scene.fight.create_layout("combat",biome,scene.chapter if chapter_scene else -1);scene.fight.player.pos=scene.fight.arena_bounds().get_center();scene.fight.enemies=[]
  for i in 3:scene.fight.spawn("guard",scene.fight.player.pos+Vector2(160+i*65,35-i*90),0)
  scene.camera_initialized=false;scene.update_camera(.2);scene.update_hud();scene.queue_redraw();scene.sync_static_floor()
  await process_frame;await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://tests/"+prefix+"-"+biome+"-game.png")
 scene.room_id="art-v6-shop";scene.state="route";scene.options=["shop"];scene.enter_room("shop");scene.cinematic.skip();scene.panel.hide();scene.camera_initialized=false;scene.update_camera(.2);scene.queue_redraw()
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/"+prefix+"-reward-room.png")
 scene.queue_free();await process_frame;quit()
