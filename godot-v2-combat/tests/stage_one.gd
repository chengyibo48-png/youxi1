extends SceneTree
var passed: int=0
var failed: int=0
func check(value: bool,message: String) -> void:
 if value:passed+=1
 else:failed+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://stage-one-test.json";scene.pause_on_focus_loss=false;root.add_child(scene);await process_frame;scene.start_demo()
 scene.rng.seed=7721
 var before: int=scene.rng.state
 scene.play_sound("swing");scene.play_sound("warning")
 check(scene.rng.state==before,"Audio playback cannot consume gameplay random stream")
 scene.settings.sfx=false;scene.play_sound("swing")
 check(scene.rng.state==before,"Muting audio cannot change gameplay stream")
 var c=scene.fight
 var stats=preload("res://scripts/run_statistics.gd").new()
 c.deaths=7;c.dealt=200;c.damage_sources={"attack":120,"heavy":80}
 stats.commit("chapter:0",c);stats.commit("chapter:0",c)
 check(stats.summary("chapter:0",c).kills==7,"Repeated commit and live summary cannot double count")
 c.deaths=3;c.dealt=50;c.damage_sources={"attack":50}
 var total: Dictionary=stats.summary("chapter:1",c)
 check(total.kills==10 and total.damage==250 and total.sources.attack==170,"Cross-chapter sources accumulate")
 var resumed=preload("res://scripts/run_statistics.gd").new();resumed.restore(stats.snapshot())
 check(resumed.summary("chapter:1",c)==total,"Reload preserves totals without adding twice")
 resumed.restore({},true);check(not resumed.summary("chapter:1",c).complete,"Old unrecorded history identified honestly")
 var label: String="资源不足：需要80点潮势，当前20点"
 var wrapped: String=preload("res://scripts/game_hud.gd").wrap_status(label,scene.font,85,10)
 check(wrapped.replace("\n","")==label,"HUD keeps the complete disabled reason")
 check(not preload("res://scripts/run_statistics.gd").valid({"version":1,"segments":[],"complete":true}),"Malformed statistics rejected before restore")
 scene.mode="campaign";scene.route=[0,1];scene.route_index=0;scene.chapter=0;scene.run_statistics.reset();scene.pending="chapter"
 c.deaths=7;c.dealt=200;c.damage_sources={"attack":200};scene.finish_choice()
 check(c.deaths==0 and scene.run_statistics.summary("chapter:1",c).kills==7,"Real chapter advance preserves run totals while clearing chapter")
 c.deaths=3;c.dealt=50;c.damage_sources={"attack":50};scene.pending="chapter";scene.finish_choice()
 check(scene.state=="ended" and scene.run_statistics.summary("chapter:1",c).kills==10,"Final chapter settlement never counts current chapter twice")
 for weapon in scene.db.tables.weapons:
  var grip: Array=preload("res://scripts/weapon_grips.gd").get_grip(weapon.id)
  if grip[1]<=0 or grip[3]=="bow":continue
  for i in 32:
   var axis: Vector2=Vector2.RIGHT.rotated(i*TAU/32)
   var pose: Dictionary=preload("res://scripts/grip_constraints.gd").solve(Vector2(0,19)+axis*float(grip[1])*.5,axis,float(grip[1]),Vector2(18,7),Vector2(-18,7))
   check(pose.right.distance_to(pose.left)-float(grip[1])<.001,"Rigid shaft keeps hand spacing")
   check(pose.right.distance_to(Vector2(18,7))<36 and pose.left.distance_to(Vector2(-18,7))<36,"Both hands can physically reach grip: "+weapon.id)
 scene.queue_free();await process_frame
 print("STAGE_ONE passed=%d failed=%d"%[passed,failed]);quit(1 if failed else 0)
