extends SceneTree
const DB=preload("res://scripts/content.gd")
const Combat=preload("res://scripts/combat.gd")
var db=DB.new()
var passed: int=0
var failed: int=0
func check(ok: bool, message: String) -> void:
 if ok:passed+=1
 else:failed+=1;push_error("FAIL: "+message)
func fresh(id: String="wukong", variant: int=0):
 var c=Combat.new(db)
 c.reset(db.find("heroes",id),db.find("weapons",id+"_w"+str(variant)))
 c.active_effects=[]
 for skill in db.for_hero("skills",id):c.active_effects.append(skill.effect)
 c.rebuild_effects();c.rng.seed=123;c.player.resource=100;c.invuln=0
 return c
func advance(c, seconds: float) -> void:
 for i in ceili(seconds/.01):c.update(.01,Vector2.ZERO)
func target(c, offset: Vector2=Vector2(80,0)) -> Dictionary:
 var e: Dictionary=c.spawn("dummy",c.player.pos+offset,0)
 e.hp=10000;e.max_hp=10000;e.marks=3
 return e
func fingerprint(c) -> Array:
 return [c.dealt,c.player.hp,c.player.shield,c.player.pos,c.player.resource,c.fields.size(),c.bullets.size(),c.summons.size(),c.player.seals.size(),c.player.delayed.size(),c.player.get("parry_until",0),c.player.guard_until,c.player.get("orbit_until",0),c.boost_until,c.enemies.reduce(func(n,e):return n+float(e.root)+float(e.mark)+float(e.marks)+float(e.slow),0.0)]
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var tempos: Array=[]
 for hero in db.tables.heroes:
  var c=fresh(hero.id);var e=target(c)
  check(c.attack(Vector2.RIGHT),hero.id+" starts signature attack")
  check(c.dealt==0,hero.id+" no damage before animation contact")
  var windup: float=c.player.action.windup
  advance(c,windup*.45)
  check(c.dealt==0,hero.id+" windup remains harmless")
  check(not c.can_switch(),hero.id+" weapon switch cannot cancel startup")
  check(not c.dash(Vector2.UP),hero.id+" dash respects cancel window")
  tempos.append(c.player.action.duration)
  advance(c,windup+.35)
  check(c.dealt>0,hero.id+" actual active frame hits target")
  advance(c,1)
  check(c.player.action.is_empty(),hero.id+" returns to idle")
  check(c.can_switch(),hero.id+" allows switching after recovery")
 check(tempos.max()-tempos.min()>.15,"five heroes do not share one attack tempo")
 var c=fresh();var e=target(c)
 c.attack(Vector2.RIGHT);advance(c,.1)
 var saved: Dictionary=c.snapshot().duplicate(true)
 var restored=fresh();restored.restore(saved);advance(c,.5);advance(restored,.5)
 check(is_equal_approx(c.dealt,restored.dealt),"mid-action save restores once-only contact and RNG")
 check(restored.player.action.is_empty(),"restored attack finishes")
 c=fresh();e=target(c);c.attack(Vector2.RIGHT);c.update(.5,Vector2.ZERO)
 check(c.dealt>0,"large time step cannot skip entire active window")
 c=fresh();e=target(c);c.attack(Vector2.RIGHT);advance(c,.7)
 check(c.damage_sources.get("attack",0)>0,"melee source accounted")
 var damage: float=c.dealt;advance(c,.3)
 check(c.dealt==damage,"same melee target cannot be damaged again by finished action")
 c=fresh("tangseng")
 for i in 3:c.attack(Vector2.RIGHT);advance(c,.9)
 check(c.player.seals.size()==2,"Tang combo creates actual persistent seals")
 e=target(c,Vector2(180,0));c.attack(Vector2.RIGHT,true,1);advance(c,.9)
 check(c.player.seals.is_empty() and c.dealt>0,"Tang heavy consumes and detonates seals")
 c=fresh("shaseng");e=target(c);e.marks=0;c.attack(Vector2.RIGHT);advance(c,.7)
 check(e.marks>0,"Sha basic hit applies marks without a talent")
 c.attack(Vector2.RIGHT,true,1);advance(c,.9)
 check(e.marks==0 and c.damage_sources.has("印裂"),"Sha heavy directionally consumes marks")
 c=fresh("shaseng",1);e=target(c);e.marks=3
 var other=target(c,Vector2(-80,0));other.marks=0
 c.attack(Vector2.RIGHT);advance(c,.3)
 check(e.marks==0,"outgoing crescent actually takes marks")
 c=fresh("bajie");c.player.resource=0;c.hurt(20,"test")
 check(c.player.resource>0,"Bajie earns rage from damage")
 c=fresh("bajie");c.player.shield=0;c.player.guard_until=1;c.hurt(30,"test")
 check(c.player.hp==c.player.max_hp and c.player.guard_until==0,"guard consumes one hit")
 advance(c,.3);c.hurt(30,"second")
 check(c.player.hp<c.player.max_hp,"guard is not permanent immunity")
 c=fresh("bailongma");c.player.resource=30
 for i in 50:c.update(.02,Vector2.RIGHT)
 check(c.player.resource>30,"Dragon tide earned through movement")
 advance(c,2);check(c.player.resource<31,"Dragon tide decays after stopping")
 c=fresh();c.player.resource=20;c.dash(Vector2.RIGHT);c.hurt(30,"near miss")
 check(c.player.precise_until>c.time and c.player.resource>20,"Wukong precise dodge arms chase")
 # Continuous collision catches a projectile crossing the entire target in one tick.
 c=fresh("bailongma");e=target(c,Vector2(100,0));c.shoot(c.player.pos,Vector2.RIGHT,25,{"speed":3000.0,"return":false,"life":2.0,"trigger":false})
 c.update(.1,Vector2.ZERO);check(c.dealt>0,"fast projectile cannot tunnel through enemy")
 c=fresh();c.shoot(c.player.pos+Vector2(150,0),Vector2.LEFT,25,{"speed":3000.0,"friendly":false,"return":false,"life":2.0})
 c.update(.1,Vector2.ZERO);check(c.player.hp<c.player.max_hp,"hostile projectile swept collision matches friendly behavior")
 for definition in db.tables.skills:
  c=fresh(definition.hero);c.player.hp=c.player.max_hp*.5
  for offset in [Vector2(80,0),Vector2(180,0),Vector2(-80,0),Vector2(60,50)]:target(c,offset)
  check(c.skill(definition,0,Vector2.RIGHT),definition.id+" eligible cast")
  check(c.dealt==0,definition.id+" payload does not fire on button press")
  var before: Array=fingerprint(c)
  advance(c,c.player.action.windup+.06)
  check(fingerprint(c)!=before,definition.id+" real gameplay effect")
  check(c.visuals.any(func(v):return v.get("role","")==definition.hero and v.get("effect","")==definition.effect),definition.id+" corresponding role visual")
  check(c.skill_cd[0]>0,definition.id+" cooldown starts once")
  advance(c,2)
  check(c.bullets.size()<=160 and c.fields.size()<=32,definition.id+" effects respect caps")
 for definition in db.tables.ultimates:
  c=fresh(definition.hero)
  for offset in [Vector2(100,0),Vector2(180,0),Vector2(-80,0)]:target(c,offset)
  check(c.ultimate(definition),definition.id+" ultimate cast")
  check(c.dealt==0,definition.id+" ultimate respects windup")
  advance(c,c.player.action.windup+.02)
  check(c.visuals.any(func(v):return v.get("effect","")==definition.effect),definition.id+" ultimate visual")
  advance(c,1.5)
  check(c.dealt>0 or c.boost_until>c.time or c.fields.size()>0,definition.id+" actual ultimate effect")
 c=fresh("shaseng");var rejected: float=c.player.resource
 check(not c.skill(db.find("skills","shaseng_s5"),0,Vector2.RIGHT),"empty marks cannot offer executable detonation")
 check(c.player.resource==rejected and c.skill_cd[0]==0,"invalid skill does not spend resources or cooldown")
 check(not c.skill(db.find("skills","wukong_s0"),0,Vector2.RIGHT),"foreign hero skill cannot be used")
 c=fresh("tangseng");c.take("pulse")
 c.role.place_seal(c,c.player.pos+Vector2(30,-60),50);c.role.place_seal(c,c.player.pos+Vector2(160,60),50);target(c,Vector2(100,0));advance(c,.2)
 check(c.damage_sources.has("连印"),"linked seal talent creates damaging geometry")
 c=fresh();c.take("echo");e=target(c,Vector2(70,0));c.attack(Vector2.RIGHT,true,1);advance(c,1)
 check(c.damage_sources.has("迟影"),"echo talent creates real delayed attack")
 c=fresh("bailongma",1);target(c,Vector2(80,0));c.take("fan");c.take("split");c.take("chain");c.attack(Vector2.RIGHT);advance(c,.3)
 check(c.bullets.size()>1,"fan plus split changes projectile population")
 advance(c,5);check(c.bullets.size()<=160,"split and chain do not recurse indefinitely")
 for hero in db.tables.heroes:
  for definition in db.for_hero("skills",hero.id):
   c=fresh(hero.id);var boss=c.spawn("boss",c.player.pos+Vector2(160,0),0,"红孩儿");boss.hp=100000;boss.max_hp=100000
   if definition.effect in ["freeze","root"]:boss.marks=3;c.skill(definition,0,Vector2.RIGHT);advance(c,.3);check(boss.root==0,"boss control converts to slow/break: "+definition.id)
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://role-tests-only.json";root.add_child(scene)
 await process_frame;scene.set_physics_process(false);scene.start_demo()
 for hero in db.tables.heroes:
  for index in 3:
   scene.role_demo(hero.id,index)
   var expected: Array=preload("res://scripts/build_modifier.gd").BUILDS[hero.id][index][1]
   check(expected.all(func(id):return scene.fight.owned.has(id)),hero.id+" build "+str(index)+" contains only valid actual talents")
   check(scene.skill_ids.all(func(id):return db.find("skills",id).hero==hero.id),"build keeps skills inside signature kit")
 scene.input_release_guard=false
 var event=InputEventAction.new();event.action="attack";event.pressed=true;scene._unhandled_input(event)
 check(is_equal_approx(scene.input_attack,.12),"single input buffer is 120ms")
 event.action="skill1";scene._unhandled_input(event)
 check(scene.input_attack==0 and not scene.pending_command.is_empty(),"latest skill replaces prior attack command")
 scene.reset_inputs();check(scene.pending_command.is_empty() and scene.input_release_guard,"menu/focus reset clears stale commands")
 check(scene.checkpoint_valid({})==false,"incomplete checkpoint rejected")
 scene.mode="campaign";scene.state="playing";scene.chapter=0;scene.route=[0];scene.route_index=0;scene.hero_id="wukong"
 scene.weapon_ids=["wukong_w0","wukong_w1"];scene.skill_ids=["wukong_s0","wukong_s2"];scene.ultimate_id="wukong_u0"
 scene.fight.reset(db.find("heroes","wukong"),db.find("weapons","wukong_w0"));scene.sync_sources()
 target(scene.fight);scene.fight.attack(Vector2.RIGHT);advance(scene.fight,.05)
 scene.save_run()
 var payload: Dictionary=scene.storage.read()
 check(not payload.is_empty() and scene.checkpoint_valid(payload.get("run",{})),"active timeline round-trips through atomic serialized save")
 if not payload.is_empty():
  var unpacked: Dictionary=scene.unpack_value(payload.run.combat)
  var reloaded=fresh();reloaded.restore(unpacked)
  advance(scene.fight,.6);advance(reloaded,.6)
  check(is_equal_approx(scene.fight.dealt,reloaded.dealt),"serialized action restores without duplicate hit or missed hit")
 c=fresh();c.visible_bounds=Rect2(c.player.pos-Vector2(150,150),Vector2(300,300))
 var distant=c.spawn("ranged",c.player.pos+Vector2(0,-300),0)
 c.enemy_ai.begin(c,distant,"spread")
 check(distant.telegraph==0,"offscreen enemy cannot start unannounced ranged attack")
 c=fresh()
 for i in 4:
  var attacker=c.spawn("charge",c.player.pos+Vector2(160,i*30),0)
  c.enemy_ai.begin(c,attacker,"rush")
 check(c.enemies.filter(func(enemy):return enemy.telegraph>0).size()==1,"rush attack quota prevents simultaneous pileup")
 c=fresh();var boss=c.spawn("boss",c.player.pos+Vector2(200,0),0,"红孩儿")
 c.bosses.begin(c,boss,"charge");var original_target: Vector2=boss.target
 c.player.pos+=Vector2(0,120);c.bosses.execute(c,boss)
 check(boss.charge_dir.is_equal_approx((original_target-boss.pos).normalized()),"boss charge locks telegraphed target instead of tracking forever")
 c=fresh("bajie");c.take("shield_burst");c.player.shield=20;c.invuln=0;target(c)
 c.hurt(20,"shield")
 check(c.damage_sources.has("反盾"),"shield breaking with no HP loss still produces counterattack")
 c=fresh("wukong");c.take("wukong_t0");c.combo=2;c.combo_until=1;c.attack(Vector2.RIGHT)
 check(c.player.action.shape=="spin","staff talent changes third attack geometry before contact")
 c=fresh("bajie");c.take("bajie_t1");c.player.guard_until=1
 c.shoot(c.player.pos+Vector2(80,0),Vector2.LEFT,10,{"friendly":false})
 c.hurt(10,"projectile")
 check(c.bullets[0].friendly and not c.bullets[0].trigger and c.bullets[0].dir.x>0,"rake guard reflects hostile projectile without recursive triggers")
 c=fresh("tangseng");c.take("tangseng_t1");e=target(c)
 c.RoleTraits.projectile(c,{"source":"协战"},e);c.RoleTraits.projectile(c,{"source":"协战"},e)
 check(c.player.seals.size()==1,"guardian seal has independent cooldown")
 c=fresh("tangseng");c.take("tangseng_t3");c.RoleTraits.chant(c,c.player.pos)
 check(c.fields.any(func(field):return field.kind=="sanctuary"),"chant talent creates actual healing field")
 c=fresh("shaseng");c.take("shaseng_t3");e=target(c);c.RoleTraits.detonate(c,e,30)
 check(c.bullets.size()==2 and not c.bullets[0].trigger,"sand detonation creates nonrecursive shards")
 c=fresh("shaseng",1);c.take("shaseng_t5");c.player.resource=20
 c.shoot(c.player.pos+Vector2(10,0),Vector2.LEFT,10,{"return":true,"back":true,"role":"shaseng"})
 advance(c,.01)
 check(c.bullets.is_empty() and c.player.resource>20,"crescent collection grants resource and removes projectile")
 c=fresh("bailongma");c.take("bailongma_t1");c.RoleTraits.wall(c);var shield: float=c.player.shield;c.RoleTraits.wall(c)
 check(shield==3 and c.player.shield==3,"waterwall shield refund is rate limited")
 c=fresh();e=target(c,Vector2(10,0));c.shoot(e.pos,Vector2.RIGHT,100,{"life":.001})
 advance(c,.01)
 check(c.dealt==0,"expired projectile cannot hit on its final update")
 c=fresh("bajie");c.take("bajie_t1");c.player.guard_until=1
 c.shoot(c.player.pos+Vector2(23,0),Vector2.LEFT,10,{"friendly":false})
 advance(c,.01)
 check(c.bullets.size()==1 and c.bullets[0].friendly,"projectile triggering guard survives actual reflection collision")
 c=fresh();e=c.spawn("boss",c.player.pos+Vector2(100,0),0,"红孩儿")
 c.hit(e,1,"test",false,100);e.stagger=0;c.hit(e,1,"test",false,100)
 check(e.stagger==0,"boss break immunity prevents immediate restagger loops")
 c=fresh("tangseng");c.take("tangseng_t1");c.active_effects=[];c.rebuild_effects();e=target(c)
 c.RoleTraits.projectile(c,{"source":"协战"},e)
 check(c.player.seals.is_empty() and not c.owns("tangseng_t1"),"inactive talent behavior agrees with UI eligibility")
 c=fresh();e=c.spawn("boss",c.player.pos+Vector2(100,0),0,"红孩儿");e.transition=1.2
 var phase_hp: float=e.hp;c.hit(e,50,"test")
 check(e.hp==phase_hp,"boss phase transition does not settle attack damage")
 c=fresh();c.take("heavy_line");c.attack(Vector2.RIGHT,true,1)
 var range_before: float=c.player.action.reach;advance(c,c.player.action.windup+.01)
 check(is_equal_approx(c.player.action.reach,range_before),"heavy geometry fixed before presentation and hit stage")
 c=fresh("tangseng");c.take("heavy_line");var seal_position: Vector2=c.player.pos+Vector2(150,0)
 c.role.place_seal(c,seal_position,60);e=target(c,Vector2(232,0));c.attack(Vector2.RIGHT,true);advance(c,.6)
 check(c.dealt>0,"Tang heavy range talent enlarges actual seal detonation")
 c=fresh("tangseng");c.take("return");c.attack(Vector2.RIGHT);advance(c,.25)
 check(c.bullets.size()>0 and c.bullets[0].life>.7,"returning prayer beads have enough lifetime for round trip")
 c=fresh();c.take("frost");e=c.spawn("boss",c.player.pos+Vector2(100,0),0,"红孩儿")
 for i in 4:c.hit(e,1,"attack",true,0)
 check(e.root==0 and e.slow>0,"generic ice buildup respects boss control conversion")
 var styles: Array=[]
 for weapon in db.tables.weapons:
  c=fresh(weapon.hero,int(str(weapon.id).right(1)))
  for offset in [Vector2(55,0),Vector2(135,0),Vector2(220,0),Vector2(90,60),Vector2(-60,0)]:target(c,offset)
  check(c.attack(Vector2.RIGHT),weapon.id+" begins its weapon kit")
  check(c.dealt==0,weapon.id+" weapon respects windup")
  var style: String=c.player.action.weapon_style;styles.append(style)
  advance(c,c.player.action.windup+.015)
  check(c.visuals.any(func(v):return v.get("weapon_id","")==weapon.id),weapon.id+" owns actual matching weapon FX")
  advance(c,1.8)
  check(c.dealt>0,weapon.id+" normal attack has real damage")
  c.player.resource=100;var damage_before: float=c.dealt
  check(c.attack(Vector2.RIGHT,true,1),weapon.id+" unique heavy can execute")
  advance(c,2.0)
  check(c.dealt>damage_before,weapon.id+" heavy has real gameplay impact")
  check(c.bullets.size()<=160 and c.fields.size()<=32 and c.player.delayed.size()<=32,weapon.id+" respects effect caps")
 check(styles.size()==30 and styles.all(func(id):return styles.count(id)==1),"30 explicit weapon kits, no parity template aliases")
 c=fresh("wukong",1);c.take("field_size");c.take("burn");target(c);c.attack(Vector2.RIGHT);advance(c,.4)
 check(c.fields.size()>0 and c.fields[0].radius>28,"ground pin accepts meaningful field size modifier")
 check(c.enemies.any(func(e):return e.burn>0),"weapon field applies hit elements once per target")
 c=fresh("shaseng",2);c.take("return");target(c);c.attack(Vector2.RIGHT);advance(c,.12)
 check(c.bullets.any(func(b):return b["return"]),"sand shards actually honor returning projectile talent")
 for relic_id in ["relic_18","relic_19","relic_20","relic_21","relic_22"]:
  c=fresh();c.player.hp=c.player.max_hp*.5;target(c)
  if relic_id=="relic_18":c.shoot(c.player.pos,Vector2.RIGHT,10,{"return":true})
  var definition: Dictionary=db.find("relics",relic_id)
  check(c.relic_reason(definition)=="",relic_id+" shared condition allows valid use")
  var before_state: Array=fingerprint(c)
  check(c.relic(definition,Vector2.RIGHT)=="",relic_id+" active executes")
  check(fingerprint(c)!=before_state or c.bullets.any(func(b):return b.get("manual_recall",false)),relic_id+" actual active result")
  check(c.relic_cd>0,relic_id+" cooldown starts once")
  check(c.relic(definition,Vector2.RIGHT)!="",relic_id+" prevents repeated activation")
  c.passive_relic=definition.effect;c.player.relic_cooldowns={}
  var passive_event: String=c.synergy.EVENTS[definition.effect];before_state=fingerprint(c)
  check(c.synergy.trigger(c,passive_event,Vector2.RIGHT),relic_id+" passive executes its own event")
  check(fingerprint(c)!=before_state,relic_id+" passive changes combat")
  check(not c.synergy.trigger(c,passive_event,Vector2.RIGHT),relic_id+" passive cannot recurse within cooldown")
 c=fresh();var recall=db.find("relics","relic_18")
 check(c.relic(recall,Vector2.RIGHT)!="" and c.relic_cd==0,"empty recall relic rejects without cooldown")
 c=fresh();c.trial="noheal";c.player.hp=40
 check(c.relic(db.find("relics","relic_19"),Vector2.RIGHT)!="" and c.relic_cd==0,"lotus follows no-heal rule")
 c=fresh();check(c.relic(db.find("relics","relic_21"),Vector2.RIGHT)!="" and c.relic_cd==0,"sand relic rejects empty targets")
 c=fresh("bajie",5);c.player.shield=8;target(c);c.attack(Vector2.RIGHT,true);advance(c,1)
 check(c.player.shield==0 and c.dealt>0,"new shield heavy actually trades shield for impact")
 c=fresh("shaseng",5);var marked=target(c);marked.marks=3;c.attack(Vector2.RIGHT,true);advance(c,1.5)
 check(marked.marks==0 and c.damage_sources.has("印裂"),"tether heavy consumes existing marks without reapplying")
 c=fresh("shaseng");target(c);c.skill(db.find("skills","shaseng_s6"),0,Vector2.RIGHT);advance(c,.5)
 var idol_position: Vector2=c.summons[0].pos;advance(c,1)
 check(c.summons[0].pos==idol_position and c.enemies.any(func(e):return e.marks>3),"sand idol stays placed and genuinely adds marks")
 c=fresh("bajie");target(c);c.skill(db.find("skills","bajie_s6"),0,Vector2.RIGHT);advance(c,.5)
 c.shoot(c.player.pos+Vector2(140,0),Vector2.LEFT,50,{"friendly":false,"return":false,"speed":500.0})
 var shield_hp: float=c.player.hp;advance(c,.4)
 check(c.player.hp==shield_hp and not c.bullets.any(func(b):return not b.friendly),"rake wall blocks hostile projectile collision")
 for item in db.tables.weapons+db.tables.skills+db.tables.ultimates+db.tables.relics:
  check(scene.icons.icon(item.id)!=null,item.id+" selectable icon exists")
 for weapon in db.tables.weapons:
  c=fresh(weapon.hero,int(str(weapon.id).right(1)))
  for offset in [Vector2(80,0),Vector2(140,0),Vector2(210,0),Vector2(100,60),Vector2(70,35),Vector2(70,-35),Vector2(-60,0)]:target(c,offset)
  var chain_names: Array=[];var total_start: float=c.dealt
  for stage in 3:
   check(c.attack(Vector2.RIGHT),weapon.id+" chain stage %d accepted"%(stage+1))
   check(c.player.action.combo==stage+1,weapon.id+" correct combo index %d"%(stage+1))
   chain_names.append(c.player.action.chain_name)
   var last_action: Dictionary=c.player.action
   advance(c,last_action.duration+.3)
   check(c.dealt>total_start,weapon.id+" stage %d has real damage"%(stage+1));total_start=c.dealt
  check(chain_names.size()==3 and chain_names[0]!=chain_names[1] and chain_names[1]!=chain_names[2],weapon.id+" three explicit unique chain moves")
  advance(c,1.5);check(c.attack(Vector2.RIGHT) and c.player.action.combo==1,weapon.id+" combo resets after break")
 c=fresh();target(c);c.attack(Vector2.RIGHT);var current: Dictionary=c.player.action
 advance(c,current.cancel_at+.01)
 check(c.attack(Vector2.RIGHT) and c.player.action.combo==2,"recovery can flow directly into next basic move")
 c=fresh();c.attack(Vector2.RIGHT,true)
 check(not c.attack(Vector2.RIGHT),"combo chaining never cancels heavy startup")
 var NewTalents=preload("res://scripts/combo_talents.gd")
 for talent in db.tables.talents.filter(func(t):return t.id in ["combo_open","combo_lateral","combo_final","combo_return","combo_anchor","combo_aegis","combo_stride","combo_ink","combo_frugal","combo_draw","w_combo_vault","w_echo_staff","t_combo_lotus","t_recall_print","b_combo_guard","b_shield_spend","s_combo_transfer","s_combo_refund","d_combo_recall","d_tide_precision"]):
  var role_id: String=talent.hero if talent.hero!="" else "wukong"
  var variant: int=5 if talent.id in ["combo_lateral","combo_return"] else 2 if talent.id=="t_recall_print" else 1 if talent.id=="d_combo_recall" else 0
  c=fresh(role_id,variant)
  if talent.id=="t_recall_print":c.take("return")
  check(c.take(talent.id),talent.id+" can be selected on appropriate weapon")
  check(not c.take(talent.id),talent.id+" single mechanism cannot stack repeatedly")
  for offset in [Vector2(70,0),Vector2(140,0),Vector2(100,60)]:target(c,offset)
  c.player.shield=50;c.player.resource=100;c.skill_cd=[5.0,5.0]
  var reference=fresh(role_id,variant);reference.player.shield=50;reference.player.resource=100;reference.skill_cd=[5.0,5.0]
  if talent.id=="t_recall_print":reference.take("return")
  for offset in [Vector2(70,0),Vector2(140,0),Vector2(100,60)]:target(reference,offset)
  var observed_change: bool=false
  for move in 3:
   c.attack(Vector2.RIGHT);reference.attack(Vector2.RIGHT)
   if c.player.action.damage!=reference.player.action.damage or c.player.action.shape!=reference.player.action.shape or c.player.action.reach!=reference.player.action.reach:observed_change=true
   var span: float=maxf(c.player.action.duration,reference.player.action.duration)+.28
   for tick in ceili(span/.01):
    c.update(.01,Vector2.ZERO);reference.update(.01,Vector2.ZERO)
    if fingerprint(c)!=fingerprint(reference) or c.skill_cd!=reference.skill_cd or c.player.get("recall_charge",0)!=reference.player.get("recall_charge",0) or c.enemies.map(func(enemy):return enemy.marks)!=reference.enemies.map(func(enemy):return enemy.marks):observed_change=true
  check(observed_change or c.player.get("combo_draw_ready",false),talent.id+" demonstrably changes three-hit loop")
  check(c.bullets.size()<=160 and c.fields.size()<=32,talent.id+" stays inside concurrent effect limits")
  check(scene.icons.icon(talent.id)!=null,talent.id+" has its selection icon")
 c=fresh();c.player.talent_budget=12
 for t in db.tables.talents:
  if NewTalents.full(c):break
  if c.can_take(t.id):c.take(t.id)
 check(NewTalents.points(c)==12 and not c.can_take("damage"),"campaign chapter has twelve total picks including upgrades")
 c=fresh();c.player.progress_tier=1
 check(not c.can_take("combo_anchor") and c.can_take("combo_frugal"),"early chapter keeps later mechanisms in reserve")
 c.player.progress_tier=2;check(c.can_take("combo_anchor") and not c.can_take("combo_draw"),"middle chapter opens new mechanics but reserves late loop")
 c.player.progress_tier=3;check(c.can_take("combo_draw"),"late chapter opens new risk/reward mechanism")
 c.effect_values={"damage":100.0,"low_power":100.0};c.player.hp=1
 check(c.scale_damage(10)<=30,"ordinary multiplicative damage gain has a bounded ceiling")
 var previous_payload: Dictionary=payload.duplicate(true)
 previous_payload.run.combat.combat_version=3
 var migration_path: String="user://weapon-migration-check.json"
 check(scene.storage.write(previous_payload,migration_path),"write an isolated legacy combat fixture")
 var migrated: Dictionary=scene.storage.read(migration_path)
 check(migrated.get("run",{}).is_empty() and migrated.get("meta",{})==previous_payload.meta and FileAccess.file_exists(migration_path+".pre-weapon-backup.json"),"legacy battle is backed up while permanent progress survives")
 scene.mode="campaign";scene.cinematics_enabled=true;scene.route=[0,1];scene.route_index=0;scene.chapter=0;scene.step=2;scene.visited=[]
 for room_type in ["shop","shrine","event","rest","reward","forge","curse"]:
  scene.room_id="room-check-"+room_type;scene.state="route";scene.options=[room_type];scene.enter_room(room_type)
  check(scene.state=="service_walk" and is_instance_valid(scene.reward_stage),room_type+" enters its own physical scene")
  check(scene.cinematic.active and is_equal_approx(scene.cinematic.duration,.85),room_type+" has a brief room transition")
  scene.cinematic.skip();scene.services()
  check(scene.state=="service_walk",room_type+" cannot interact from outside scene range")
  scene.demo_control=true;scene.demo_movement_override=Vector2.RIGHT
  var position_before: Vector2=scene.fight.player.pos;scene._physics_process(.05)
  check(scene.fight.player.pos!=position_before,room_type+" real walking animation and movement update")
  scene.fight.player.pos=scene.reward_stage.interaction
  var interact=InputEventAction.new();interact.action="interact";interact.pressed=true;scene._unhandled_input(interact)
  check(scene.state=="service",room_type+" physical interaction opens choices")
  scene.save_run();var room_payload: Dictionary=scene.storage.read()
  check(scene.checkpoint_valid(room_payload.get("run",{})),room_type+" persists choices and physical room state")
 scene.clear_reward_stage()
 for talent_id in ["burn","poison","sand","frost","purify","iceburst","fireburst","venomspread","steam","dash_trail","shield_burst","combo_charge","cast_echo"]:
  var low=fresh();var high=fresh()
  for combatant in [low,high]:
   if talent_id in ["iceburst","steam"]:combatant.take("frost")
   if talent_id in ["fireburst","steam"]:combatant.take("burn")
   if talent_id=="venomspread":combatant.take("poison")
   if talent_id=="shield_burst":combatant.take("shield")
   combatant.take(talent_id)
  high.take(talent_id);high.take(talent_id)
  check(int(high.owned.get(talent_id,0))==3,talent_id+" legitimately upgrades to rank three")
  var one: Dictionary=target(low);var three: Dictionary=target(high)
  target(low,Vector2(110,0));target(high,Vector2(110,0))
  low.player.resource=30;high.player.resource=30;low.skill_cd=[0.0,0.0];high.skill_cd=[0.0,0.0]
  match talent_id:
   "burn","poison","sand","frost","steam":low.hit(one,10,"attack");high.hit(three,10,"attack");advance(low,.6);advance(high,.6)
   "purify","cast_echo":low.skill(db.find("skills","wukong_s2"),0,Vector2.RIGHT);high.skill(db.find("skills","wukong_s2"),0,Vector2.RIGHT);advance(low,.8);advance(high,.8)
   "iceburst","fireburst","venomspread":one.root=1;one.burn=1;one.poison=1;three.root=1;three.burn=1;three.poison=1;low.die(one);high.die(three)
   "dash_trail":low.dash(Vector2.RIGHT);high.dash(Vector2.RIGHT)
   "shield_burst":low.player.shield=3;high.player.shield=3;low.hurt(12,"enemy");high.hurt(12,"enemy")
   "combo_charge":low.player.combo_charge=true;high.player.combo_charge=true;low.attack(Vector2.RIGHT,true);high.attack(Vector2.RIGHT,true)
  var low_state: String=JSON.stringify(scene.pack_value(low.snapshot()));var high_state: String=JSON.stringify(scene.pack_value(high.snapshot()))
  # Compare executed values rather than owned/effect dictionaries, which only mirror data.
  var evidence: bool=low.dealt!=high.dealt or low.player.resource!=high.player.resource or low.bullets.size()!=high.bullets.size() or one.burn!=three.burn or one.poison!=three.poison or one.marks!=three.marks or one.slow!=three.slow
  if low.fields.size()>0 and high.fields.size()>0:evidence=evidence or low.fields[0].damage!=high.fields[0].damage or low.fields[0].radius!=high.fields[0].radius
  if low.bullets.size()>0 and high.bullets.size()>0:evidence=evidence or low.bullets[0].damage!=high.bullets[0].damage
  if not low.player.action.is_empty() and not high.player.action.is_empty():evidence=evidence or low.player.action.damage!=high.player.action.damage
  check(evidence,talent_id+" rank three alters actual executed effect, not just description")
 c=fresh("bailongma",5);c.active_effects=[];c.rebuild_effects()
 check(not c.can_take("combo_return"),"return finisher rejected without actual return source")
 c.take("return");check(c.can_take("combo_return"),"return finisher becomes eligible after real return source")
 c=fresh("tangseng",2);check(c.can_take("t_recall_print"),"natural returning rosary allows recall seal without filler talent")
 c=fresh("tangseng",5);var fast: float=0;var slow: float=0
 c.attack(Vector2.RIGHT);fast=c.player.action.duration;c=fresh("tangseng",5);c.take("domain");c.attack(Vector2.RIGHT);slow=c.player.action.duration
 check(slow>fast,"domain core really slows attack timeline")
 c=fresh();c.attack(Vector2.RIGHT,true);var base_heavy: float=c.player.action.damage;c=fresh();c.take("immovable");c.attack(Vector2.RIGHT,true)
 check(c.player.action.damage>base_heavy,"immovable core grants the advertised heavy power")
 c=fresh();c.player.resource=0;c.relic(db.find("relics","relic_16"),Vector2.RIGHT);var ordinary_cd: float=c.relic_cd
 c=fresh();c.take("relicmaster");c.player.resource=0;c.relic(db.find("relics","relic_16"),Vector2.RIGHT)
 check(c.relic_cd>ordinary_cd,"relic mastery has an actual cooldown cost")
 for chapter_index in 37:
  c=fresh("wukong",5);c.player.talent_budget=12;c.player.progress_tier=1+mini(2,int(chapter_index/12));c.rng.seed=700+chapter_index
  for reward in 12:
   var pool: Array=db.choices(c.hero.id,c.tags(),c.owned,[],c.rng)
   check(not pool.is_empty(),"chapter %d still has a valid choice before its cap"%(chapter_index+1))
   if pool.is_empty():break
   check(c.take(pool[0]),"chapter %d reward %d is usable"%[chapter_index+1,reward+1])
  check(NewTalents.points(c)==12 and c.owned.size()<db.tables.talents.size()/2,"chapter %d cannot exhaust the game-wide pool"%(chapter_index+1))
 for role_id in ["wukong","tangseng","bajie","shaseng","bailongma"]:
  c=fresh(role_id,5);c.player.talent_budget=24
  for reward in 24:
   c.player.progress_tier=1+mini(2,int(reward/8))
   var candidates: Array=db.choices(role_id,c.tags(),c.owned,[],c.rng)
   check(not candidates.is_empty(),role_id+" short run reward pool does not drain early")
   if candidates.is_empty():break
   check(c.take(candidates[0]),role_id+" short run candidate can really apply")
  check(NewTalents.points(c)==24,role_id+" short run stays within total progression budget")
 scene.queue_free();await process_frame
 print("ROLE_CHECKS passed=%d failed=%d"%[passed,failed])
 var out=FileAccess.open("res://tests/role-results.json",FileAccess.WRITE);out.store_string(JSON.stringify({"passed":passed,"failed":failed,"scope":"Role mechanics and integration, not human quality acceptance"},"  "));out.close()
 quit(1 if failed>0 else 0)

