extends SceneTree
var db=preload("res://scripts/content.gd").new()
var passed: int=0
var failures: Array[String]=[]
var records: Array=[]
func check(ok: bool,label: String,actual: Variant=null,expected: Variant=null) -> void:
 records.append({"check":label,"passed":ok,"actual":actual,"expected":expected})
 if ok:passed+=1
 else:failures.append(label);push_error(label)
func _initialize() -> void:call_deferred("run")
func fresh(hero: String="wukong",weapon: int=0):
 var c=preload("res://scripts/combat.gd").new(db)
 c.reset(db.find("heroes",hero),db.find("weapons",hero+"_w"+str(weapon)));c.configure_arena(Vector2(2400,1400))
 c.player.pos=c.arena_bounds().get_center();c.rng.seed=872;c.player.resource=25
 return c
func take(c,id: String,level: int) -> void:
 for i in level:check(c.take(id),id+" legal upgrade "+str(i+1))
func target(c,offset: Vector2=Vector2(80,0)) -> Dictionary:
 var e: Dictionary=c.spawn("dummy",c.player.pos+offset,0);e.hp=10000;e.max_hp=10000;return e
func advance(c,seconds: float,movement: Vector2=Vector2.ZERO) -> void:
 for tick in ceili(seconds*120):c.update(1.0/120,movement)
func resolve(c) -> void:
 for tick in 300:
  if not c.role.busy(c):break
  c.update(1.0/120,Vector2.ZERO)
