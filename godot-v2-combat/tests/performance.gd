extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(1920,1080)
 root.content_scale_size=Vector2i(1280,720)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var scene=load("res://Main.tscn").instantiate()
 scene.pause_on_focus_loss=false
 scene.storage.base_path="user://performance-only.json"
 root.add_child(scene)
 await process_frame
 scene.mode="training";scene.start_run();scene.set_physics_process(false)
 var c=scene.fight
 for id in ["split","chain","return","burn","frost","pierce","fan","crit","cast_echo"]:
  if c.can_take(id):c.take(id)
 c.clear_room()
 c.create_layout("combat","forest")
 c.player.pos=c.arena_bounds().get_center()
 for i in 40:
  var enemy=c.spawn("ranged" if i%5==0 else "guard",c.player.pos+Vector2(-460+i%10*100,-155+floori(i/10.0)*95),0)
  enemy.hp=100000;enemy.max_hp=100000
 var samples: Array=[]
 var cpu: Array=[]
 var previous: int=Time.get_ticks_usec()
 for frame in 420:
  c.invuln=999
  while c.bullets.size()<120:c.shoot(c.player.pos+Vector2(-450+c.rng.randf()*900,-190+c.rng.randf()*380),Vector2.RIGHT.rotated(c.rng.randf()*TAU),1,{"life":20.0,"return":false,"pierce":100,"trigger":false})
  if frame%10==0:
   for effect in ["beam","freeze","pull","sanctuary"]:c.presentation.emit(c,effect,c.player.pos+Vector2(c.rng.randf_range(-180,180),0),Vector2.RIGHT,150,.65)
  c.player.velocity=Vector2(140,0);c.player.gait+=.12
  var begin=Time.get_ticks_usec()
  c.update(1.0/60,Vector2.ZERO)
  scene.queue_redraw()
  var elapsed=(Time.get_ticks_usec()-begin)/1000.0
  await process_frame
  await RenderingServer.frame_post_draw
  var now=Time.get_ticks_usec()
  if frame>60:samples.append((now-previous)/1000.0);cpu.append(elapsed)
  previous=now
 samples.sort();cpu.sort()
 var report={"resolution":"1920x1080","renderer":"gl_compatibility","gpu":RenderingServer.get_video_adapter_name(),"cpu":OS.get_processor_name(),"enemies":40,"sound_pool":16,"music_enabled":true,"projectiles":120,"obstacles":c.obstacles.size(),"frames":samples.size(),"vsync":false,"frame_p95_ms":samples[int(samples.size()*.95)],"simulation_p95_ms":cpu[int(cpu.size()*.95)],"frame_median_ms":samples[int(samples.size()*.5)],"scope":"Development build, one scene with walking skin mesh and layered spell effects. Not full campaign acceptance."}
 var output=FileAccess.open("res://tests/performance.json",FileAccess.WRITE)
 output.store_string(JSON.stringify(report,"  "));output.close()
 print(JSON.stringify(report))
 scene.queue_free();await create_timer(.25).timeout;await process_frame;quit()
