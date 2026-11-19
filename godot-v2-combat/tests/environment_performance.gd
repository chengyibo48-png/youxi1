extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(1920,1080);root.content_scale_size=Vector2i(1280,720)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var scene=preload("res://tests/environment_main.gd").new();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 scene.storage.base_path="user://environment-performance-only.json";root.add_child(scene);await process_frame;scene.start_demo()
 var reports: Array=[]
 var boss_mode: bool="--boss-rigs" in OS.get_cmdline_user_args()
 var definitions: Array=[]
 for hero in scene.db.tables.heroes:
  for environment in ["forest","river","ember"]:
   var entry: Dictionary=scene.db.find("weapons",hero.id+"_w0").duplicate(true)
   entry.benchmark_biome=environment;definitions.append(entry)
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--hero="):definitions=definitions.filter(func(d):return d.hero==arg.trim_prefix("--hero="))
 var benchmark_case: int=0
 var sample_target: int=1200 if "--long" in OS.get_cmdline_user_args() else 180
 var focus: String=""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--focus-boss="):focus=arg.trim_prefix("--focus-boss=")
 if boss_mode and not focus.is_empty():
  benchmark_case=definitions.find(scene.db.find("bosses",focus))
  definitions=definitions.filter(func(d):return d.id==focus)
 for definition in definitions:
  print("PERF START ",definition.id," ",definition.benchmark_biome)
  var scene_start: int=Time.get_ticks_usec()
  var role: String="wukong" if boss_mode else definition.hero
  var weapon: Dictionary=scene.db.find("weapons",role+"_w0") if boss_mode else definition
  scene.role_demo(role);scene.weapon_ids=[weapon.id,role+"_w0"];scene.slot=0;scene.fight.weapon=weapon;scene.skill_ids=[role+"_s6",role+"_s1"];scene.ultimate_id=role+"_u2";scene.sync_sources()
  for talent in ["fan","split","chain","burn","frost","combo_anchor","combo_ink"]:
   if scene.fight.can_take(talent):scene.fight.take(talent)
  scene.input_release_guard=false;scene.input_release_guard=false;scene.demo_control=true;scene.demo_aim_override=Vector2.RIGHT;scene.demo_movement_override=Vector2.RIGHT*.1
  var c=scene.fight;c.enemies=[]
  scene.benchmark_environment=definition.benchmark_biome
  c.create_layout("combat",definition.benchmark_biome)
  if is_instance_valid(scene.soundscape):scene.soundscape.update_mix(.1,definition.benchmark_biome,0,true,.65)
  await process_frame;await RenderingServer.frame_post_draw
  var first_scene_frame_ms: float=(Time.get_ticks_usec()-scene_start)/1000.0
  c.rng.seed=10000+benchmark_case;benchmark_case+=1
  if boss_mode:c.create_layout("boss",definition.biome)
  for i in 40:
   var enemy=c.spawn("boss" if boss_mode and i==0 else "ranged" if i%3==0 else "guard",c.player.pos+Vector2(-380+i%10*80,-155+floori(i/10.0)*100),0,definition.name if boss_mode and i==0 else "")
   enemy.hp=100000;enemy.max_hp=100000
   if boss_mode and i==0:enemy.hp=40000;enemy.phase=2;c.bosses.begin(c,enemy,definition.signature[0])
  var samples: Array=[];var all_samples: Array=[];var previous: int=Time.get_ticks_usec();var simulation_start: float=c.time;var physics_start: int=Engine.get_physics_frames()
  var cpu_physics: Array=[];var cpu_draw: Array=[]
  var case_wall_start: int=Time.get_ticks_msec()
  for frame in 36000:
   c.invuln=999;c.player.resource=100
   while c.bullets.size()<120:c.shoot(c.player.pos+Vector2(-400+c.rng.randf()*800,-170+c.rng.randf()*340),Vector2.RIGHT.rotated(c.rng.randf()*TAU),1,{"life":20.0,"return":false,"pierce":100,"trigger":false,"role":role,"visual":"bead" if role=="tangseng" else "crescent" if role=="shaseng" else "sword" if role=="bailongma" else ""})
   if frame%20==0:scene.input_attack=.12
   if frame%90==0:scene.heavy_buffer=.12;scene.heavy_aim=Vector2.RIGHT;scene.heavy_power=1
   if frame%45==0:c.skill_cd[0]=0;scene.pending_command={"slot":0,"left":.12,"aim":Vector2.RIGHT}
   var combat_before: float=c.time
   await process_frame;await RenderingServer.frame_post_draw
   var now: int=Time.get_ticks_usec()
   if frame>=40:
    cpu_physics.append(scene.last_physics_ms);cpu_draw.append(scene.last_draw_ms)
    all_samples.append((now-previous)/1000.0)
    if c.time>combat_before:samples.append((now-previous)/1000.0)
   previous=now
   if samples.size()>=sample_target or Time.get_ticks_msec()-case_wall_start>45000:break
  if samples.is_empty():push_error("No advancing battle samples");quit(1);return
  samples.sort();all_samples.sort();reports.append({"hero":role,"weapon":definition.id,"physics_frames":Engine.get_physics_frames()-physics_start,"simulation_seconds":c.time-simulation_start,"frame_p95_ms":samples[int(samples.size()*.95)],"all_frame_p95_ms":all_samples[int(all_samples.size()*.95)],"median_ms":samples[int(samples.size()*.5)],"samples":samples.size(),"target_met":samples[int(samples.size()*.95)]<=16.7 and all_samples[int(all_samples.size()*.95)]<=16.7})
  if boss_mode:reports[-1].boss_id=definition.id;reports[-1].weapon=weapon.id
  reports[-1].environment=definition.benchmark_biome
  reports[-1].first_scene_frame_ms=first_scene_frame_ms
  cpu_physics.sort();cpu_draw.sort()
  reports[-1].physics_cpu_p95_ms=cpu_physics[int(cpu_physics.size()*.95)]
  reports[-1].draw_command_cpu_p95_ms=cpu_draw[int(cpu_draw.size()*.95)]
  reports[-1].rng_seed=str(c.rng.seed)
  reports[-1].static_floor_redraws=scene.static_floor.redraw_count
  reports[-1].sample_target_reached=samples.size()>=sample_target
  print("PERF DONE ",definition.id," ",definition.benchmark_biome," all=",reports[-1].all_frame_p95_ms," battle=",reports[-1].frame_p95_ms)
 var report={"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"resolution":"1920x1080","enemies":40,"projectiles_minimum":120,"scene":"Actual Main.tscn physics, AI, input buffers, role rig, role FX, HUD, audio","vsync":false,"roles":reports,"scope":"One arena per weapon across thirty weapons. Full campaign and human readability acceptance remain separate."}
 if boss_mode:report.scope="26 separate boss arenas, one phase-two boss plus 39 ordinary enemies and at least 120 projectiles. Brief samples do not cover all moves or full campaign."
 if not focus.is_empty():report.scope="Single targeted phase-two boss, same original case RNG seed, plus 39 ordinary enemies and at least 120 projectiles; not a repeat of all 26 arenas."
 var output: String="res://tests/boss-painted-focus.json" if not focus.is_empty() else "res://tests/boss-rig-performance.json" if boss_mode else "res://tests/weapon-performance.json"
 output="res://tests/environment-performance.json"
 if "--diagnostic" in OS.get_cmdline_user_args():output="res://tests/environment-performance-diagnostic.json"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--output="):output="res://tests/"+arg.trim_prefix("--output=").get_file()
 report.scope="%d room-change cases across selected heroes in forest, river and ember. First scene frame includes setup and render wait; later cases may reuse cached assets. Stress invulnerability is a performance fixture, not normal combat acceptance."%reports.size()
 report.friendly_projectile_draw_culling=scene.cull_friendly_projectiles
 report.sample_target=sample_target
 var file=FileAccess.open(output,FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();print(JSON.stringify(report))
 scene.queue_free();await create_timer(.2).timeout;await process_frame;quit()

