extends SceneTree
var passed: int=0
var failed: int=0
func check(value: bool,message: String) -> void:
 if value:passed+=1
 else:failed+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://stage-three-tests.json";scene.pause_on_focus_loss=false;root.add_child(scene);await process_frame
 scene.mode="training"
 for hero in ["wukong","tangseng","bajie","shaseng","bailongma"]:
  for index in 3:
   scene.role_demo(hero,index)
   for id in preload("res://scripts/build_modifier.gd").BUILDS[hero][index][1]:check(scene.fight.owned.has(id),"Preset is executable: "+hero+"/"+id)
 var store=preload("res://scripts/save.gd").new()
 check(not store.write({"meta":{}},"user://nonexistent-stage-three/sub/file.json") and not store.last_error.is_empty(),"Failed storage write exposes the reason")
 var path: String="user://stage-three-recovery.json"
 check(store.write({"meta":{"merit":3}},path),"Initial save")
 check(store.write({"meta":{"merit":8}},path),"Atomic replacement with backup")
 var f=FileAccess.open(path,FileAccess.WRITE);f.store_string("broken");f.close()
 check(store.read(path).get("meta",{}).get("merit",-1)==3,"Recover intact backup when main file is broken")
 scene.mode="short";scene.hero_id="wukong";scene.weapon_ids=["wukong_w0","wukong_w1"];scene.start_run(811)
 var route: Array=scene.route.duplicate();var next_value: int=scene.rng.randi()
 scene.start_run(811);check(scene.route==route and scene.rng.randi()==next_value,"Fixed seed includes initial randomized route")
 var preview=preload("res://scripts/preview.gd").new();scene.add_child(preview)
 preview.configure(scene.db,scene.fight.hero,scene.fight.weapon,scene.db.find("talents","burn"),scene.fight)
 check(preview.demonstration_ok and preview.arenas.size()==2,"Executable comparison preview")
 check(preview.arenas[0].has_method("art_draw_base"),"Material stamps keep the arena transform")
 scene.input_attack=.12;scene.pending_command={"slot":0,"left":.12};Input.action_press("attack")
 scene.on_joy_connection_changed(3,false)
 check(scene.input_attack==0 and scene.pending_command.is_empty() and not Input.is_action_pressed("attack"),"Disconnect clears cached and held controller actions")
 var ambience=preload("res://scripts/soundscape.gd").new()
 var original: int=scene.rng.state;var sound: AudioStreamWAV=ambience.make_stream("river")
 check(sound.loop_mode==AudioStreamWAV.LOOP_FORWARD and sound.data.size()==22050*8*2,"Original ambient loop has full PCM and loop bounds")
 check(scene.rng.state==original,"Ambient synthesis leaves gameplay RNG unchanged")
 ambience.free()
 var route_rng=RandomNumberGenerator.new()
 for seed_value in 20:
  route_rng.seed=seed_value
  for stop in [3,5]:
   var choices: Array=preload("res://scripts/route_flow.gd").choices(stop,scene.NAMES.keys(),route_rng)
   check(choices.size()==3 and choices.has("combat") and choices.all(func(kind):return kind in preload("res://scripts/route_flow.gd").COMBAT_ROOMS),"Two unavoidable encounters preserve different risk choices")
 for chapter in 37:
  var plan: Dictionary=preload("res://scripts/chapter_scenery.gd").composition(chapter)
  check(not plan.is_empty() and not plan.landmarks.is_empty(),"Chapter landmark retained: "+str(chapter))
 scene.queue_free();await process_frame
 print("STAGE_THREE passed=%d failed=%d"%[passed,failed]);quit(1 if failed else 0)
