extends SceneTree
const DB=preload("res://scripts/content.gd")
const EngineCombat=preload("res://scripts/combat.gd")
const Save=preload("res://scripts/save.gd")
var db=DB.new()
var passed: int=0
var failed: int=0
func check(condition: bool,message: String) -> void:
 if condition:passed+=1
 else:failed+=1;push_error("FAIL: "+message)
func fresh(hero: String="wukong",weapon: String="wukong_w0"):
 var c=EngineCombat.new(db)
 c.reset(db.find("heroes",hero),db.find("weapons",weapon))
 c.active_effects=["summon","mark","sanctuary","pull","beam","detonate","freeze","dragon","shield"]
 c.rng.seed=42
 return c
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 var atlas=preload("res://scripts/icon_catalog.gd").new()
 for table in ["weapons","skills","ultimates","relics","talents"]:
  for item in db.tables[table]:check(atlas.icon(item.id)!=null,"pixel icon mapped to stable item "+item.id)
 var motion_animator=preload("res://scripts/character_pose.gd").new()
 var motion_pose={"velocity":Vector2(230,0),"gait":PI/2,"facing":Vector2.RIGHT}
 var motion_a: PackedVector2Array=motion_animator.vertices(motion_pose,0)
 motion_pose.gait=PI*1.5
 var motion_b: PackedVector2Array=motion_animator.vertices(motion_pose,0)
 check(motion_a[63].y<motion_b[63].y and motion_a[69].y>motion_b[69].y,"left and right feet alternate independently")
 check(motion_a[0].distance_to(motion_b[0])<1,"walking feet do not distort the head")
 var motion_lotus=fresh();motion_lotus.take("lotus_steps");motion_lotus.dash(Vector2.RIGHT)
 check(motion_lotus.fields.size()==3,"motion_lotus dodge leaves three real delayed attacks")
 var motion_dummy=motion_lotus.spawn("dummy",motion_lotus.fields[0].pos,0);motion_dummy.hp=1000
 motion_lotus.update(.36,Vector2.ZERO)
 check(motion_dummy.hp<1000,"motion_lotus blossom actually damages an enemy")
 var motion_crescent=fresh();motion_crescent.take("third_crescent")
 for i in 3:motion_crescent.attack_cd=0;motion_crescent.attack(Vector2.RIGHT)
 check(motion_crescent.fields.size()==2,"third melee strike creates two delayed crescents")
 var motion_wheel=fresh();motion_wheel.take("seal_wheel");motion_wheel.skill(db.tables.skills.filter(func(d):return d.effect=="summon")[0],0,Vector2.RIGHT)
 check(motion_wheel.player.seal_until>motion_wheel.time,"casting primes the seal motion_wheel")
 motion_wheel.attack(Vector2.RIGHT)
 check(motion_wheel.player.seal_until==0 and motion_wheel.visuals.any(func(v):return v.get("style","")=="seal_wheel"),"next attack consumes seal and displays actual bonus attack")
 motion_wheel.attack_cd=0;motion_wheel.visuals=[];motion_wheel.attack(Vector2.RIGHT)
 check(not motion_wheel.visuals.any(func(v):return v.get("style","")=="seal_wheel"),"seal bonus cannot be repeated without casting")
 var motion_parry=fresh();motion_parry.skill(db.tables.skills.filter(func(d):return d.effect=="counter")[0],0,Vector2.RIGHT)
 var motion_hp: float=motion_parry.player.hp
 motion_parry.hurt(40,"测试招式")
 check(motion_parry.player.hp==motion_hp and motion_parry.player.parry_until==0,"successful motion_parry blocks one hit and consumes its window")
 motion_parry.update(.3,Vector2.ZERO);motion_parry.player.shield=0;motion_parry.hurt(40,"后续攻击")
 check(motion_parry.player.hp<motion_hp,"motion_parry does not grant unlimited immunity")
 var motion_wall=fresh();motion_wall.skill(db.tables.skills.filter(func(d):return d.effect=="waterwall")[0],0,Vector2.RIGHT)
 motion_hp=motion_wall.player.hp;motion_wall.player.shield=0
 motion_wall.shoot(motion_wall.player.pos+Vector2(250,0),Vector2.LEFT,40,{"friendly":false,"speed":1000.0})
 motion_wall.update(.25,Vector2.ZERO)
 check(motion_wall.player.hp==motion_hp and motion_wall.bullets.is_empty(),"water motion_wall catches motion_a fast projectile before it damages the player")
 var motion_tide=fresh();motion_tide.skill(db.tables.skills.filter(func(d):return d.effect=="wave")[0],0,Vector2.RIGHT)
 var motion_origin: Vector2=motion_tide.fields[0].pos;motion_tide.update(.1,Vector2.ZERO)
 check(motion_tide.fields[0].pos.x>motion_origin.x+15,"wave advances rather than remaining motion_a stationary circle")
 var motion_quake=fresh();motion_quake.skill(db.tables.skills.filter(func(d):return d.effect=="quake")[0],0,Vector2.RIGHT)
 check(motion_quake.fields.size()==3 and motion_quake.fields[0].tick>motion_quake.fields[2].tick,"motion_quake has three sequential real explosions")
 for definition in db.tables.skills:
  var caster=fresh(definition.hero,definition.hero+"_w0")
  caster.skill(definition,0,Vector2.RIGHT)
  check(caster.player.pose_clip==definition.effect,"skill motion_pose corresponds to effect "+definition.id)
  check(caster.visuals.any(func(v):return v.get("style","")==definition.effect),"skill emits matching visual "+definition.id)
 var motion_replay=fresh();motion_replay.take("lotus_steps");motion_replay.dash(Vector2.RIGHT)
 var motion_restored=fresh();motion_restored.restore(motion_replay.snapshot().duplicate(true));motion_restored.update(.4,Vector2.ZERO)
 check(motion_restored.visuals.all(func(v):return v.life>0),"new spell visuals survive snapshot restoration and expire")
 var moving_skill=fresh()
 var moving_origin: Vector2=moving_skill.player.pos
 moving_skill.skill(db.find("skills","wukong_s1"),0,Vector2.RIGHT)
 check(moving_skill.player.pos==moving_origin,"lunge begins without instant teleportation")
 moving_skill.update(.06,Vector2.ZERO)
 check(moving_skill.player.pos.x>moving_origin.x+50 and moving_skill.player.pos.x<moving_origin.x+100,"lunge advances smoothly during its action")
 var moving_progress: Vector2=moving_skill.player.pos
 moving_skill.dash(Vector2.UP)
 check(moving_skill.player.skill_left==0,"dodge cancels remaining skill travel")
 moving_skill.update(.06,Vector2.ZERO)
 check(absf(moving_skill.player.pos.x-moving_progress.x)<1,"cancelled lunge does not continue sliding forward")
 var room_motion=fresh();room_motion.skill(db.find("skills","wukong_s1"),0,Vector2.RIGHT);room_motion.clear_room()
 check(room_motion.player.skill_left==0 and room_motion.player.velocity==Vector2.ZERO,"new room clears skill travel and velocity")
 var palette=preload("res://scripts/audio_palette.gd").new()
 for i in 40:palette.trigger("impact")
 check(palette.voices.size()<=16,"layered sound limits concurrent voices")
 var audio_valid=true
 for i in 10000:audio_valid=audio_valid and is_finite(palette.sample())
 check(audio_valid,"audio mixer never emits invalid samples")
 check(palette.voices.is_empty(),"sound voices expire after playback")
 for boss_profile in db.tables.bosses:
  var stress=fresh();stress.configure_arena(Vector2(2400,1400));stress.create_layout("boss",boss_profile.biome)
  var stress_enemy=stress.spawn("boss",stress.player.pos+Vector2(350,0),0,boss_profile.name)
  stress_enemy.hp=stress_enemy.max_hp*.2
  for frame in 360:
   stress.invuln=1
   stress.update(1.0/60,Vector2.RIGHT.rotated(frame*.025))
  check(stress_enemy.phase==3 and stress_enemy.pos.is_finite(),"final phase stable during movement "+boss_profile.name)
  check(stress.hazards.size()<=24 and stress.enemies.size()<=40 and stress.bullets.size()<=160,"final boss effects remain bounded "+boss_profile.name)
 for relic_definition in db.tables.relics:
  var support=fresh();support.passive_relic=relic_definition.effect
  support.player.hp=50;support.player.resource=0;support.player.shield=20;support.player.poison=2;support.skill_cd=[2.0,2.0]
  var foe=support.spawn("dummy",support.player.pos+Vector2(70,0),0)
  support.spawn("dummy",support.player.pos+Vector2(130,0),0)
  var event: String=support.synergy.EVENTS[relic_definition.effect]
  var before_support=[support.player.hp,support.player.shield,support.player.resource,support.player.poison,support.skill_cd.duplicate(),foe.pos,foe.mark,foe.root,foe.slow,support.bullets.size(),support.fields.size(),support.dealt,support.player.get("relic_line_until",0),support.player.get("barrier_until",0)]
  check(support.synergy.trigger(support,event),"equipped support executes "+relic_definition.id)
  var after_support=[support.player.hp,support.player.shield,support.player.resource,support.player.poison,support.skill_cd.duplicate(),foe.pos,foe.mark,foe.root,foe.slow,support.bullets.size(),support.fields.size(),support.dealt,support.player.get("relic_line_until",0),support.player.get("barrier_until",0)]
  check(before_support!=after_support,"support has real gameplay consequence "+relic_definition.id)
  check(not support.synergy.trigger(support,event),"support cooldown blocks repeated trigger "+relic_definition.id)
  var state=support.snapshot().duplicate(true);var restored_support=fresh();restored_support.restore(state)
  check(not restored_support.synergy.trigger(restored_support,event),"support cooldown survives restore "+relic_definition.id)
 var resonance=fresh();resonance.passive_relic="thunder"
 var resonance_foe=resonance.spawn("dummy",resonance.player.pos+Vector2(70,0),0);resonance_foe.hp=2000
 var resonance_other=resonance.spawn("dummy",resonance.player.pos+Vector2(110,0),0);resonance_other.hp=2000
 for i in 3:resonance.attack_cd=0;resonance.attack(Vector2.RIGHT)
 check(resonance.damage_sources.has("雷链") and resonance_other.hp<2000,"third strike really produces relic lightning")
 var returning_weapon=fresh("wukong","wukong_w1")
 returning_weapon.take("return");returning_weapon.attack(Vector2.RIGHT);returning_weapon.update(.12,Vector2.ZERO)
 check(returning_weapon.recall()==1,"outgoing weapon can be recalled manually")
 check(returning_weapon.recall()==0,"already returning weapon cannot be recalled repeatedly")
 for i in 60:returning_weapon.update(1.0/60,Vector2.ZERO)
 check(returning_weapon.player.get("recall_charge",0)==1,"actual collection primes one melee finisher")
 returning_weapon.weapon=db.find("weapons","wukong_w0");returning_weapon.attack_cd=0;returning_weapon.attack(Vector2.RIGHT)
 check(returning_weapon.player.recall_charge==0,"melee finisher consumes recall charge")
 var expired_recall=fresh("wukong","wukong_w1");expired_recall.take("return")
 expired_recall.player.recall_charge=3;expired_recall.player.recall_until=-1
 expired_recall.shoot(expired_recall.player.pos,Vector2.RIGHT,1,{"return":true,"back":true,"manual_recall":true})
 expired_recall.update(.01,Vector2.ZERO)
 check(expired_recall.player.recall_charge==1,"expired recall stacks cannot be renewed by one new weapon")
 var mobility=fresh();var start: Vector2=mobility.player.pos
 mobility.update(1.0/60,Vector2.RIGHT)
 check(mobility.player.velocity.x>0 and mobility.player.velocity.x<mobility.hero.speed,"movement starts responsive with brief acceleration")
 for i in 5:mobility.update(1.0/60,Vector2.RIGHT)
 check(is_equal_approx(mobility.player.velocity.x,mobility.hero.speed),"movement reaches full speed within 100ms")
 for i in 4:mobility.update(1.0/60,Vector2.ZERO)
 check(mobility.player.velocity.length()<.1,"release brakes within 70ms")
 for i in 6:mobility.update(1.0/60,Vector2.LEFT)
 check(mobility.player.velocity.x<0 and mobility.player.facing.x<0,"turning changes velocity and facing")
 var cardinal=fresh();var diagonal=fresh()
 for i in 20:cardinal.update(1.0/60,Vector2.RIGHT);diagonal.update(1.0/60,Vector2(1,1))
 check(is_equal_approx(cardinal.player.velocity.length(),diagonal.player.velocity.length()),"diagonal movement cannot gain speed")
 var slow_rate=fresh();var fast_rate=fresh()
 for i in 30:slow_rate.update(1.0/30,Vector2.RIGHT)
 for i in 120:fast_rate.update(1.0/120,Vector2.RIGHT)
 check(slow_rate.player.pos.distance_to(fast_rate.player.pos)<4,"movement remains consistent across 30 and 120Hz")
 mobility.attack_cd=0;mobility.attack(Vector2.UP,true)
 check(mobility.player.attack_heavy and mobility.player.attack_direction==Vector2.UP and mobility.player.lunge.y<0,"heavy attack commits direction and forward impulse")
 mobility.dash(Vector2.RIGHT)
 check(mobility.player.attack_left==0 and mobility.player.lunge==Vector2.ZERO,"dash cancels attack pose and residual lunge")
 var charges=mobility.dash_stock
 check(not mobility.dash(Vector2.RIGHT) and mobility.dash_stock==charges,"active dash cannot be stacked to erase cooldowns")
 check(not mobility.attack(Vector2.RIGHT),"dash startup cannot be immediately erased by attack")
 mobility.update(.09,Vector2.RIGHT)
 check(mobility.attack(Vector2.RIGHT) and mobility.dash_time==0 and mobility.player.attack_left>0 and mobility.invuln<=.025,"late dash cancel enters visible attack and gives up protection")
 var continuation=fresh();continuation.restore(mobility.snapshot().duplicate(true))
 check(continuation.player.velocity==mobility.player.velocity and continuation.player.attack_left==mobility.player.attack_left,"motion state survives snapshot restore")
 # Evolution belongs to one weapon and survives saves without affecting the other slot.
 var evolved=fresh()
 check(evolved.evolve(1),"first evolution applies")
 check(not evolved.evolve(2),"evolution branches mutually exclusive")
 evolved.weapon=db.find("weapons","wukong_w1")
 check(evolved.evolution()==0,"switch does not transfer evolution")
 check(evolved.evolve(2),"secondary can evolve independently")
 evolved.weapon=db.find("weapons","wukong_w0")
 check(evolved.evolution()==1,"switch back restores original branch")
 var checkpoint_state=evolved.snapshot().duplicate(true)
 var recovered=fresh()
 recovered.restore(checkpoint_state)
 check(recovered.evolution()==1,"per-weapon evolution persisted")
 var legacy_evolution=checkpoint_state.duplicate(true)
 legacy_evolution.erase("evolutions");legacy_evolution.player.evolution=2
 recovered.restore(legacy_evolution)
 check(recovered.evolution()==2 and recovered.player.evolution==0,"legacy evolution migrates once to current weapon")
 for w in db.tables.weapons:
  for branch in [1,2]:
   var sample=fresh(w.hero,w.id)
   sample.evolve(branch)
   sample.spawn("dummy",sample.player.pos+Vector2(65,0),0)
   sample.attack(Vector2.RIGHT,true)
   check(sample.attack_cd>0 and sample.attack_interval()!=w.interval,"evolution alters cadence "+w.id+str(branch))
   var primary: Array=sample.bullets.filter(func(b):return b.source=="heavy")
   if w.mode=="bolt":check(primary.size()>=(3 if branch==1 else 1) and primary[0].pierce>0,"bolt spread or innate pierce")
   elif w.mode=="field":check(sample.fields.size()==(2 if branch==1 else 1),"field evolution geometry")
   elif w.mode=="orbit" and branch==2:check(sample.player.shield==8,"guarding orbit grants real shield")
   elif w.mode=="return":check(primary[0].get("back_power",0)==(1.5 if branch==2 else 1.0),"return evolution back damage")
 var returning=fresh("wukong","wukong_w4")
 returning.evolve(2)
 var return_target=returning.spawn("dummy",returning.player.pos+Vector2(100,0),0)
 return_target.hp=10000;return_target.max_hp=10000
 returning.attack(Vector2.RIGHT)
 var outgoing_damage: float=0
 for frame in 180:
  returning.update(1.0/120,Vector2.ZERO)
  if frame==45:outgoing_damage=returning.dealt
 check(outgoing_damage>0 and returning.dealt>outgoing_damage*2,"return path hits again with amplified damage")
 check(returning.bullets.is_empty(),"return shot is removed after recovery")
 var ink=fresh("wukong","wukong_w2")
 ink.evolve(2);ink.attack(Vector2.RIGHT);ink.attack_cd=0
 var ink_target=ink.spawn("dummy",ink.fields[0].pos,0)
 ink_target.hp=10000;ink_target.max_hp=10000
 ink.attack(Vector2.RIGHT,true)
 check(ink_target.hp<10000 and ink.fields.size()==1,"heavy detonates old ink field once")
 var preview_source=fresh()
 preview_source.take("burn")
 var preview_node=load("res://scripts/preview.gd").new()
 var dependent=db.tables.talents.filter(func(t):return t.effect=="fireburst")[0]
 preview_node.configure(db,preview_source.hero,preview_source.weapon,dependent,preview_source,["wukong_s0"],[0])
 check(preview_node.demonstration_ok and preview_node.after.has("burn") and preview_node.after.has("fireburst"),"preview inherits talent prerequisites")
 check(preview_node.before.owned==preview_source.owned and not preview_source.has("fireburst"),"preview never changes live build")
 preview_node._process(.01)
 check(preview_node.before.summons.size()>0,"preview actually executes equipped summon skill")
 preview_node.free()
 var spacious=fresh()
 spacious.configure_arena(Vector2(2400,1400))
 spacious.player.pos=Vector2(1700,1000)
 spacious.update(.1,Vector2.RIGHT)
 check(spacious.player.pos.x>1700,"player travels beyond old right boundary")
 spacious.skill(db.find("skills","wukong_s1"),0,Vector2.RIGHT)
 spacious.update(.24,Vector2.ZERO)
 check(spacious.player.pos.x>1900,"movement skill uses expanded map bounds")
 spacious.player.pos=Vector2(10000,10000);spacious.update(.1,Vector2.ZERO)
 check(spacious.player.pos==spacious.arena_origin+spacious.arena_size-Vector2(20,20),"new outer boundary clamps player")
 spacious.player.pos=Vector2(1800,1000)
 var large_boss=spacious.spawn("boss",Vector2(2000,1000),0,"红孩儿")
 spacious.bosses.begin(spacious,large_boss,"fire")
 check(spacious.hazards.all(func(h):return h.pos.x>1180),"boss warning locations respect expanded map")
 spacious.shoot(Vector2(1800,1100),Vector2.RIGHT,1,{"life":3.0,"return":false,"trigger":false})
 spacious.update(.1,Vector2.ZERO)
 check(not spacious.bullets.is_empty(),"projectiles remain alive outside old screen bounds")
 spacious.caches=[{"pos":spacious.player.pos,"coins":9,"claimed":false}]
 var money_before=spacious.player.coins
 spacious.collect_caches();spacious.collect_caches()
 check(spacious.player.coins==money_before+9,"exploration cache settles only once")
 var wide_restore=fresh();wide_restore.restore(spacious.snapshot().duplicate(true))
 wide_restore.collect_caches()
 check(wide_restore.arena_size==Vector2(2400,1400) and wide_restore.player.coins==money_before+9,"expanded map and claimed cache survive save")
 var cover=fresh()
 cover.configure_arena(Vector2(2400,1400))
 cover.obstacles=[{"pos":Vector2(700,700),"radius":60.0,"kind":"rock"}]
 cover.geometry.configure(cover.arena_bounds(),cover.obstacles)
 cover.player.pos=Vector2(600,700)
 cover.update(.25,Vector2.RIGHT)
 check(cover.player.pos.x<620,"normal movement cannot enter rock")
 cover.dash(Vector2.RIGHT);cover.update(.1,Vector2.ZERO)
 check(cover.player.pos.x<620,"dash cannot tunnel through cover")
 cover.skill(db.find("skills","wukong_s1"),0,Vector2.RIGHT)
 cover.update(.24,Vector2.ZERO)
 check(cover.player.pos.x<620,"movement skill sweeps obstacle collision")
 cover.player.pos=Vector2(600,700)
 var screened=cover.spawn("dummy",Vector2(800,700),0)
 cover.area(cover.player.pos,400,100,"test",false)
 check(screened.hp==screened.max_hp,"area shock cannot hit through rock")
 cover.shoot(Vector2(600,700),Vector2.RIGHT,40,{"return":false,"speed":1000.0})
 cover.update(.25,Vector2.ZERO)
 check(cover.bullets.is_empty() and screened.hp==screened.max_hp,"swept projectile stops before enemy behind cover")
 cover.invuln=0
 var health: float=cover.player.hp
 cover.shoot(Vector2(800,700),Vector2.LEFT,40,{"friendly":false,"return":false,"speed":1000.0})
 cover.update(.25,Vector2.ZERO)
 check(cover.player.hp==health,"cover blocks hostile projectile too")
 cover.shoot(Vector2(600,700),Vector2.RIGHT,10,{"return":true,"speed":1000.0,"life":3.0,"trigger":false})
 cover.update(.07,Vector2.ZERO)
 check(cover.bullets.size()==1 and cover.bullets[0].back,"return weapon turns back on cover contact")
 cover.update(.04,Vector2.ZERO);cover.update(.02,Vector2.ZERO)
 check(cover.bullets.is_empty(),"blocked return weapon can be recovered")
 cover.shoot(Vector2(600,700),Vector2.RIGHT,10,{"return":false,"speed":1000.0,"life":3.0,"bounce":1,"trigger":false})
 cover.update(.07,Vector2.ZERO)
 check(cover.bullets.size()==1 and cover.bullets[0].dir.x<0 and cover.bullets[0].bounce==0,"ricochet reflects once using obstacle normal")
 cover.bullets=[]
 var hunter=cover.spawn("chaser",Vector2(520,700),0)
 cover.player.pos=Vector2(900,700)
 for tick in 600:cover.move_enemy(hunter,cover.player.pos,1.0/60,150)
 check(hunter.pos.distance_to(cover.player.pos)<65,"enemy routes around rock instead of getting stuck")
 check(cover.geometry.walkable(hunter.pos,hunter.radius),"navigation ends in valid collision position")
 var cover_copy=fresh();cover_copy.restore(cover.snapshot().duplicate(true))
 check(cover_copy.obstacles==cover.obstacles and not cover_copy.geometry.visible(Vector2(600,700),Vector2(800,700)),"save restores both obstacle appearance and collision")
 cover.player.pos=Vector2(900,700);cover.hazards=[]
 cover.bosses.hazard(cover,Vector2(500,700),24,"laser",.5,30,.1,{"end":cover.player.pos})
 check(cover.hazards[0].end.x<700,"laser warning stops at same cover that blocks damage")
 cover.player.pos=Vector2(1700,1000);cover.relic_cd=0
 var blink_relic=db.tables.relics.filter(func(r):return r.effect=="blink")[0]
 cover.relic(blink_relic,Vector2.RIGHT)
 check(cover.player.pos.x>1900,"relic movement no longer uses old arena clamp")
 cover.take("return");cover.take("homing");cover.take("bounce")
 cover.shoot(Vector2(1700,1200),Vector2.RIGHT,1,{"friendly":false})
 var hostile: Dictionary=cover.bullets[-1]
 check(not hostile["return"] and not hostile.homing and hostile.bounce==0,"enemy bullets cannot inherit player shape talents")
 var layout_names: Array=[]
 for seed_number in 24:
  var room=fresh();room.configure_arena(Vector2(2400,1400));room.rng.seed=seed_number;room.create_layout("combat","forest")
  if room.layout_name not in layout_names:layout_names.append(room.layout_name)
  check(room.obstacles.size()>=10 and room.obstacles.size()<=18,"bounded varied room layout")
  check(room.geometry.visible(room.player.pos,room.exit_position(),42),"layout reserves reachable central exit corridor")
  var restored_room=fresh();restored_room.restore(room.snapshot().duplicate(true))
  check(restored_room.obstacles==room.obstacles and restored_room.layout_name==room.layout_name,"layout does not reroll on reload")
 check(layout_names.size()==6,"all six layout variants occur")
 for role in ["chaser","ranged","charge","guard","summoner","elite"]:
  var shapes: Array=[]
  var attacks: Array=[]
  for encounter_seed in 12:
   var encounter=fresh();encounter.rng.seed=encounter_seed
   var unit=encounter.spawn(role,Vector2(740,370),0)
   var appearance=[unit.skin,unit.visual_variant,snappedf(unit.body_scale,.01)]
   if appearance not in shapes:shapes.append(appearance)
   for attempt in 8:
    var action=encounter.enemy_ai.choose(encounter,unit)
    if action not in attacks:attacks.append(action)
   encounter.enemy_ai.begin(encounter,unit,unit.attack_pool[0])
   var saved_encounter=fresh();saved_encounter.restore(encounter.snapshot().duplicate(true))
   check(saved_encounter.enemies[0].skin==unit.skin and saved_encounter.enemies[0].attack==unit.attack,"enemy appearance and pending attack stay fixed across reload "+role)
  check(shapes.size()>5 and attacks.size()>=2,"random enemy appearances and role attacks "+role)
 for profile in db.tables.bosses:
  var duel=fresh();duel.invuln=999
  var boss=duel.spawn("boss",Vector2(740,370),0,profile.name)
  boss.hp=boss.max_hp*.2
  duel.update(.016,Vector2.ZERO)
  check(boss.phase==3 and boss.transition>0 and boss.warning==0,"boss third phase creates readable transition "+profile.id)
  for frame in 180:duel.update(1.0/60,Vector2.ZERO)
  check(boss.sequence>0,"third phase performs actual move "+profile.id)
  boss.followups=[];boss.sequence=3
  var signature_first=duel.bosses.choose(duel,boss)
  check(signature_first==profile.signature[0] and boss.followups.size()==profile.signature.size()-1,"boss signature chain is data driven "+profile.id)
  duel.bosses.begin(duel,boss,"fire")
  check(duel.hazards.any(func(h):return int(h.get("owner",-1))==int(boss.uid)),"boss owns its warning hazards "+profile.id)
  duel.die(boss)
  check(not duel.hazards.any(func(h):return int(h.get("owner",-1))==int(boss.uid)),"boss death cancels pending attacks "+profile.id)
 var punish=fresh()
 var ordinary=punish.spawn("dummy",Vector2(740,370),0)
 var exposed=punish.spawn("dummy",Vector2(760,370),0)
 ordinary.hp=1000;exposed.hp=1000;exposed.exposed=1.0
 punish.rng.seed=21;punish.hit(ordinary,10,"test",false)
 punish.rng.seed=21;punish.hit(exposed,10,"test",false)
 check(is_equal_approx((1000-exposed.hp)/(1000-ordinary.hp),1.15),"boss punish window grants actual damage bonus")
 var fair=fresh();fair.invuln=999
 var bull=fair.spawn("boss",Vector2(920,370),0,"牛魔王")
 fair.bosses.begin(fair,bull,"charge");fair.bosses.execute(fair,bull);bull.warning=0
 check(bull.charging>0 and bull.exposed==0,"no punish bonus while boss is charging")
 fair.bosses.update(fair,bull,.51)
 check(bull.charging==0 and bull.exposed>1 and bull.boss_cd>=1.4,"charge recovery opens full punish window")
 fair.bosses.begin(fair,bull,"fire")
 fair.bosses.hazard(fair,bull.pos,50,"fire",3,8,0,{"owner":bull.uid})
 var second=fair.spawn("boss",Vector2(720,270),0,"红孩儿")
 fair.bosses.begin(fair,second,"fire")
 bull.followups=["charge"];bull.ward=3;bull.break=99
 fair.hit(bull,1,"test",false,2)
 check(bull.stagger>0 and bull.warning==0 and bull.followups.is_empty() and bull.ward==0,"break interrupts boss warning chain and ward")
 check(not fair.hazards.any(func(h):return int(h.get("owner",-1))==int(bull.uid) and h.warn>0),"broken boss cannot fire queued hazard")
 check(fair.hazards.any(func(h):return int(h.get("owner",-1))==int(bull.uid) and h.warn==0) and fair.hazards.any(func(h):return int(h.get("owner",-1))==int(second.uid)),"interrupt keeps active fields and other enemy warnings")
 for action in ["fan","wave","burst"]:
  for stage in [1,2,3]:
   bull.phase=stage;fair.bosses.begin(fair,bull,action)
   var predicted=fair.bosses.projectile_directions(bull)
   fair.bullets=[];fair.bosses.execute(fair,bull)
   var matched: bool=fair.bullets.size()==predicted.size()
   for shot_index in mini(fair.bullets.size(),predicted.size()):matched=matched and fair.bullets[shot_index].dir.is_equal_approx(predicted[shot_index])
   check(matched,"boss projectile warning matches actual volley %s %d"%[action,stage])
 var leap=fresh()
 var jumper=leap.spawn("charge",Vector2(300,370),0)
 leap.enemy_ai.begin(leap,jumper,"leap")
 var landing: Vector2=leap.hazards[0].pos
 check(jumper.pos.distance_to(landing)<=221,"leap warning uses reachable landing rather than distant player")
 leap.enemy_ai.execute(leap,jumper)
 check(jumper.pos.distance_to(landing)<1,"leap lands exactly inside its warning circle")
 leap.enemy_ai.begin(leap,jumper,"leap");jumper.break=35;jumper.volley_left=1;jumper.rush_time=.3
 leap.hit(jumper,1,"test",false,2)
 check(jumper.telegraph==0 and jumper.volley_left==0 and jumper.rush_time==0 and leap.hazards.all(func(h):return h.warn<=0),"normal enemy break cancels queued attacks")
 var icy=fresh();icy.invuln=0
 icy.shoot(icy.player.pos,Vector2.RIGHT,2,{"friendly":false,"status":"frost","speed":0.0})
 icy.update(.01,Vector2.ZERO)
 check(icy.player.slow>1,"enemy frost projectile has real status effect")
 check(db.tables.talents.size()==123,"123 unique talents")
 check(db.tables.weapons.size()==25,"25 weapons")
 check(db.tables.skills.size()==30,"30 skills")
 check(db.tables.ultimates.size()==10,"10 ultimates")
 check(db.tables.relics.size()==18,"18 relics")
 check(db.tables.events.size()==24,"24 events")
 check(db.tables.trials.size()==12,"12 trials")
 check(db.tables.chapters.size()==37,"37 chapters")
 var bosses: int=0
 var trials: int=0
 for chapter in db.tables.chapters:
  trials+=chapter.lastTrial-chapter.firstTrial+1
  bosses+=chapter.bossRefs.size()
 check(bosses==26,"26 source boss encounters")
 check(trials==81,"81 source ordeals")
 var ids: Array=[]
 for t in db.tables.talents:
  check(t.id not in ids,"unique id "+t.id)
  ids.append(t.id)
  var c=fresh(t.hero if t.hero!="" else "wukong")
  if "projectile" in t.tags or "projectile" in t.get("source_tags_any",[]):c.weapon=db.find("weapons",c.hero.id+"_w1")
  if "field" in t.tags:
   for w in db.for_hero("weapons",c.hero.id):
    if w.mode=="field":c.weapon=w
  if "orbit" in t.tags:
   for w in db.for_hero("weapons",c.hero.id):
    if w.mode=="orbit":c.weapon=w
  for requirement in t.get("requires",[]):c.take(requirement)
  for requirement in t.get("requires_any",[]):
   if c.can_take(requirement):c.take(requirement);break
  check(c.can_take(t.id),"talent eligible "+t.id)
  check(c.take(t.id),"talent apply "+t.id)
  for i in int(t.max_level)-1:check(c.take(t.id),"talent upgrade "+t.id)
  check(not c.take(t.id),"max level blocks "+t.id)
  var enemy=c.spawn("boss",Vector2(690,370),0,"测试首领")
  c.player.resource=100
  c.attack(Vector2.RIGHT,true,.8)
  for step in 90:c.update(1.0/60,Vector2.ZERO)
  check(c.player.hp>=0 and c.bullets.size()<=160 and c.fields.size()<=32,"bounded simulation "+t.id)
 for w in db.tables.weapons:
  var c=fresh(w.hero,w.id)
  c.spawn("boss",Vector2(710,370),0,"靶")
  c.attack(Vector2.RIGHT)
  for i in 80:c.update(1.0/60,Vector2.ZERO)
  check(c.dealt>0,"weapon deals real damage "+w.id)
 for s in db.tables.skills:
  var c=fresh(s.hero,s.hero+"_w0")
  c.player.hp=c.player.max_hp*.6
  c.player.resource=100
  c.spawn("chaser",Vector2(700,370),0)
  c.spawn("boss",Vector2(740,370),0,"靶")
  check(c.skill(s,0,Vector2.RIGHT),"skill executable "+s.id)
  check(c.skill_cd[0]>0,"skill cooldown "+s.id)
  check(not c.skill(s,0,Vector2.RIGHT),"cooldown blocks "+s.id)
  for i in 30:c.update(1.0/60,Vector2.ZERO)
 for r in db.tables.relics:
  var c=fresh()
  c.player.hp=50
  c.player.resource=5
  c.skill_cd=[5.0,5.0]
  c.spawn("boss",Vector2(700,370),0,"靶")
  check(c.relic(r,Vector2.RIGHT)=="","relic executable "+r.id)
  check(c.relic_cd>0,"relic cooldown "+r.id)
  check(c.relic(r,Vector2.RIGHT)!="","relic cannot spam "+r.id)
 for u in db.tables.ultimates:
  var actor=fresh(u.hero,u.hero+"_w0")
  actor.player.resource=100
  actor.player.hp=30
  for i in 5:
   var target=actor.spawn("dummy",Vector2(710+i*30,370),0)
   target.hp=10000;target.max_hp=10000
  check(actor.ultimate(u,Vector2.RIGHT),"ultimate executes "+u.id)
  check(actor.player.resource==20,"ultimate resource cost "+u.id)
  check(not actor.ultimate(u),"ultimate cannot spam "+u.id)
  for i in 120:actor.update(1.0/60,Vector2.ZERO)
  check(actor.dealt>0 or actor.player.shield>0 or actor.player.hp>30,"ultimate real consequence "+u.id)
 var c=fresh("wukong","wukong_w1")
 c.take("split");c.take("chain")
 for i in 10:c.spawn("boss",Vector2(710+i*20,370+i%2*20),0,"靶")
 c.attack(Vector2.RIGHT)
 for i in 150:c.update(1.0/60,Vector2.ZERO)
 check(c.dealt>30,"split chain deals damage")
 check(c.bullets.size()<=160,"split chain bounded")
 c=fresh()
 c.take("glass");c.take("goldbody")
 check(not c.can_take("storm"),"max two cores")
 c=fresh()
 check(not c.can_take("burn_power"),"burn upgrade excluded without burn")
 c.take("burn")
 check(c.can_take("burn_power"),"burn upgrade enabled with burn")
 c.active_effects=[]
 check(not c.can_take("wukong_t1"),"summon upgrade excluded without summon source")
 c.active_effects=["summon"]
 check(c.can_take("wukong_t1"),"summon upgrade enabled with equipped summon")
 c.take("goldbody")
 check(not c.can_take("crit"),"crit excluded under goldbody")
 # Three Wukong builds must expose different real combat behavior.
 var melee=fresh()
 melee.take("echo")
 melee.spawn("boss",Vector2(725,370),0)
 melee.attack(Vector2.RIGHT,true)
 check(melee.fields.size()==1 and melee.fields[0].kind=="mine","melee build creates delayed ink strike")
 var ranged=fresh("wukong","wukong_w1")
 ranged.take("split");ranged.take("chain");ranged.take("fan")
 for i in 4:ranged.spawn("boss",Vector2(700+i*30,370),0)
 ranged.attack(Vector2.RIGHT)
 check(ranged.bullets.size()==3,"ranged build changes primary attack count")
 var shot_count=ranged.shot_id
 for i in 45:ranged.update(1.0/60,Vector2.ZERO)
 check(ranged.shot_id>shot_count,"ranged build actually splits on impact")
 check(ranged.damage_sources.has("雷链"),"ranged build actually chains to another target")
 var field=fresh("wukong","wukong_w2")
 field.take("burn");field.take("domain")
 var field_target=field.spawn("boss",Vector2(760,370),0)
 field.attack(Vector2.RIGHT)
 check(field.fields.size()==1 and field.fields[0].radius>=120,"field build expands persistent attack")
 field.update(.02,Vector2.ZERO)
 check(field_target.burn>0,"primary field actually applies elemental status")
 var prior=field.value("domain")
 field.weapon=db.find("weapons","wukong_w0")
 field.active_effects=[];field.rebuild_effects()
 check(prior>0 and field.value("domain")==0,"incompatible core becomes inactive after weapon switch")
 var rng=RandomNumberGenerator.new()
 rng.seed=234
 var owned: Dictionary={}
 var banned: Array=["damage","armor"]
 var offers: Array=db.choices("wukong",["melee"],owned,banned,rng)
 check(offers.size()==3,"three choices")
 for id in offers:
  var t: Dictionary=db.find("talents",id)
  check(id not in banned,"ban excludes")
  check(t.hero in ["","wukong"],"hero filter")
  check("projectile" not in t.tags,"weapon filter")
 var rng_state=rng.state
 var restored=RandomNumberGenerator.new()
 restored.state=rng_state
 check(db.choices("wukong",["melee"],{},[],rng)==db.choices("wukong",["melee"],{},[],restored),"rng continuation deterministic")
 var st=Save.new()
 var path="user://test-v2-save.json"
 check(st.write({"offers":offers,"rng":str(rng.state)},path),"atomic save")
 check(st.read(path).offers==offers,"candidates preserved")
 check(st.write({"offers":offers,"marker":2},path),"second atomic save")
 var corrupt=FileAccess.open(path,FileAccess.WRITE)
 corrupt.store_string("{bad")
 corrupt.close()
 check(st.read(path).offers==offers,"backup recovery")
 for suffix in ["",".tmp",".bak"]:
  if FileAccess.file_exists(path+suffix):DirAccess.remove_absolute(path+suffix)
 check(db.tables.bosses.size()==26,"26 implemented boss profiles")
 for profile in db.tables.bosses:
  var battle=fresh()
  var enemy=battle.spawn("boss",Vector2(950,370),0,profile.name)
  check(enemy.has("profile"),"boss profile applied "+profile.id)
  battle.invuln=999
  for frame in 360:battle.update(1.0/60,Vector2.ZERO)
  check(enemy.sequence>=1,"boss phase one acts "+profile.id)
  enemy.hp=enemy.max_hp*.4
  for frame in 300:battle.invuln=999;battle.update(1.0/60,Vector2.ZERO)
  check(enemy.phase==2,"boss second phase changes "+profile.id)
  check(battle.hazards.size()<=24 and battle.bullets.size()<=160,"boss effects bounded "+profile.id)
 var guard=fresh()
 guard.player.resource=100
 check(guard.relic(db.find("relics","relic_16"),Vector2.RIGHT)!="","full resource relic rejected")
 check(guard.relic_cd==0,"ineffective relic does not consume cooldown")
 guard.take("goldbody")
 check(guard.relic(db.find("relics","relic_0"),Vector2.RIGHT)!="","crit relic rejected for goldbody")
 var mover=fresh("bailongma","bailongma_w0")
 mover.player.resource=0
 mover.take("bailongma_t0")
 mover.update(.1,Vector2.RIGHT)
 var gain1=mover.player.resource
 mover.player.resource=0;mover.take("bailongma_t0");mover.update(.1,Vector2.RIGHT)
 check(mover.player.resource>gain1,"movement resource talent level two increases real gain")
 var source=fresh()
 source.active_effects=[];source.rebuild_effects()
 check(not source.can_take("shield_burst"),"shield break talent needs shield source")
 source.take("shield")
 check(source.can_take("shield_burst"),"shield break talent activates with shield talent")
 var scene=load("res://Main.tscn").instantiate()
 scene.storage.base_path="user://test-v2-scene.json"
 for suffix in ["",".tmp",".bak"]:
  if FileAccess.file_exists(scene.storage.base_path+suffix):DirAccess.remove_absolute(scene.storage.base_path+suffix)
 scene.cinematics_enabled=false
 root.add_child(scene)
 await process_frame
 scene.set_physics_process(false)
 var meta_before=scene.meta.duplicate(true)
 var checkpoint_before=scene.checkpoint.duplicate(true)
 scene.start_demo()
 check(scene.mode=="training" and scene.state=="lab","demo starts at interactive lab")
 var expected: Array=[["echo","frost","frost_break"],["return","fan","split","chain"],["burn","domain","shield","shield_burst"]]
 for preset in 3:
  scene.demo_build(preset)
  check(expected[preset].all(func(id):return scene.fight.owned.has(id) and scene.fight.talent_active(scene.db.find("talents",id))),"every demo preset has real active talents %d"%preset)
  scene.demo_dummies();scene.fight.attack(Vector2.RIGHT,true)
  check(not scene.fight.fields.is_empty() if preset==2 else not scene.fight.bullets.is_empty() if preset==1 else not scene.fight.visuals.is_empty(),"demo preset changes actual attack %d"%preset)
 scene.hero_id="tangseng";scene.demo_build(0)
 check(scene.hero_id=="wukong" and scene.fight.hero.id=="wukong" and scene.skill_ids[0]=="wukong_s0","demo presets align hero weapon and skill ownership")
 scene.demo_squad()
 check(scene.fight.enemies.size()==8 and scene.fight.enemies.any(func(enemy):return enemy.kind=="elite"),"demo squad contains all roles and elite")
 for stage in [1,2,3]:
  scene.demo_boss("红孩儿",stage)
  check(scene.fight.enemies.size()==1 and scene.fight.enemies[0].phase==stage,"demo boss starts selected phase %d"%stage)
  scene.fight.update(.016,Vector2.ZERO)
  check(scene.fight.enemies[0].phase==stage,"demo phase matches health threshold %d"%stage)
 scene.fight.player.hp=0;scene.hitstop=0;scene._physics_process(.016)
 check(scene.state=="lab","training death opens retry menu")
 scene.restore_demo()
 check(scene.fight.player.hp==scene.fight.player.max_hp and scene.state=="playing" and scene.fight.invuln>1,"training retry restores life with brief protection")
 scene.demo_boss("不存在",1)
 check(scene.fight.enemies[0].name=="红孩儿","invalid demo boss ignored")
 check(scene.meta==meta_before and scene.checkpoint==checkpoint_before,"demo cannot change permanent progress or saved run")
 scene.demo_build(0);scene.demo_squad()
 var demon_positions: Array=scene.fight.enemies.map(func(enemy):return enemy.pos)
 for i in 30:scene._physics_process(1.0/60)
 check(scene.fight.enemies.any(func(enemy):return enemy.speed>0 and enemy.cooldown<999),"training no longer freezes real enemies")
 check(scene.fight.enemies[0].pos.distance_to(demon_positions[0])>2,"demo monsters really move during gameplay")
 scene.fight.attack_cd=.1;scene.charging=true;scene.charge=.8
 var release=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_RIGHT;release.pressed=false
 scene._unhandled_input(release)
 check(scene.heavy_buffer>0 and not scene.charging,"heavy release buffers rather than disappearing during recovery")
 for i in 12:scene._physics_process(1.0/60)
 check(scene.fight.player.attack_heavy and scene.heavy_buffer==0,"buffered heavy fires when attack recovery ends")
 scene.update_hud()
 check(scene.battle_hud.model.slots.size()==6 and scene.battle_hud.model.hp==scene.fight.player.hp,"HUD uses current combat state for all six slots")
 scene.fight.player.resource=100;scene.fight.skill_cd=[0.0,0.0]
 scene.fight.skill(scene.db.find("skills","wukong_s0"),0,Vector2.UP)
 check(scene.fight.player.action_kind=="cast" and scene.fight.player.attack_direction==Vector2.UP,"skill cast has committed directional motion")
 scene.fight.player.resource=100;scene.fight.ultimate(scene.db.find("ultimates","wukong_u0"),Vector2.LEFT)
 check(scene.fight.player.action_kind=="ultimate" and scene.fight.player.attack_direction==Vector2.LEFT,"ultimate has its own cast motion")
 scene.mode="training"
 var chosen_weapons: Array=scene.weapon_ids.duplicate()
 for page in ["hero","weapon","skill","ultimate"]:
  scene.loadout_tab=page;scene.loadout()
  check(scene.footer.get_child_count()==2,"loadout keeps primary and return actions pinned "+page)
  check(scene.weapon_ids==chosen_weapons,"loadout tab does not replace equipment "+page)
 scene.demo_build(1)
 for page in ["overview","talents","relics","training"]:
  scene.build_tab=page;scene.build_panel()
  check(scene.footer.get_child_count()==2 and scene.menu_title.text=="本局修行录","build page keeps shared heading and return "+page)
 scene.training_category="全部";scene.build_tab="training";scene.build_panel()
 var searches=scene.panel.find_children("TalentSearch","LineEdit",true,false)
 check(searches.size()==1,"training has one persistent search field")
 searches[0].text="雷";searches[0].text_changed.emit("雷")
 var visible_cards: Array=[]
 for node in scene.panel.find_children("*","Button",true,false):
  if node.has_meta("search") and node.visible:visible_cards.append(node)
 check(not visible_cards.is_empty() and visible_cards.all(func(card):return str(card.get_meta("search")).containsn("雷")),"search filters visible talents without rebuilding input")
 searches[0].text="zzzz不存在";searches[0].text_changed.emit("zzzz不存在")
 check(scene.panel.find_children("*","Button",true,false).filter(func(node):return node.has_meta("search") and node.visible).is_empty(),"empty search result hides unrelated talents")
 scene.talent_search="";scene.demo_boss_panel()
 check(scene.footer.get_child_count()==1 and scene.panel.find_children("*","OptionButton",true,false)[0].item_count==26,"boss picker exposes every profile with pinned return")
 scene.loadout_tab="weapon";scene.loadout();await process_frame
 check(scene.menu_nav.visible and scene.menu_nav.get_child_count()==4,"equipment tabs stay outside scrolling content")
 check(scene.footer.get_children().all(func(item):return item.size.x>=140 and item.size.y<=80),"footer buttons remain legible and compact after layout")
 scene.notify("old combat prompt");scene.home();scene.update_hud()
 check(not scene.toast.visible,"old state notification cannot leak into homepage")
 scene.build_panel("route")
 var cancel_menu=InputEventKey.new();cancel_menu.physical_keycode=KEY_ESCAPE;cancel_menu.pressed=true
 scene._unhandled_input(cancel_menu)
 check(scene.state=="route","escape from route build returns to route rather than entering combat")
 for page in ["display","audio","controls"]:
  scene.settings_tab=page;scene.show_settings()
  check(scene.menu_nav.get_child_count()==3 and scene.footer.get_child_count()==1,"settings tabs preserve footer "+page)
 scene.mode="short";scene.loadout()
 scene.start_run()
 check(scene.options.size()==2,"route initial choices")
 scene.enter_room("shop")
 var money=scene.fight.player.coins
 scene.buy("shield",9999)
 check(scene.fight.player.coins==money,"invalid purchase no charge")
 scene.fight.player.coins=100
 scene.buy("shield",10)
 check(scene.fight.player.coins==90 and scene.fight.player.shield>=25,"valid transaction effect")
 scene.buy("shield",10)
 check(scene.fight.player.coins==90,"duplicate purchase prevented")
 scene.buy("relic",15)
 var selection=scene.selection_items.duplicate()
 var paid=scene.fight.player.coins
 scene.save_run()
 scene.resume_run()
 check(scene.selection_items==selection,"paid selection preserved on load")
 check(scene.fight.player.coins==paid,"paid selection no double charge")
 scene.commit_selection(selection[0])
 check(scene.relic_ids[scene.relic_slot]==selection[0],"paid relic selection really equipped")
 scene.commit_selection(selection[0])
 check(scene.fight.player.coins==paid,"selection cannot claim twice")
 scene.bought=[]
 scene.slot=1
 scene.fight.weapon=scene.db.find("weapons",scene.weapon_ids[1])
 scene.fight.player.coins=100
 scene.buy("weapon",10)
 var replacement=scene.selection_items[0]
 check(replacement not in scene.weapon_ids,"current weapons excluded from paid replacement")
 scene.commit_selection(replacement)
 check(scene.fight.weapon.id==replacement,"secondary weapon replacement immediately updates active combat")
 scene.offers=[]
 scene.pending="level"
 scene.talent_panel()
 var saved_offers=scene.offers.duplicate()
 scene.fight.attack_cd=.7;scene.fight.boost_until=scene.fight.time+4;scene.fight.dash_stock=1;scene.fight.invuln=.03
 scene.save_run()
 scene.resume_run()
 check(is_equal_approx(scene.fight.attack_cd,.7),"reload cannot reset attack cooldown")
 check(is_equal_approx(scene.fight.invuln,.03),"reload cannot grant extra invulnerability")
 check(scene.fight.boost_until>scene.fight.time and scene.fight.dash_stock==1,"temporary buff and dash stocks preserved")
 check(scene.offers==saved_offers,"real scene reload preserves candidates")
 check(scene.checkpoint_valid(scene.checkpoint),"valid checkpoint recognized")
 var malformed=scene.checkpoint.duplicate(true)
 malformed.weapons=["not_a_weapon","not_a_weapon"]
 check(not scene.checkpoint_valid(malformed),"unknown weapon checkpoint rejected")
 malformed=scene.checkpoint.duplicate(true)
 malformed.combat.player.pos={"__v":["invalid",4]}
 check(not scene.checkpoint_valid(malformed),"malformed coordinate checkpoint rejected")
 malformed=scene.checkpoint.duplicate(true)
 malformed.combat.evolutions={"wukong_w0":3}
 check(not scene.checkpoint_valid(malformed),"unknown evolution branch rejected")
 malformed.combat.evolutions={"not_a_weapon":1}
 check(not scene.checkpoint_valid(malformed),"unknown evolved weapon rejected")
 malformed=scene.checkpoint.duplicate(true)
 malformed.combat.obstacles=[{"pos":{"__v":[700,700]},"radius":-10,"kind":"rock"}]
 check(not scene.checkpoint_valid(malformed),"corrupted obstacle radius rejected before restoring geometry")


 scene.kind="event";scene.event_id="event_2";scene.bought=[];scene.fight.player.hp=100
 scene.buy("coins",0)
 var event_money=scene.fight.player.coins
 check(scene.fight.player.hp==90,"event health price actually paid")
 scene.buy("event_alternative",0)
 check(scene.fight.player.coins==event_money,"event alternatives mutually exclusive")
 scene.meta.merit=100
 scene.unlock_content("weapon","wukong_w4")
 var permanent_merit=scene.meta.merit
 scene.unlock_content("weapon","wukong_w4")
 check(scene.meta.merit==permanent_merit and "wukong_w4" in scene.meta.weapon_unlocks,"permanent weapon unlock cannot charge twice")
 scene.unlock_content("talent","domain")
 scene.mode="short";scene.sync_sources()
 check("domain" in scene.db.unlocked_talents,"core permanent unlock enters run pool")
 var legacy_path="user://test-v19-import.json"
 var legacy={"format":"xiyou-v19-meta","meta":{"heroUnlocks":["shaseng"],"merit":100,"unlocks":["shaseng-hidden"]},"completed":[0,1]}
 var legacy_file=FileAccess.open(legacy_path,FileAccess.WRITE)
 legacy_file.store_string(JSON.stringify(legacy));legacy_file.close()
 scene.import_old(legacy_path)
 var imported_merit=scene.meta.merit
 legacy_file=FileAccess.open(legacy_path,FileAccess.WRITE)
 legacy_file.store_string(JSON.stringify(legacy,"  "));legacy_file.close()
 scene.meta.merit-=10
 scene.import_old(legacy_path)
 check(scene.meta.merit==imported_merit-10,"reformatted legacy import cannot restore spent merit")
 check("shaseng_w4" in scene.meta.weapon_unlocks,"legacy hidden weapon maps to corresponding new unlock")
 DirAccess.remove_absolute(legacy_path)
 scene.mode="short";scene.loadout();scene.start_run();scene.enter_room("combat")
 check(scene.fight.arena_size==Vector2(2400,1400) and scene.fight.caches.size()==5,"new battle creates larger exploration map")
 scene.fight.player.pos=scene.fight.arena_bounds().get_center()
 var projected=scene.fight.player.pos+scene.camera_offset()
 check(projected.distance_to(Vector2(640,382.5))<1,"camera follows player with HUD safe area")
 check(scene.screen_to_world(projected)==scene.fight.player.pos,"mouse aim converts screen to world")
 scene.fight.player.pos=scene.fight.arena_origin+Vector2(20,20)
 for i in 20:
  var reinforcement=scene.spawn_position()
  check(reinforcement.distance_to(scene.fight.player.pos)>=280 and scene.fight.arena_bounds().has_point(reinforcement),"edge spawning stays distant and in bounds")
 scene.remaining=0;scene.fight.enemies=[];scene.fight.player.xp=0;scene.hitstop=0
 scene._physics_process(.016)
 check(scene.state=="playing" and scene.fight.player.room_cleared,"clear room opens exit without instant teleport")
 scene.fight.player.pos=scene.fight.exit_position();scene._physics_process(.016)
 check(scene.state=="talent" and scene.room_id in scene.visited,"walking through exit settles room")
 scene.mode="campaign"
 scene.loadout()
 check(scene.weapon_ids.all(func(id):return id in scene.meta.weapon_unlocks),"new run removes unowned training or temporary weapons")
 scene.start_run()
 for chapter_number in 37:
  check(scene.chapter==chapter_number,"campaign chapter reachable %d"%chapter_number)
  scene.kind="boss"
  scene.room_reward()
  scene.finish_choice()
 check(scene.state=="ended","campaign reaches ending")
 check(scene.meta.completed.size()==37,"all chapters settlement recorded")
 for suffix in ["",".tmp",".bak"]:
  if FileAccess.file_exists("user://test-v2-scene.json"+suffix):DirAccess.remove_absolute("user://test-v2-scene.json"+suffix)
 scene.meta.talent_unlocks=scene.meta.talent_unlocks.filter(func(id):return id not in ["lotus_steps","third_crescent","seal_wheel"])
 scene.repair_meta()
 check(["lotus_steps","third_crescent","seal_wheel"].all(func(id):return id in scene.meta.talent_unlocks),"old progress receives new ordinary talent unlocks")
 scene.pause_panel();scene.show_settings();scene.return_from_settings()
 check(scene.state=="paused" and scene.panel.visible,"pause settings returns to paused battle")
 scene.start_run();scene.enter_room("combat");scene.save_run()
 var damaged_checkpoint=scene.checkpoint.duplicate(true);damaged_checkpoint.combat.player.hp="broken"
 check(not scene.checkpoint_valid(damaged_checkpoint),"corrupted player numbers rejected before loading")
 var skill_checkpoint=scene.checkpoint.duplicate(true);skill_checkpoint.combat.player.skill_left=.2;skill_checkpoint.combat.player.erase("skill_direction")
 check(not scene.checkpoint_valid(skill_checkpoint),"incomplete moving skill save rejected before loading")
 var bad_cooldown=scene.checkpoint.duplicate(true);bad_cooldown.combat.skill_cd="invalid"
 check(not scene.checkpoint_valid(bad_cooldown),"malformed cooldown list rejected without script errors")
 var bad_branches=scene.checkpoint.duplicate(true);bad_branches.erase("branches")
 check(not scene.checkpoint_valid(bad_branches),"missing skill branches rejected before resume")
 scene.relic_ids=["relic_0","relic_9"];scene.relic_slot=0;scene.skill_ids=["wukong_s1","wukong_s2"];scene.sync_sources()
 check(scene.fight.passive_relic=="wind" and "summon_source" not in scene.fight.tags(),"passive wind blades do not advertise nonexistent summon source")
 scene.relic_slot=1;scene.sync_sources()
 check(scene.fight.passive_relic=="crit" and "summon_source" in scene.fight.tags(),"changing relic roles updates actual applicability")
 scene.cinematics_enabled=true
 scene.play_cinematic("过场测试","西行启程")
 var clock_before: float=scene.fight.time
 scene.state="playing";scene._physics_process(.1)
 check(scene.cinematic.active and scene.fight.time==clock_before,"cinematic pauses battle without advancing simulation")
 var skip=InputEventKey.new();skip.physical_keycode=KEY_SPACE;skip.pressed=true
 scene._unhandled_input(skip)
 check(not scene.cinematic.active and scene.input_dash==0,"skip input is consumed without immediately dodging")
 scene.play_cinematic("自动结束","测试")
 scene.cinematic.advance(3)
 check(not scene.cinematic.active,"cinematic completes on its own")
 scene.cinematics_enabled=false
 scene.meta.completed=[0.0,0,1.0,1,900,"invalid"]
 scene.repair_meta()
 check(scene.meta.completed==[0,1],"JSON numeric chapter records normalize and deduplicate on load")
 for suffix in ["",".tmp",".bak"]:
  if FileAccess.file_exists(scene.storage.base_path+suffix):DirAccess.remove_absolute(scene.storage.base_path+suffix)
 scene.queue_free()
 await create_timer(.25).timeout
 await process_frame
 print("V2 TESTS: %d passed / %d failed"%[passed,failed])
 quit(1 if failed>0 else 0)

