extends SceneTree
var passed: int=0
var failed: int=0
var db=preload("res://scripts/content.gd").new()
const Balance=preload("res://scripts/journey_balance.gd")
const Director=preload("res://scripts/attack_director.gd")
func check(ok: bool,label: String) -> void:
 if ok:passed+=1
 else:failed+=1;push_error(label)
func _initialize() -> void:call_deferred("run")
func fresh(hero: String="wukong"):
 var c=preload("res://scripts/combat.gd").new(db);c.reset(db.find("heroes",hero),db.for_hero("weapons",hero)[0]);c.configure_arena(Vector2(2400,1400));c.player.pos=c.arena_bounds().get_center();return c
func run() -> void:
 for hero in db.tables.heroes:
  var c=fresh(hero.id);var old_damage: float=c.scale_damage(100)
  Balance.activate(c)
  check(c.player.max_hp==floor(hero.hp*.94),"New-run hero vitality "+hero.id)
  check(is_equal_approx(c.scale_damage(100),old_damage*.93),"New-run outgoing damage "+hero.id)
  var resumed=fresh(hero.id);resumed.restore(c.snapshot().duplicate(true))
  check(Balance.enabled(resumed) and resumed.player.max_hp==c.player.max_hp,"Saved profile "+hero.id)
  for tier in [0,12,36]:
   var enemy: Dictionary=c.spawn("chaser",c.player.pos+Vector2(350,0),tier)
   check(is_equal_approx(enemy.hp,(36+tier*4)*Balance.vitality("chaser",tier)),"Enemy vitality curve")
   check(enemy.damage_scale>=1.12 and enemy.damage_scale<=1.35,"Bounded enemy damage")
   c.shoot(enemy.pos,Vector2.LEFT,10,{"friendly":false,"owner":enemy.uid})
   check(is_equal_approx(c.bullets.back().damage,10*enemy.damage_scale),"Projectile damage uses owner tier")
 for chapter in 37:
  check(Balance.population(chapter,chapter,"combat")>=24 and Balance.population(chapter,chapter,"combat")<=48,"Room population bounds")
  check(Balance.active_limit(chapter)<=18 and Balance.interval(chapter,chapter)>=.62,"Fair density cap")
 var native=fresh("bailongma");native.weapon=db.find("weapons","bailongma_w1")
 check(not native.can_take("return"),"Do not offer a redundant return shape on intrinsic-return weapons")
 native.weapon=db.find("weapons","bailongma_w5")
 check(native.can_take("return"),"Return remains available for a nonreturn bow")
 var c=fresh();var boss: Dictionary=c.spawn("boss",c.player.pos+Vector2(300,0),0,db.tables.bosses[0].name)
 c.bosses.begin(c,boss,"fan");boss.warning=0;c.bosses.execute(c,boss)
 var first: Dictionary=c.spawn("guard",c.player.pos+Vector2(180,0),0);first.telegraph=1
 var second: Dictionary=c.spawn("guard",c.player.pos+Vector2(-180,0),0)
 check(not Director.can_begin(c,second),"Boss live shots plus one ordinary block another attack")
 c.die(boss)
 check(not c.bullets.any(func(b):return not b.get("friendly",true) and int(b.get("owner",-1))==boss.uid),"Dead boss clears hostile shots")
 check(Director.can_begin(c,second),"Death releases quota")
 var store=preload("res://scripts/save.gd").new();var path: String="user://reliability-"+str(Time.get_ticks_usec())+".json"
 check(store.write({"meta":{"merit":8}},path),"Write valid data")
 check(not store.write({"meta":{"merit":NAN}},path),"Reject invalid data before replacing files")
 check(store.read(path).get("meta",{}).get("merit",0)==8,"Invalid write preserves main")
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://reliability-scene-"+str(Time.get_ticks_usec())+".json";root.add_child(scene);await process_frame
 scene.set_physics_process(false);scene.set_process(false)
 scene.fight.reset(db.find("heroes","wukong"),db.find("weapons","wukong_w0"))
 scene.hero_id="wukong";scene.skill_ids=["wukong_s0","wukong_s1"];scene.branches=[1,2];scene.kind="shop";scene.state="select";scene.selection_kind="skill";scene.selection_items=["wukong_s2"]
 scene.commit_selection("wukong_s2",1)
 check(scene.skill_ids==["wukong_s0","wukong_s2"] and scene.branches==[1,0],"Replace second skill slot independently")
 scene.kind="shop";scene.bought=[];scene.fight.player.coins=40
 scene.weapon_ids=["wukong_w0","wukong_w1"]
 var preview_snapshot: Dictionary=scene.fight.snapshot().duplicate(true)
 scene.weapon_purchase_preview(22)
 check(scene.fight.player.coins==40 and scene.bought.is_empty(),"Weapon purchase preview does not charge or commit")
 check(JSON.stringify(preview_snapshot)==JSON.stringify(scene.fight.snapshot()),"Weapon comparison does not change combat or its RNG")
 scene.kind="rest";scene.bought=[];scene.fight.player.hp=scene.fight.player.max_hp-20;scene.fight.trial="noheal"
 check(scene.reason("heal",0)=="当前试炼禁止回复","Rest healing explicitly blocked during noheal trial")
 scene.kind="event"
 for event in db.tables.events:
  if event.get("alternative","")=="heal":
   scene.event_id=event.id
   check(scene.reason("event_alternative",0)=="当前试炼禁止回复","Event alternative shares actual healing restriction")
   break
 scene.kind="shrine";scene.chapter=0;scene.enter_reward_stage(false)
 check(is_instance_valid(scene.reward_stage) and scene.reward_stage.z_index<0,"Reward floor stays behind actors")
 scene.queue_free();await process_frame
 print("FINAL_RELIABILITY passed=%d failed=%d"%[passed,failed]);quit(1 if failed else 0)
