extends SceneTree
var db=preload("res://scripts/content.gd").new()
var results: Dictionary={}
func _initialize() -> void:call_deferred("run")
func fresh():
 var c=preload("res://scripts/combat.gd").new(db)
 c.reset(db.find("heroes","bailongma"),db.find("weapons","bailongma_w1"));c.configure_arena(Vector2(2400,1400));c.geometry.configure(c.arena_bounds(),[]);c.player.pos=c.arena_bounds().get_center();return c
func corrupt(path: String) -> void:
 var file=FileAccess.open(path,FileAccess.WRITE);file.store_string("truncated");file.close()
func run() -> void:
 var c=fresh()
 var taken: bool=c.take("nova")
 var target: Dictionary=c.spawn("dummy",c.player.pos+Vector2(80,0),0);target.hp=10;target.max_hp=10;c.rng.seed=11
 c.hit(target,100,"attack",true)
 results.nova={"talent_was_eligible":taken,"actual_damage_recorded":c.dealt,"sources":c.damage_sources,"kills":c.deaths,"negative_statistics":c.dealt<0}
 var stats=preload("res://scripts/run_statistics.gd").new();stats.commit("chapter:0",c)
 results.nova.statistics_snapshot_valid=preload("res://scripts/run_statistics.gd").valid(stats.snapshot())
 c=fresh()
 var boss: Dictionary=c.spawn("boss",c.player.pos+Vector2(280,0),0,db.tables.bosses[0].name)
 c.bosses.begin(c,boss,"fan");boss.warning=0;c.bosses.execute(c,boss)
 results.boss_quota={"live_hostile_projectiles":c.bullets.filter(func(b):return not b.friendly).size(),"quota_after_firing":preload("res://scripts/attack_director.gd").weight(boss,c.hazards)}
 c=fresh()
 var h: Dictionary={"pos":c.player.pos,"radius":45.0,"kind":"slam","warn":0.0,"warning":0.0,"life":.05,"damage":10.0,"tick":0.0}
 var accepted: bool=preload("res://scripts/escape_planner.gd").valid(c,PackedVector2Array([c.player.pos,c.player.pos+Vector2(100,0)]),[h])
 var hp: float=c.player.hp;c.invuln=0;c.hazards=[h];c.bosses.update_hazards(c,.01)
 results.escape_reaction={"planner_accepts_route":accepted,"damage_before_reaction":hp-c.player.hp}
 var store=preload("res://scripts/save.gd").new()
 var path: String="user://audit-backup-"+str(Time.get_ticks_usec())+".json"
 store.write({"meta":{"merit":3}},path);store.write({"meta":{"merit":8}},path);corrupt(path)
 var recovered: Dictionary=store.read(path)
 store.write({"meta":{"merit":9}},path);corrupt(path)
 results.backup={"first_recovered_merit":recovered.get("meta",{}).get("merit",-1),"second_recovery_failed":store.read(path).is_empty(),"scope":"Isolated disposable audit file, not player progress"}
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://audit-services-"+str(Time.get_ticks_usec())+".json";root.add_child(scene);await process_frame
 scene.fight.reset(scene.db.find("heroes","wukong"),scene.db.find("weapons","wukong_w0"));scene.hero_id="wukong";scene.kind="shrine";scene.state="service";scene.stock=["resource"];scene.bought=[];scene.fight.player.resource=100;scene.fight.player.coins=20
 var reason: String=scene.reason("resource",6);scene.buy("resource",6)
 results.full_resource_purchase={"disabled_reason":reason,"resource_after":scene.fight.player.resource,"coins_after":scene.fight.player.coins}
 var encounters: Array=[]
 for event in scene.db.tables.events:
  if event.effect not in ["fight","trial","risk","secret"]:continue
  scene.kind="event";scene.event_id=event.id;scene.state="service";scene.options=[];scene.room_id="audit-"+event.id;scene.bought=[];scene.visited=[]
  scene.fight.player.hp=scene.fight.player.max_hp;scene.fight.player.coins=100
  var initial_hp: float=scene.fight.player.hp
  var blocked: String=scene.reason(event.effect,int(event.cost))
  scene.buy(event.effect,int(event.cost))
  encounters.append({"event":event.id,"action":event.effect,"disabled_reason":blocked,"state_after":scene.state,"kind_after":scene.kind,"spent":100-scene.fight.player.coins,"hp_lost":initial_hp-scene.fight.player.hp,"bought":scene.bought.duplicate(),"enemy_count":scene.fight.enemies.size()})
 results.event_encounters=encounters
 var preview=preload("res://scripts/preview.gd").new();scene.add_child(preview);preview.set_process(false)
 var base=fresh();preview.configure(db,base.hero,base.weapon,db.find("talents","haste"),base)
 var starts: Array=[0,0]
 for frame in 420:
  preview._process(1.0/60)
  for index in 2:
   var arena=preview.before if index==0 else preview.after
   if not arena.player.action.is_empty() and arena.player.action.elapsed==0:starts[index]+=1
 results.haste_preview={"talent_was_eligible":preview.demonstration_ok,"haste_gain":preview.after.value("haste"),"before_action_starts":starts[0],"after_action_starts":starts[1],"duration_seconds":7}
 var sound=preload("res://scripts/soundscape.gd").new();var timings: Dictionary={}
 for theme in ["forest","river","ember"]:
  var start: int=Time.get_ticks_usec();sound.make_stream(theme);timings[theme]=(Time.get_ticks_usec()-start)/1000.0
 results.audio_cold_generation_ms=timings;sound.free()
 scene.queue_free();await process_frame
 var file=FileAccess.open("res://tests/optimization-audit-results.json",FileAccess.WRITE);file.store_string(JSON.stringify(results,"  "));file.close()
 print(JSON.stringify(results));quit()
