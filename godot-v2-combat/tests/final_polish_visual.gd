extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://role-visual-only.json";scene.pause_on_focus_loss=false
 root.add_child(scene);await process_frame;scene.set_physics_process(false);scene.home()
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/final-polish-home.png")
 scene.start_demo();scene.cinematic.skip();scene.role_lab()
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/final-polish-role-menu.png")
 for hero in scene.db.tables.heroes:
  scene.role_demo(hero.id);scene.input_release_guard=false;scene.fight.player.pos=scene.fight.arena_bounds().get_center();scene.demo_dummies()
  scene.fight.attack(Vector2.RIGHT,true,1)
  scene.fight.update(scene.fight.player.action.windup+.03,Vector2.ZERO)
  scene.update_hud();scene.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://tests/final-polish-role-basic-"+hero.id+".png")
 scene.training_lab();scene.update_hud();scene.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/final-polish-role-skill-picker.png")
 scene.show_settings();scene.settings_tab="display";scene.show_settings();await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/final-polish-role-settings.png")
 scene.settings_tab="audio";scene.show_settings();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/final-polish-role-audio-settings.png")
 scene.build_panel();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/final-polish-role-build-panel.png")
 scene.show_talent_preview(scene.db.find("talents","heavy_line"));await create_timer(3.3).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/final-polish-role-talent-preview.png")
 for type in ["shop","shrine","event","rest","reward","forge","curse"]:
  scene.room_id="visual-"+type;scene.visited=[];scene.state="route";scene.options=[type];scene.enter_room(type);scene.cinematic.skip();scene.fight.player.pos=scene.reward_stage.interaction-Vector2(75,0);scene.camera_initialized=false;scene.update_camera(.2);scene.reward_stage.position=scene.camera_offset();scene.update_hud();scene.queue_redraw()
  await process_frame;await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://tests/final-polish-room-"+type+".png")
 scene.queue_free();await process_frame;quit()

