extends SceneTree
const Prayer=preload("res://scripts/painted_prayer.gd")
const Cast=preload("res://scripts/painted_boss_cast.gd")
func _initialize() -> void:call_deferred("run")
func p95(values: Array) -> float:
 values.sort();return float(values[mini(values.size()-1,int(values.size()*.95))]) if not values.is_empty() else 0.0
func run() -> void:
 root.size=Vector2i(1920,1080);root.content_scale_size=Vector2i(1280,720);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var scene=preload("res://tests/environment_main.gd").new();scene.storage.base_path="user://art-v9-performance-only.json";scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 root.add_child(scene);await process_frame;scene.start_demo();scene.cinematic.skip();scene.demo_control=true
 var results: Array=[]
 for index in 2:
  var role: String="tangseng" if index==0 else "wukong"
  scene.role_demo(role);scene.state="playing";scene.panel.hide();scene.chapter=0 if index==0 else 12;scene.benchmark_environment="forest" if index==0 else "ember"
  var c=scene.fight
  var weapon: String="tangseng_w3" if index==0 else "wukong_w0"
  scene.weapon_ids=[weapon,weapon];c.weapon=scene.db.find("weapons",weapon);scene.sync_sources()
  c.rng.seed=20900+index;c.enemies=[];c.hazards=[];c.bullets=[];c.create_layout("combat",scene.benchmark_environment,scene.chapter)
  for i in 40:
   var enemy=c.spawn("boss" if index==1 and i==0 else "guard",c.player.pos+Vector2(-350+i%10*75,-140+floori(i/10.0)*95),0,"红孩儿" if index==1 and i==0 else "")
   enemy.hp=100000;enemy.max_hp=100000
  scene.update_camera(.2);scene.sync_static_floor();scene.update_hud();scene.queue_redraw()
  await process_frame;await RenderingServer.frame_post_draw
  var previous: int=Time.get_ticks_usec();var start: int=Time.get_ticks_msec()
  var all_frames: Array=[];var combat_frames: Array=[];var cpu_draw: Array=[];var fullbody_frames: int=0
  for frame in 20000:
   c.invuln=999;c.player.resource=100;c.player.hp=c.player.max_hp*.5
   while c.bullets.size()<120:c.shoot(c.player.pos+Vector2(-400+c.rng.randf()*800,-170+c.rng.randf()*340),Vector2.RIGHT.rotated(c.rng.randf()*TAU),1,{"life":20.0,"return":false,"pierce":100,"trigger":false,"role":role})
   if index==0 and frame%120==0:scene.pending_command={"slot":0,"left":.12,"aim":Vector2.DOWN}
   if index==1 and frame%100==0 and c.enemies[0].warning<=0 and c.enemies[0].transition<=0:c.bosses.begin(c,c.enemies[0],"fire")
   var before: float=c.time
   await process_frame;await RenderingServer.frame_post_draw
   var now: int=Time.get_ticks_usec()
   if frame>=40:
    all_frames.append((now-previous)/1000.0);cpu_draw.append(scene.last_draw_ms)
    if c.time>before:combat_frames.append((now-previous)/1000.0)
    if Prayer.weight(role,c.player)>0 or index==1 and Cast.frame_index(c.enemies[0])>=0:fullbody_frames+=1
   previous=now
   if combat_frames.size()>=1200 or Time.get_ticks_msec()-start>45000:break
  results.append({"hero":role,"weapon":weapon,"boss":"红孩儿" if index==1 else "","all_frame_p95_ms":p95(all_frames),"combat_frame_p95_ms":p95(combat_frames),"draw_cpu_p95_ms":p95(cpu_draw),"combat_samples":combat_frames.size(),"fullbody_display_frames":fullbody_frames,"target_met":p95(all_frames)<=16.7 and p95(combat_frames)<=16.7 and combat_frames.size()>=1200 and fullbody_frames>0})
  print("ART_V9_PERF ",JSON.stringify(results[-1]))
 var report={"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"resolution":"1920x1080","enemies":40,"projectiles_minimum":120,"vsync":false,"results":results,"scope":"Two new-art fixtures: stationary rosary prayer and Red Boy side fire. Invulnerability, restored HP/resource and directed casts are pressure fixtures, not normal combat, cold-start or full-campaign acceptance."}
 var file=FileAccess.open("res://tests/art-v9-performance.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
 scene.queue_free();await process_frame;quit()