func run() -> void:
 for hero in db.tables.heroes:
  for weapon in db.for_hero("weapons",hero.id):
   var c=fresh(hero.id,int(weapon.id.right(1)))
   var style: String=preload("res://scripts/weapon_arts.gd").KITS[weapon.id][1]
   check(c.weapon_style()==style and "weapon_"+style in c.tags(),weapon.id+" source geometry identity")
   var e=target(c);c.hit(e,1,"attack",false)
   var sparks: Array=c.visuals.filter(func(v):return v.kind=="material_hit")
   check(not sparks.is_empty() and sparks[0].weapon_style==style,weapon.id+" material impact identity")
 var sand=fresh("shaseng");sand.active_effects=["sand","root","sandburst"]
 check(not sand.can_take("shaseng_t2"),"Extra fan blades reject unrelated projectile ultimate")
 var dragon=fresh("bailongma");dragon.active_effects=["wave","dragon","dragonflight"]
 check(not dragon.can_take("bailongma_t2"),"Extra returning sword rejects lance and nonprojectile spells")
 for level in range(1,4):
  sand=fresh("shaseng");sand.active_effects=["fan"];take(sand,"shaseng_t2",level);sand.player.resource=100
  check(sand.skill(db.find("skills","shaseng_s2"),0,Vector2.RIGHT),"Fan skill starts")
  var timing: float=sand.player.action.windup
  advance(sand,timing+.001)
  var fan: Array=sand.bullets.filter(func(b):return b.source=="skill" and b.get("apply_marks",false))
  check(fan.size()==5+level*2,"Fan actual projectile count level "+str(level),fan.size(),5+level*2)
  dragon=fresh("bailongma",1);take(dragon,"bailongma_t2",level);check(dragon.attack(Vector2.RIGHT),"Returning sword starts")
  advance(dragon,dragon.player.action.windup+.001)
  check(dragon.bullets.size()==2,"Returning sword actual split count level "+str(level),dragon.bullets.size(),2)
  check(dragon.bullets.all(func(b):return b.get("return",false) and b.weapon_style=="wave_sword"),"Both swords preserve return/visual identity")
  check(is_equal_approx(dragon.bullets[0].damage,dragon.weapon.damage/sqrt(2)),"Additional sword shares base damage",dragon.bullets[0].damage,dragon.weapon.damage/sqrt(2))
  var c=fresh();c.active_effects=["dash"];take(c,"purify",level);c.player.poison=3;c.player.burn=3;c.player.resource=50
  var skill: Dictionary=db.for_hero("skills","wukong")[1]
  check(c.skill(skill,0,Vector2.RIGHT),"Purification actual skill starts")
  advance(c,c.player.action.windup+.001)
  check(c.player.poison==0 and c.player.burn==0,"Purification clears both actual statuses")
  check(is_equal_approx(c.player.resource,50-float(skill.cost)+2*level),"Purification refund exact level "+str(level),c.player.resource,50-float(skill.cost)+2*level)
  c=fresh();take(c,"low_power",level);c.player.hp=c.player.max_hp*.3
  check(is_equal_approx(c.scale_damage(100),100*(1+c.value("low_power"))),"Low-life damage actual multiplier")
  c.player.hp=c.player.max_hp*.5;check(is_equal_approx(c.scale_damage(100),100),"Low-life bonus ends above threshold")
  c=fresh();take(c,"full_power",level);c.player.hp=c.player.max_hp
  check(is_equal_approx(c.scale_damage(100),100*(1+c.value("full_power"))),"High-life damage actual multiplier")
  c.player.hp=c.player.max_hp*.8;check(is_equal_approx(c.scale_damage(100),100),"High-life bonus ends below threshold")
  c=fresh();take(c,"element_guard",level);c.invuln=0;c.hurt(20,"毒雾")
  check(is_equal_approx(c.player.max_hp-c.player.hp,20*(1-minf(.6,c.value("element_guard")))),"Element protection actual damage")
  for source in ["余毒","余火"]:
   c.invuln=0;var before: float=c.player.hp;c.hurt(2,source)
   check(is_equal_approx(before-c.player.hp,2*(1-c.value("element_guard"))),"Actual lingering status protection "+source)
  c.invuln=0;var before: float=c.player.hp;c.hurt(10,"首领冰域","element_dot")
  check(is_equal_approx(before-c.player.hp,10*(1-c.value("element_guard"))),"Structured boss periodic damage protection")
  c.invuln=0;before=c.player.hp;c.hurt(10,"普通飞弹")
  check(is_equal_approx(before-c.player.hp,10),"Protection does not reduce direct projectile damage")
  c=fresh();take(c,"dodge_resource",level);check(c.dash(Vector2.RIGHT),"Risk-resource dash starts")
  var dash_duration: float=c.dash_time;c.hurt(20,"第一枚弹幕");var gained: float=c.player.resource
  check(is_equal_approx(gained,25+6+8*level),"Risk-resource actual benefit at level "+str(level))
  c.hurt(20,"同次第二枚弹幕")
  check(c.player.resource==gained and c.dash_time==dash_duration,"Risk-resource cooldown preserves dash and blocks repeated income")
  advance(c,1.1);check(c.dash(Vector2.RIGHT),"Second dash after independent cooldown")
  c.hurt(20,"下次弹幕");check(c.player.resource>gained,"Risk-resource can trigger again after cooldown")
  c=fresh();take(c,"heal_power",level);c.player.hp=c.player.max_hp*.2;var hp: float=c.player.hp;c.heal(10)
  check(is_equal_approx(c.player.hp-hp,10*(1+c.value("heal_power"))),"Healing benefit actual level")
  c=fresh();take(c,"dash_cd",level);check(c.dash(Vector2.RIGHT),"Dash starts")
  check(is_equal_approx(c.dash_cd,2.8/(1+c.value("dash_cd"))),"Dash recovery actual level")
  c=fresh();take(c,"speed",level);var p: Vector2=c.player.pos;advance(c,.75,Vector2.RIGHT)
  var slower=fresh();advance(slower,.75,Vector2.RIGHT)
  check(c.player.pos.x-p.x>slower.player.pos.x-p.x,"Movement distance improves without teleporting")
 var file=FileAccess.open("res://tests/specialized-talent-contracts.json",FileAccess.WRITE)
 file.store_string(JSON.stringify({"passed":passed,"failures":failures,"records":records,"scope":"Explicit actual projectile counts, source applicability, damage/resource thresholds, status cleanse, movement and cooldown fixtures. No human or visual approval."},"  "));file.close()
 print("SPECIALIZED_TALENTS passed=%d failed=%d"%[passed,failures.size()]);quit(1 if not failures.is_empty() else 0)
