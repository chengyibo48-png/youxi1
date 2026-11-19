extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://projectile-culling-only.json";scene.pause_on_focus_loss=false;scene.cinematics_enabled=false;root.add_child(scene);await process_frame
 scene.set_physics_process(false);scene.set_process(false);scene.start_demo();scene.panel.hide();scene.settings.music=false;scene.settings.sfx=false;scene.settings.shake=false;scene.shake=0;scene.fight.enemies=[];scene.fight.visuals=[];scene.fight.bullets=[]
 scene.fight.player.pos=scene.fight.arena_bounds().get_center();scene.camera_initialized=false;scene.update_camera(.2)
 var origin: Vector2=-scene.camera_offset()
 var edges: Array[Vector2]=[Vector2(0,260),Vector2(1280,260),Vector2(640,115),Vector2(640,650)]
 for edge in edges:
  for offset in [-180,-80,-35,0,35,80,180]:
   for role in ["wukong","tangseng","bajie","shaseng","bailongma"]:
    scene.fight.shoot(origin+edge+Vector2(offset,offset*.5),Vector2.LEFT.rotated(offset*.03),1,{"life":20,"role":role,"visual":"bead" if role=="tangseng" else "crescent" if role=="shaseng" else "sword" if role=="bailongma" else "","weapon_style":"meteor" if role=="bajie" else "","friendly":true})
 scene.update_hud()
 var before: String=JSON.stringify(scene.fight.bullets)
 var images: Array[Image]=[]
 for enabled in [false,true]:
  scene.cull_friendly_projectiles=enabled;scene.queue_redraw();await process_frame;await process_frame;await RenderingServer.frame_post_draw
  var image: Image=root.get_texture().get_image();images.append(image);image.save_png("res://tests/projectile-culling-"+("after" if enabled else "before")+".png")
 var differences: int=0;var maximum: float=0
 for y in images[0].get_height():
  for x in images[0].get_width():
   var first: Color=images[0].get_pixel(x,y);var second: Color=images[1].get_pixel(x,y)
   var error: float=maxf(absf(first.r-second.r),maxf(absf(first.g-second.g),absf(first.b-second.b)))
   if error>.001:differences+=1;maximum=maxf(maximum,error)
 var unchanged: bool=before==JSON.stringify(scene.fight.bullets)
 var skipped: int=scene.fight.bullets.filter(func(b):return not scene.projectile_in_view(b)).size()
 var report={"pixel_differences":differences,"maximum_color_difference":maximum,"projectiles_unchanged":unchanged,"projectiles":scene.fight.bullets.size(),"skipped_friendly_draws":skipped,"enemy_warning_culling":false,"passed":differences==0 and unchanged and skipped>0}
 var file=FileAccess.open("res://tests/projectile-culling-visual.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();print(JSON.stringify(report))
 scene.queue_free();await process_frame;quit(0 if report.passed else 1)
