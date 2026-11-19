extends SceneTree
var failures: Array=[]
func _initialize() -> void:call_deferred("run")
func check(condition: bool,label: String) -> void:
 if not condition:failures.append(label);push_error(label)
func run() -> void:
 var db=load("res://scripts/content.gd").new()
 check(db.tables.heroes.size()==5,"five heroes packaged")
 check(db.tables.weapons.size()==30,"30 weapons packaged")
 check(db.tables.bosses.size()==26,"26 bosses packaged")
 check(db.tables.chapters.size()==37,"37 chapters packaged")
 for role in db.tables.heroes:
  var body=load("res://scripts/fullbody_locomotion.gd");check(body.frame_mesh(role.id,3,7).get_surface_count()==1,"body mesh "+role.id)
 for profile in db.tables.bosses:check(not load("res://scripts/boss_choreography.gd").definition(profile.id).is_empty(),"boss choreography "+profile.id)
 for path in ["res://data/fullbody_regions_v11.json","res://data/chapter_lighting_v11.json","res://assets/painterly/regions.json"]:check(FileAccess.file_exists(path),"dynamic JSON "+path)
 for folder in ["tests","tools","build","exports",".git",".publisher"]:check(not DirAccess.dir_exists_absolute("res://"+folder),"excluded "+folder)
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://export-smoke-only.json";root.add_child(scene)
 await process_frame
 scene.start_demo();scene.cinematic.skip();scene.demo_control=true
 for i in 30:await process_frame
 check(scene.fight.player.hp>0,"exported runtime starts gameplay")
 scene.queue_free();await process_frame
 print("EXPORT_PROBE ",JSON.stringify({"failures":failures,"passed":failures.is_empty()}));quit(0 if failures.is_empty() else 1)
