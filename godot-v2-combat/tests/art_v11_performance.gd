extends SceneTree
const Body=preload("res://scripts/fullbody_locomotion.gd")
func _initialize() -> void:call_deferred("run")
func p95(values: Array) -> float:
 values.sort();return float(values[mini(values.size()-1,int(values.size()*.95))]) if not values.is_empty() else 0.0
func run() -> void:
 root.size=Vector2i(1920,1080);root.content_scale_size=Vector2i(1280,720);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var scene=preload("res://tests/environment_main.gd").new();scene.storage.base_path="user://art-v11-performance-only.json";scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 root.add_child(scene);await process_frame;scene.start_demo();scene.cinematic.skip();scene.demo_control=true
 var results: Array=[]
 var roles=["wukong","tangseng","bajie","shaseng","bailongma"]
 var environments=["forest","temple","desert","river","ember"]
 var chapters=[3,7,5,15,12]
 for index in roles.size():
  var role: String=roles[index]
  scene.role_demo(role);scene.state="playing";scene.panel.hide();scene.chapter=chapters[index];scene.benchmark_environment=environments[index]
  var c=scene.fight;var weapon: String=role+"_w0"
  scene.weapon_ids=[weapon,weapon];c.weapon=scene.db.find("weapons",weapon);scene.sync_sources()
  c.rng.seed=21100+index;c.enemies=[];c.hazards=[];c.bullets=[];c.create_layout("combat",scene.benchmark_environment,scene.chapter)
  for i in 40:
   var enemy=c.spawn("boss" if i==0 else "guard",c.player.pos+Vector2(-350+i%10*75,-140+floori(i/10.0)*95),0,"红孩儿" if i==0 else "")
   enemy.hp=100000;enemy.max_hp=100000
  scene.update_camera(.2);scene.sync_static_floor();scene.update_hud();scene.queue_redraw()
  var previous: int=Time.get_ticks_usec();var start: int=Time.get_ticks_msec()
  var all_frames: Array=[];var combat_frames: Array=[];var cpu_draw: Array=[];var cpu_physics: Array=[];var cold_frames: Array=[];var body_frames: int=0
  for frame in 20000:
   c.invuln=999;c.player.resource=100;c.player.hp=c.player.max_hp*.5
   scene.demo_movement_override=Vector2.RIGHT.rotated(frame*.017);scene.demo_aim_override=scene.demo_movement_override
   while c.bullets.size()<120:c.shoot(c.player.pos+Vector2(-400+c.rng.randf()*800,-170+c.rng.randf()*340),Vector2.RIGHT.rotated(c.rng.randf()*TAU),1,{"life":20.0,"return":false,"pierce":100,"trigger":false,"role":role})
   if frame%150==0:scene.input_attack=.12
   var before: float=c.time
   await process_frame;await RenderingServer.frame_post_draw
   var now: int=Time.get_ticks_usec();var elapsed: float=(now-previous)/1000.0
   if frame<40:cold_frames.append(elapsed)
   else:
    all_frames.append(elapsed);cpu_draw.append(scene.last_draw_ms);cpu_physics.append(scene.last_physics_ms)
    if c.time>before:combat_frames.append(elapsed)
    if Body.weight(role,c.player)>0:body_frames+=1
   previous=now
   if combat_frames.size()>=1200 or Time.get_ticks_msec()-start>45000:break
  results.append({"hero":role,"environment":environments[index],"first_40_frame_max_ms":cold_frames.max(),"all_frame_p95_ms":p95(all_frames),"combat_frame_p95_ms":p95(combat_frames),"draw_cpu_p95_ms":p95(cpu_draw),"physics_cpu_p95_ms":p95(cpu_physics),"combat_samples":combat_frames.size(),"fullbody_display_frames":body_frames,"target_met":p95(all_frames)<=16.7 and p95(combat_frames)<=16.7 and combat_frames.size()>=1200 and body_frames>0})
  print("ART_V11_PERF ",JSON.stringify(results[-1]))
 var report={"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"resolution":"1920x1080","enemies":40,"projectiles_minimum":120,"results":results,"scope":"Five sequential moving-role fixtures; first 40 frames measure per-role first use in one process, not independent OS cold launches. Invulnerability, restored resources and high enemy HP are pressure fixtures, not campaign or human acceptance."}
 var file=FileAccess.open("res://tests/art-v11-performance.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
 scene.queue_free();await process_frame;quit()
