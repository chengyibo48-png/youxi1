extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(1920,1080);root.content_scale_size=Vector2i(1280,720)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 scene.storage.base_path="user://role-performance-only.json";root.add_child(scene);await process_frame;scene.start_demo()
 var reports: Array=[]
 for role in ["wukong","tangseng","bajie","shaseng","bailongma"]:
  scene.role_demo(role,1);scene.input_release_guard=false;scene.demo_control=true;scene.demo_aim_override=Vector2.RIGHT;scene.demo_movement_override=Vector2.RIGHT*.1
  var c=scene.fight;c.enemies=[]
  for i in 40:
   var enemy=c.spawn("ranged" if i%3==0 else "guard",c.player.pos+Vector2(-380+i%10*80,-155+floori(i/10.0)*100),0)
   enemy.hp=100000;enemy.max_hp=100000
  var samples: Array=[];var all_samples: Array=[];var previous: int=Time.get_ticks_usec();var simulation_start: float=c.time;var physics_start: int=Engine.get_physics_frames()
  for frame in 800:
   c.invuln=999;c.player.resource=100
   while c.bullets.size()<120:c.shoot(c.player.pos+Vector2(-400+c.rng.randf()*800,-170+c.rng.randf()*340),Vector2.RIGHT.rotated(c.rng.randf()*TAU),1,{"life":20.0,"return":false,"pierce":100,"trigger":false,"role":role,"visual":"bead" if role=="tangseng" else "crescent" if role=="shaseng" else "sword" if role=="bailongma" else ""})
   if frame%20==0:scene.input_attack=.12
   if frame%45==0:c.skill_cd[0]=0;scene.pending_command={"slot":0,"left":.12,"aim":Vector2.RIGHT}
   var combat_before: float=c.time
   await process_frame;await RenderingServer.frame_post_draw
   var now: int=Time.get_ticks_usec()
   if frame>=40:
    all_samples.append((now-previous)/1000.0)
    if c.time>combat_before:samples.append((now-previous)/1000.0)
   previous=now
   if samples.size()>=120:break
  samples.sort();all_samples.sort();reports.append({"hero":role,"physics_frames":Engine.get_physics_frames()-physics_start,"simulation_seconds":c.time-simulation_start,"frame_p95_ms":samples[int(samples.size()*.95)],"all_frame_p95_ms":all_samples[int(all_samples.size()*.95)],"median_ms":samples[int(samples.size()*.5)],"samples":samples.size(),"target_met":samples[int(samples.size()*.95)]<=16.7})
 var report={"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"resolution":"1920x1080","enemies":40,"projectiles_minimum":120,"scene":"Actual Main.tscn physics, AI, input buffers, role rig, role FX, HUD, audio","vsync":false,"roles":reports,"scope":"One arena per role. Full campaign and human readability acceptance remain separate."}
 var file=FileAccess.open("res://tests/role-performance.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();print(JSON.stringify(report))
 scene.queue_free();await create_timer(.2).timeout;await process_frame;quit()
