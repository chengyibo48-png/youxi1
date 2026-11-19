extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://six-point-visual-only.json";scene.pause_on_focus_loss=false;root.add_child(scene);await process_frame
 scene.set_physics_process(false);scene.start_demo();scene.cinematic.skip()
 scene.room_id="six-point-shop";scene.state="route";scene.options=["shop"];scene.enter_room("shop");scene.cinematic.skip()
 scene.fight.player.pos=scene.reward_stage.interaction-Vector2(75,0);scene.camera_initialized=false;scene.update_camera(.2);scene.reward_stage.position=scene.camera_offset()
 scene.fight.player.coins=60;scene.fight.player.hp=scene.fight.player.max_hp-23;scene.fight.player.resource=90;scene.fight.player.shield=145
 scene.stock=["heal","shield","resource","weapon","skill","relic","evolve"];scene.services();scene.update_hud();scene.queue_redraw()
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/six-point-shop-preview.png")
 scene.weapon_purchase_preview(22);scene.update_hud();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/six-point-weapon-preview.png")
 scene.queue_free();await process_frame;quit()
