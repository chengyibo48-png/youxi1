extends SceneTree
var passed: int=0
var failed: int=0
var db=preload("res://scripts/content.gd").new()
func check(value: bool,message: String) -> void:
 if value:passed+=1
 else:failed+=1;push_error(message)
func fresh(role: String,weapon: String=""):
 var c=preload("res://scripts/combat.gd").new(db)
 c.reset(db.find("heroes",role),db.find("weapons",role+"_w0" if weapon=="" else weapon))
 c.configure_arena(Vector2(2400,1400));c.player.pos=c.arena_bounds().get_center();c.obstacles=[];c.geometry.configure(c.arena_bounds(),[])
 return c
func payload(c,effect: String,branch: int=1) -> void:
 var definition: Dictionary={"effect":effect,"branch":branch}
 c.role.skill_payload(c,{"definition":definition,"direction":Vector2.RIGHT,"heavy":false,"combo":1,"kind":"skill"})
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var c=fresh("bajie");c.player.shield=0;payload(c,"shield")
 check(is_equal_approx(c.player.shield,33.75),"Condensed rake guard grants 35% more shield")
 c=fresh("tangseng");c.player.hp=c.player.max_hp-30;payload(c,"heal")
 for task in c.player.delayed:task.left=0
 c.role.tick(c,.001,Vector2.ZERO)
 check(is_equal_approx(c.player.hp,c.player.max_hp-9.75),"Five condensed chant ticks heal 20.25, rather than unmodified 15")
 c=fresh("tangseng");payload(c,"counter")
 check(is_equal_approx(c.player.parry_until-c.time,1.08),"Condensed counter extends the actual parry window")
 c=fresh("shaseng");var target: Dictionary=c.spawn("chaser",c.player.pos+Vector2(100,0),0);target.marks=2;payload(c,"root")
 check(is_equal_approx(target.root,1.755),"Condensed sand bind extends actual control duration")
 c=fresh("bailongma");c.player.shield=0;payload(c,"waterwall")
 check(is_equal_approx(c.player.shield,8.1),"Condensed water curtain improves shield")
 c=fresh("wukong");payload(c,"mark");target=c.spawn("chaser",c.player.pos+Vector2(100,0),0);payload(c,"mark")
 check(is_equal_approx(target.mark,9.45),"Condensed weak-point mark lasts longer")
 c=fresh("wukong","wukong_w5")
 c.role.clone_attack(c,{"action":{"weapon_style":"disc","weapon_id":"wukong_w5","direction":Vector2.RIGHT,"damage":20.0,"reach":280.0,"shape":"seal","combo":1,"heavy":false},"pos":c.player.pos})
 check(c.bullets.size()==2 and c.bullets.all(func(b):return b["return"] and not b.trigger and b.source=="分身复招"),"Cloned ring attack returns two rings with nonrecursive ownership")
 check(c.player.delayed.is_empty(),"A cloned ring cannot spawn another clone")
 c=fresh("wukong","wukong_w1")
 target=c.spawn("chaser",c.player.pos+Vector2(75,0),0);target.hp=1000;target.max_hp=1000
 c.role.clone_attack(c,{"action":{"weapon_style":"pin","weapon_id":"wukong_w1","direction":Vector2.RIGHT,"damage":20.0,"reach":320.0,"shape":"seal","combo":1,"heavy":false},"pos":c.player.pos})
 check(target.hp==1000 and c.player.delayed.size()==2,"Cloned pillar retains delay rather than doing an immediate generic slash")
 for task in c.player.delayed:task.left=0
 c.role.tick(c,.001,Vector2.ZERO)
 check(target.hp<1000 and c.player.delayed.is_empty(),"Cloned delayed pillars resolve and do not recurse")
 c=fresh("wukong","wukong_w2");c.take("wukong_t0");c.combo=2;c.combo_until=c.time+2;c.role.begin(c,"attack",Vector2.RIGHT)
 check(c.player.action.shape=="seal","Third-strike spin talent cannot replace a flame weapon with a melee slash")
 for skill in db.tables.skills:check(not skill.branches[1].contains("范围增加"),"Branch text never promises an unimplemented range bonus: "+skill.id)
 c=fresh("wukong");target=c.spawn("chaser",c.player.pos+Vector2(180,0),0);target.pos=c.player.pos+Vector2(95,0);target.hp=1000;target.max_hp=1000
 c.role.clone_attack(c,{"action":{"weapon_style":"extend","weapon_id":"wukong_w0","direction":Vector2.RIGHT,"damage":20.0,"reach":160.0,"shape":"thrust","combo":1,"heavy":false},"pos":c.player.pos})
 c.role.tick(c,.04,Vector2.ZERO);check(target.hp==1000,"Clone windup cannot deal melee damage")
 c.weapon=db.find("weapons","wukong_w2");c.player.facing=Vector2.LEFT
 c.role.tick(c,.04,Vector2.ZERO);check(target.hp<1000,"Clone contact occurs during its active phase")
 var impact: Dictionary=c.visuals.filter(func(v):return v.kind=="material_hit")[0]
 check(impact.weapon_style=="extend" and impact.dir==Vector2.RIGHT,"Switching weapons cannot recolour or reverse an existing clone hit")
 var after_hit: float=target.hp;c.role.tick(c,.04,Vector2.ZERO);check(target.hp==after_hit,"Clone hit record prevents repeated melee damage")
 check(is_equal_approx(c.visuals.filter(func(v):return v.get("effect","")=="clone_replay")[0].actor.action.elapsed,c.player.delayed[0].action.elapsed),"Clone animation and collision use the same elapsed time")
 check(c.visuals.filter(func(v):return v.get("effect","")=="clone_replay")[0].has("color"),"Clone replay satisfies the live renderer's colour contract")
 var restored=fresh("wukong");restored.restore(c.snapshot().duplicate(true));restored.role.tick(restored,.1,Vector2.ZERO)
 check(restored.enemies[0].hp==after_hit,"Restoring an active clone preserves its hit record")
 var boss=preload("res://scripts/boss_controller.gd")
 var ring: Dictionary={"kind":"ring","pos":Vector2.ZERO,"radius":170.0}
 check(not boss.hazard_contains(ring,Vector2.ZERO),"Roar center stays safe")
 check(boss.hazard_contains(ring,Vector2(170,0)),"Roar band deals damage")
 check(not boss.hazard_contains(ring,Vector2(205,0)),"Outside roar band stays safe")
 var visual=preload("res://scripts/weapon_visual.gd")
 for id in ["wukong_w3","tangseng_w2","shaseng_w4"]:
  var item: Texture2D=visual.dual_part(id,0);var extent: Vector2=visual.dual_extent(id,item)
  check(is_equal_approx(extent.x/extent.y,item.get_width()/float(item.get_height())),"Dual item retains its source proportions: "+id)
  check(item==visual.dual_part(id,0),"Dual sprite regions are reused: "+id)
 var file=FileAccess.open("res://tests/mechanism-polish-results.json",FileAccess.WRITE);file.store_string(JSON.stringify({"passed":passed,"failed":failed},"  "));file.close()
 print("MECHANISM_POLISH passed=",passed," failed=",failed);quit(1 if failed else 0)
