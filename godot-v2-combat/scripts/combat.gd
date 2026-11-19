
extends RefCounted
var role=preload("res://scripts/role_combat.gd").new()
const RoleTraits=preload("res://scripts/role_traits.gd")
var role_step_dt: float=0.0
var visible_bounds: Rect2=Rect2(-100000,-100000,200000,200000)
var passive_relic=""
var synergy=preload("res://scripts/relic_synergy.gd").new()
var presentation=preload("res://scripts/skill_presentation.gd").new()
const EnemyController=preload("res://scripts/enemy_controller.gd")
var enemy_ai=EnemyController.new()
var crowd=preload("res://scripts/crowd_spacing.gd").new()
const RoomGeometry=preload("res://scripts/room_geometry.gd")
var geometry=RoomGeometry.new()
var obstacles: Array=[]
var layout_name: String="开阔地"
const BossController=preload("res://scripts/boss_controller.gd")
var bosses=BossController.new()
var motion=preload("res://scripts/action_motion.gd").new()
var hazards: Array=[]
var arena_origin: Vector2=Vector2(90,150)
var arena_size: Vector2=Vector2(1100,470)
var caches: Array=[]
signal feedback(kind: String, position: Vector2, value: float)
signal changed
signal killed(enemy: Dictionary)
var content
var rng := RandomNumberGenerator.new()
var hero: Dictionary = {}
var weapon: Dictionary = {}:
 set(new_weapon):
  weapon=new_weapon
  if not player.is_empty():player.weapon_id=new_weapon.id
  if content!=null and not weapon.is_empty():rebuild_effects()
var evolutions: Dictionary = {}
var owned: Dictionary = {}
var effect_values: Dictionary = {}
var active_talent_ids: Dictionary = {}
var active_effects: Array=[]
var player: Dictionary = {}
var enemies: Array = []
var bullets: Array = []
var fields: Array = []
var summons: Array = []
var visuals: Array = []
var time := 0.0
var combo := 0
var combo_until := 0.0
var attack_cd := 0.0
var skill_cd: Array = [0.0,0.0]
var relic_cd := 0.0
var dash_cd := 0.0
var dash_stock := 2
var dash_direction := Vector2.RIGHT
var dash_time := 0.0
var invuln := 0.0
var boost_until := 0.0
var dash_power_until := 0.0
var cast_haste_until := 0.0
var shot_id := 0
var trial := ""
var loot: Array = []
var deaths := 0
var dealt := 0.0
var damage_sources: Dictionary = {}
func _init(db = null) -> void:
 content = db
 rng.randomize()
func rebuild_effects() -> void:
 effect_values={};active_talent_ids={}
 if content==null:return
 for id in owned:
  var t: Dictionary=content.find("talents",id)
  if not t.is_empty() and talent_active(t):
   active_talent_ids[id]=true
   effect_values[t.effect]=float(effect_values.get(t.effect,0))+float(t.amount)*int(owned[id])
func owns(id: String) -> bool:
 return active_talent_ids.has(id)
func talent_active(t: Dictionary) -> bool:
 var remaining: Dictionary=owned.duplicate()
 remaining.erase(t.id)
 return content.talent_allowed(t,hero.get("id",""),tags(),remaining,[])
func value(effect: String) -> float:
 return float(effect_values.get(effect,0))
func has(effect: String) -> bool: return value(effect) > 0
func reset(hero_data: Dictionary, weapon_data: Dictionary) -> void:
 passive_relic=""
 hero=hero_data.duplicate(true);weapon=weapon_data.duplicate(true);owned={};effect_values={};evolutions={}
 arena_origin=Vector2(90,150);arena_size=Vector2(1100,470);caches=[]
 player={"pos":Vector2(640,370),"hp":float(hero.hp),"max_hp":float(hero.hp),"shield":0.0,"resource":25.0,"xp":0.0,"level":1,"coins":20,"curse":0,"poison":0.0,"burn":0.0,"last_hit":"","weapon_id":weapon.id,"evolution":0,"slow":0.0,"dot":0.0}
 motion.reset(player)
 role.reset(self)
 clear_room();time=0;combo_until=0;boost_until=0;dash_power_until=0;cast_haste_until=0;skill_cd=[0.0,0.0];relic_cd=0;dash_cd=0;dash_stock=2;deaths=0;dealt=0;damage_sources={};combo=0
func evolution() -> int:
 return int(evolutions.get(weapon.get("id",""),0))
func evolve(branch: int) -> bool:
 if branch not in [1,2] or evolution()!=0:return false
 evolutions[weapon.id]=branch
 return true
func attack_interval() -> float:
 var rate: float=weapon.interval/maxf(.4,1+value("haste")+(value("cast_haste") if time<cast_haste_until else 0))
 if has("domain"):rate*=1.2
 if evolution()==1:rate*=.88
 if evolution()==2:rate*=1.12
 return rate
func arena_bounds() -> Rect2:
 return Rect2(arena_origin,arena_size)
func clamp_actor(position: Vector2, margin: float=20) -> Vector2:
 return geometry.constrain(position,margin)
func configure_arena(size: Vector2) -> void:
 arena_size=size;obstacles=[];layout_name="开阔地"
 geometry.configure(arena_bounds(),[])
 player.pos=arena_origin+Vector2(260,size.y*.5)
 player.room_cleared=false;player.skill_left=0.0;player.attack_left=0.0;player.lunge=Vector2.ZERO;player.velocity=Vector2.ZERO
 caches=[]
func create_layout(room_kind: String, biome: String,chapter_identity: int=-1) -> void:
 obstacles=[]
 if chapter_identity>=0 and preload("res://scripts/chapter_scenery.gd").apply_composition(self,chapter_identity):
  geometry.configure(arena_bounds(),obstacles)
  return
 var variant: int=rng.randi_range(0,5)
 if chapter_identity>=0:
  var art_brief: Dictionary=preload("res://scripts/chapter_scenery.gd").brief(chapter_identity,biome)
  variant={"paired_gate":5,"ridge":4,"grove":0,"courtyard":3,"riverbank":2}.get(art_brief.composition,variant)
 layout_name=["疏林曲径","石阵回廊","两岸迂回","上下环阵","折岭石径","双关古阵"][variant]
 for i in 18:
  var column: int=i%6
  var row: int=int(i/6)
  var x: float=460+column*285+rng.randf_range(-40,40)
  var y: float=[280.0,1120.0,400.0 if variant==0 else 1020.0][row]+rng.randf_range(-60,60)
  if variant==1:x+=100 if row%2==1 else -70
  if variant==2:y=250+row*425+(column%2)*110
  elif variant==3:
   x=550+(i%9)*155;y=(340 if i<9 else 1030)+sin((i%9)*PI/8)*60
  elif variant==4:y=[280.0,1100.0,430.0][row]+(column%2)*45
  elif variant==5:x=(620 if column<3 else 1610)+(column%3)*145;y=[280.0,1120.0,430.0][row]
  # Bring scenery into the gameplay camera while preserving the central safe route.
  y=arena_size.y*.5+(y-arena_size.y*.5)*.67
  var position: Vector2=arena_origin+Vector2(x,y)
  if absf(position.y-arena_bounds().get_center().y)<170:continue
  if position.distance_to(exit_position())<180:continue
  obstacles.append({"pos":position,"radius":rng.randf_range(40,66),"kind":"tree" if biome in ["forest","wild","web","night"] else "pillar" if room_kind=="boss" else "rock"})
 preload("res://scripts/chapter_scenery.gd").decorate(obstacles,chapter_identity,biome)
 geometry.configure(arena_bounds(),obstacles)
func move_enemy(enemy: Dictionary, target: Vector2, dt: float, speed: float) -> void:
 enemy.nav_cd=float(enemy.get("nav_cd",0))-dt
 if geometry.visible(enemy.pos,target,enemy.radius):enemy.nav=(target-enemy.pos).normalized()
 elif enemy.nav_cd<=0:
  enemy.nav=geometry.direction(enemy.pos,target,enemy.radius);enemy.nav_cd=.35
 var displacement: Vector2=(enemy.get("nav",Vector2.ZERO)+crowd.push(enemy)*.8).limit_length(1)*speed*dt
 enemy.pos=geometry.move(enemy.pos,displacement,enemy.radius)
func exit_position() -> Vector2:
 return arena_origin+Vector2(arena_size.x-160,arena_size.y*.5)
func collect_caches() -> void:
 for cache in caches:
  if not cache.claimed and cache.pos.distance_to(player.pos)<45:
   cache.claimed=true;player.coins+=int(cache.coins);feedback.emit("pickup",cache.pos,cache.coins)
func clear_room() -> void:
 caches=[];obstacles=[];layout_name="开阔地"
 geometry.configure(arena_bounds(),obstacles)
 player.room_cleared=false;player.skill_left=0.0;player.attack_left=0.0;player.lunge=Vector2.ZERO;player.velocity=Vector2.ZERO
 player.action={};player.delayed=[];player.seals=[];player.motion_state="idle";player.action_phase="idle";player.pose_clip="attack"
 enemies=[];bullets=[];hazards=[];fields=[];summons=[];visuals=[];loot=[];attack_cd=0;dash_time=0;invuln=.6
func weapon_style() -> String:
 var kit: Array=preload("res://scripts/weapon_arts.gd").KITS.get(weapon.id,[])
 return str(kit[1]) if kit.size()>1 else str(weapon.get("attack_style","extend"))
func tags() -> Array:
 var out: Array = ["melee"] if weapon.mode == "slash" else ["projectile"]
 if hero.get("id","")=="tangseng":out.append("field");out.append("melee")
 if "field_source" in out:out.append("field")
 if weapon.mode == "field": out=["field"]
 if weapon.mode == "orbit": out=["orbit"]
 if owned.has("orbit"): out.append("orbit")
 out.append("weapon_"+weapon_style())
 for effect in active_effects:out.append("effect_"+str(effect))
 if owned.has("summoner") or active_effects.any(func(e):return e in ["summon","convert","avatars","wind","needles","sand_guardian"]):out.append("summon_source")
 if "mark" in active_effects:out.append("mark_source")
 if active_effects.any(func(e):return e in ["sanctuary","sand","wave","pagoda","chant","quakes","sandstorm","rake_wall","golden_city","relic_lotus"]):out.append("field_source")
 if "field_source" in out and "field" not in out:out.append("field")
 if "pull" in active_effects:out.append("pull_source")
 if active_effects.any(func(e):return e in ["beam","fan","breath","dragon","pursue","windwheel","arrow_rain"]):out.append("skill_shots")
 if "detonate" in active_effects:out.append("detonate_source")
 if hero.get("id","")=="shaseng" and "detonate_source" not in out:out.append("detonate_source")
 if active_effects.any(func(e):return e in ["freeze","root","wake_bell","relic_hourglass"]):out.append("control_source")
 if "dragon" in active_effects:out.append("buff_source")
 if active_effects.any(func(e):return e in ["shield","counter","waterwall","rake_wall","golden_city","barrier","waterguard","marshal","tide","avatars"]):out.append("shield_source")
 if weapon_style() in ["rosary","hook","meteor","crescent","twin_moon","wave_sword","stars","disc","tether"] or (owned.has("return") and "projectile" in out) or active_effects.any(func(e):return e in ["arrow_rain","windwheel","ring_storm","sandburst","tide","sky_bow"]) or (hero.id=="shaseng" and "wave" in active_effects):out.append("return_source")
 if owned.has("combo_aegis") and "shield_source" not in out:out.append("shield_source")
 if int(player.get("progress_tier",3))>=2:out.append("journey_mid")
 if int(player.get("progress_tier",3))>=3:out.append("journey_late")
 if weapon.mode=="return" or weapon_style()=="disc":out.append("native_return")
 return out
func can_take(id: String, banned: Array = []) -> bool:
 if preload("res://scripts/combo_talents.gd").full(self):return false
 var t: Dictionary=content.find("talents",id)
 return not t.is_empty() and content.talent_allowed(t,hero.id,tags(),owned,banned)
func take(id: String) -> bool:
 if not can_take(id):return false
 var t: Dictionary=content.find("talents",id)
 owned[id]=int(owned.get(id,0))+1
 rebuild_effects()
 if t.effect=="max_hp":player.max_hp+=t.amount; heal(t.amount)
 if t.effect=="glass":player.max_hp*=.7;player.hp=minf(player.hp,player.max_hp)
 if t.effect=="goldbody":player.shield+=40
 if t.effect=="shield":player.shield+=t.amount
 changed.emit();return true
func heal(amount: float) -> void:
 if trial=="noheal":return
 player.hp=minf(player.max_hp,player.hp+amount*(1+value("heal_power")+value("hero_heal_gain")))
func resource(amount: float) -> void:player.resource=clampf(player.resource+amount,0,100)
func scale_damage(base: float, source: String = "attack") -> float:
 var factor:=1+value("damage")
 if has("orbit") and weapon.mode in ["bolt","return"]:factor*=.9
 if has("glass"):factor*=1.6
 if has("storm"):factor*=.8
 if has("summoner") and source in ["attack","heavy"]:factor*=.75
 if player.hp < player.max_hp*.35:factor*=1+value("low_power")
 if player.hp > player.max_hp*.9:factor*=1+value("full_power")
 if player.resource>=85:factor*=1+value("resource_damage")+value("hero_resource_damage")
 if source=="skill":factor*=1+value("hero_skill_power")
 if time<boost_until:factor*=1.25
 if time<dash_power_until:factor*=1+value("dash_attack")
 return base*minf(factor,3.0)*(.93 if preload("res://scripts/journey_balance.gd").enabled(self) else 1.0)
func spawn(kind: String, position: Vector2, tier: int, boss_name: String = "") -> Dictionary:
 if kind!="dummy" and position.distance_to(player.pos)<120:
  position=clamp_actor(player.pos+(position-player.pos).normalized()*180 if position.distance_to(player.pos)>1 else player.pos+Vector2(180,0),40)
 if kind!="dummy" and position.distance_to(exit_position())<100:position=clamp_actor(position+Vector2(-150,0),40)
 var is_boss:=kind=="boss"
 var maxhp: float=(520+tier*42) if is_boss else (100+tier*12 if kind=="elite" else 36+tier*4)
 if kind!="dummy" and preload("res://scripts/journey_balance.gd").enabled(self):maxhp*=preload("res://scripts/journey_balance.gd").vitality(kind,tier)
 var e: Dictionary={"uid":shot_id,"kind":kind,"pos":clamp_actor(position,38 if is_boss else 22 if kind=="elite" else 15),"hp":maxhp,"max_hp":maxhp,"speed":75+tier*1.2,"radius":38 if is_boss else 22 if kind=="elite" else 15,"cooldown":rng.randf_range(.8,2),"telegraph":0.0,"target":Vector2.ZERO,"phase":1,"break":0.0,"stagger":0.0,"slow":0.0,"root":0.0,"burn":0.0,"poison":0.0,"dot":0.0,"marks":0,"mark":0.0,"ice_hits":0,"name":boss_name if is_boss else kind,"flash":0.0,"dead":false}
 e.tier=tier;e.damage_scale=preload("res://scripts/journey_balance.gd").enemy_damage(tier) if kind!="dummy" and preload("res://scripts/journey_balance.gd").enabled(self) else 1.0
 if is_boss:bosses.configure(self,e)
 elif kind!="dummy":enemy_ai.configure(self,e)
 shot_id+=1;enemies.append(e);return e
func hurt(amount: float, source: String,damage_kind: String="") -> void:
 if time<player.get("guard_until",0):
  player.guard_until=0;resource(15);area(player.pos,140,35,"格挡反击",false);RoleTraits.guard(self)
  role.art(self,"guard",player.pos,player.get("facing",Vector2.RIGHT),140,.5)
  feedback.emit("guard",player.pos,0);invuln=.2;return
 if time<player.get("parry_until",0):
  player.parry_until=0;resource(12);area(player.pos,140,45,"招架反击",false);role.art(self,"counter",player.pos,player.get("facing",Vector2.RIGHT),140);feedback.emit("guard",player.pos,0);invuln=.25;return
 if invuln>0:
  if dash_time>0 and hero.id=="wukong" and time>=player.get("dodge_reward_at",0):player.precise_until=time+2;player.dodge_reward_at=time+1;resource(6)
  if dash_time>0 and has("dodge_resource") and time>=player.get("dodge_resource_at",0):
   resource(value("dodge_resource"));player.dodge_resource_at=time+1.0
  return
 var dmg:=amount*(1-minf(.55,value("armor")+(.2 if has("immovable") else 0)))
 if damage_kind=="element_dot" or source in ["毒雾","火域","余毒","余火"]:dmg*=1-minf(.6,value("element_guard"))
 var shield_before: float=player.shield
 var blocked:=minf(player.shield,dmg);player.shield-=blocked;dmg-=blocked
 if hero.id=="bajie" and blocked>0:resource(blocked*.35)
 if blocked>0:feedback.emit("shield",player.pos,blocked)
 if shield_before>0 and player.shield<=0 and has("shield_burst"):
  area(player.pos,80+10*value("shield_burst"),8+6*value("shield_burst"),"反盾",false)
  role.art(self,"counter",player.pos,player.get("facing",Vector2.RIGHT),80+10*value("shield_burst"),.45)
 if hero.id=="bajie" and dmg>0:
  resource(minf(12,dmg*.4))
  if owns("bajie_t0"):player.retaliation=minf(40,float(player.get("retaliation",0))+dmg*.5)
 player.hit_history.append({"source":source,"damage":dmg,"shield":blocked,"resource":player.resource,"time":time})
 if player.hit_history.size()>6:player.hit_history.pop_front()
 player.hp=maxf(0,player.hp-dmg);player.last_hit=source;invuln=.6
 if dmg>0:player.hurt_left=.18
 if blocked>0:synergy.trigger(self,"shield_hit")
 if has("hero_hurt_resource"):resource(30*value("hero_hurt_resource"))
 feedback.emit("hurt",player.pos,dmg);changed.emit()
func hit(e: Dictionary, base: float, source: String, triggers: bool = true, break_power: float = 8, impact_style: String="", impact_direction: Vector2=Vector2.ZERO) -> void:
 if e.dead or e.hp<=0 or e.get("transition",0)>0:return
 var dmg:=scale_damage(base,source)
 if e.get("exposed",0)>0:dmg*=1.15
 var critical:=rng.randf()<minf(.65,.08+value("crit")+(.35 if time<player.get("crit_until",0) else 0)) and not has("goldbody")
 if critical:dmg*=minf(2.4,1.6+value("crit_power"))
 if has("duelist"):dmg*=1.5 if e.kind=="boss" else .8
 if has("frost_break") and e.slow>0:dmg*=1+value("frost_break")
 if e.marks>0:dmg*=1+e.marks*value("sand_damage")*.1
 if e.mark>0:dmg*=1.25+value("hero_mark_power")
 if trial=="armor":dmg*=.7
 if e.get("ward",0)>0:
  if source=="heavy":e.ward=0
  else:dmg*=.5
 if hero.id=="bajie" and source=="heavy" and owns("bajie_t0"):
  dmg+=float(player.get("retaliation",0));player.retaliation=0.0
 if e.kind=="guard":dmg*=.7 if source!="heavy" else 1.15
 if trial=="break":e.break+=20
 var applied:=clampf(dmg,0,maxf(0,e.hp))
 e.hp-=dmg;e.flash=.1;e.break+=break_power*(1+(.5 if has("goldbody") else 0)+value("hero_control_break"))
 dealt+=applied;damage_sources[source]=float(damage_sources.get(source,0))+applied
 if e.break>= (100 if e.kind=="boss" else 36) and time>=e.get("break_lock_until",0):
  e.break=0;e.stagger=1.3 if e.kind=="boss" else .8
  e.break_lock_until=time+e.stagger+(2.0 if e.kind=="boss" else .5)
  if e.has("profile"):bosses.interrupt(self,e)
  elif e.kind!="dummy":enemy_ai.interrupt(self,e)
  resource(value("break_reward"));feedback.emit("break",e.pos,dmg)
 if triggers:
  if source in ["attack","heavy"]:
   match weapon.get("trait",""):
    "frost_edge":e.slow=maxf(e.slow,1.2)
    "resource_edge":resource(2)
    "sand_edge":
     if source!="heavy":e.marks=mini(6,e.marks+1)
  resource((1+value("hero_resource_gain"))*1.5)
  if has("burn"):e.burn=(2+value("burn"))*(1+value("burn_time"))
  if has("poison"):e.poison=2+2*value("poison")
  if has("sand"):e.marks=mini(6,e.marks+int(value("sand"))+int(ceil(value("hero_sand_gain")*5)));e.slow=1.5
  if hero.id=="shaseng" and e.marks>0:resource(e.marks*.35)
  if has("frost"):
   e.slow=(1.5+.5*value("frost"))*(1+value("frost_time"));e.ice_hits+=1
   if e.ice_hits>=4:
    if e.kind=="boss":e.slow=maxf(e.slow,1.2);e.break+=25
    else:e.root=1.2
    e.ice_hits=0
  if critical:resource(value("crit_resource"))
  if has("chain") or (critical and has("crit_chain")):chain(e,base*.35,int(value("chain")+value("chain_count"))+int(critical and has("crit_chain")))
  if has("nova") and source=="attack":area(e.pos,45,base*.25,"震波",false)
 feedback.emit("impact" if source=="heavy" else "crit" if critical else "hit",e.pos,dmg)
 if source in ["attack","heavy","分身复招"] and time>=e.get("hit_spark_until",0) and visuals.size()<160:
  e.hit_spark_until=time+.045
  visuals.append({"kind":"material_hit","pos":e.pos-Vector2(0,22),"dir":player.get("facing",Vector2.RIGHT) if impact_direction==Vector2.ZERO else impact_direction,"weapon_style":weapon_style() if impact_style=="" else impact_style,"radius":24.0 if source=="heavy" else 12.0,"life":.19,"max":.19,"color":Color(hero.color)})
 if e.hp<=0:die(e)
func chain(first: Dictionary, damage: float, count: int) -> void:
 var visited: Array=[first.uid];var origin: Vector2=first.pos
 for jump in mini(5,count):
  var candidate: Dictionary={};var best:=170*(1+value("chain_range"))
  for e in enemies:
   var distance: float=origin.distance_to(e.pos)
   if not e.dead and e.uid not in visited and distance<best:candidate=e;best=distance
  if candidate.is_empty():break
  visuals.append({"kind":"line","from":origin,"pos":candidate.pos,"life":.2,"max":.2,"color":Color("d8bb57"),"radius":2})
  hit(candidate,damage*pow(.8,jump)*(1.5 if has("storm") else 1),"雷链",false,10*(1+value("shock")))
  origin=candidate.pos;visited.append(candidate.uid)
func die(e: Dictionary) -> void:
 if e.dead:return
 hazards=hazards.filter(func(h):return int(h.get("owner",-1))!=int(e.uid))
 bullets=bullets.filter(func(b):return b.get("friendly",true) or int(b.get("owner",-1))!=int(e.uid))
 e.dead=true;deaths+=1
 if e.kind=="boss" and e.has("profile"):
  var actor: Dictionary=e.duplicate(true)
  actor.warning=0.0;actor.transition=0.0;actor.pose_release=0.0;actor.flash=0.0;actor.move_blend=0.0;actor.dash_blend=0.0
  visuals.append({"kind":"boss_fall","actor":actor,"pos":e.pos,"life":.8,"max":.8,"color":Color.WHITE})
 var bonus: float=(1+value("coins"))*(1+value("fortune") if e.kind=="elite" else 1)
 if trial!="nocoins":loot.append({"pos":e.pos,"coins":int((25 if e.kind=="boss" else 8 if e.kind=="elite" else 2)*bonus),"life":20.0})
 player.xp+=(80 if e.kind=="boss" else 25 if e.kind=="elite" else 12)*(1+value("xp"))
 resource(3+value("kill_resource"))
 if e.poison>0:heal(value("kill_heal"))
 if has("iceburst") and e.root>0 and e.kind!="boss":
  for i in 4+int(2*value("iceburst")):shoot(e.pos,Vector2.RIGHT.rotated(i*TAU/(4+2*value("iceburst"))),8+2*value("iceburst"),{"source":"冰裂","trigger":false})
 if has("fireburst") and e.burn>0:area(e.pos,50+15*value("fireburst"),16+6*value("fireburst"),"焰爆",false)
 if has("venomspread") and e.poison>0:add_field(e.pos,45+10*value("venomspread"),3+2*value("venomspread"),2+value("venomspread"),"poison")
 synergy.trigger(self,"kill")
 killed.emit(e);changed.emit()
func area(pos: Vector2, radius: float, damage: float, source: String, triggers: bool = true, impact_style: String="", impact_direction: Vector2=Vector2.ZERO) -> void:
 visuals.append({"kind":"ring","pos":pos,"radius":radius,"life":.28,"max":.28,"color":Color("d68754") if has("burn") else Color("79c2cd") if has("frost") else Color(hero.color)})
 for e in enemies.duplicate():
  if not e.dead and pos.distance_to(e.pos)<radius+e.radius and geometry.visible(pos,e.pos):hit(e,damage,source,triggers,20 if source=="heavy" else 8,impact_style,impact_direction)
func shoot(pos: Vector2, direction: Vector2, damage: float, opts: Dictionary = {}) -> void:
 if bullets.size()>=160:return
 var b: Dictionary={"id":shot_id,"pos":pos,"start":pos,"dir":direction.normalized(),"speed":480.0,"damage":damage,"life":1.2,"age":0.0,"radius":7.0,"pierce":int(value("pierce")),"return":weapon.mode=="return" or has("return"),"back":false,"hit":[],"trigger":opts.get("trigger",true),"source":opts.get("source","attack"),"homing":has("homing"),"bounce":int(value("bounce")),"color":Color(hero.color)}
 if not opts.get("friendly",true):b.merge({"return":false,"homing":false,"bounce":0,"pierce":0},true)
 b.merge(opts,true);bullets.append(b);shot_id+=1
 if not b.get("friendly",true):b.damage*=preload("res://scripts/journey_balance.gd").damage_multiplier(self,int(b.get("owner",-1)))
 if b.get("friendly",true) and b.source=="skill":b.damage*=1+value("hero_projectile_power")
func add_field(pos: Vector2, radius: float, damage: float, duration: float, kind: String) -> void:
 if fields.size()>=32:return
 fields.append({"pos":pos,"radius":radius*(1+value("field_size"))*(1.5 if has("domain") else 1),"damage":damage*(1+value("hero_field_power")),"life":duration*(1+value("field_time"))*(1.5 if has("domain") else 1),"kind":kind,"tick":0.0})
func attack(direction: Vector2, heavy: bool=false, charge: float=0.0) -> bool:
 return role.begin(self,"attack",direction,{},heavy,charge)
func skill_reason(definition: Dictionary, slot: int) -> String:
 return role.skill_reason(self,definition,slot)
func skill(definition: Dictionary, slot: int, direction: Vector2, branch: int=0) -> bool:
 if skill_reason(definition,slot)!="":return false
 var payload: Dictionary=definition.duplicate(true);payload.branch=branch
 if not role.begin(self,"skill",direction,payload):return false
 skill_cd[slot]=definition.cooldown*maxf(.35,1-value("cooldown"))*(1.2 if branch==1 else .8 if branch==2 else 1)
 cast_haste_until=time+3
 return true
func ultimate(definition: Dictionary, direction: Vector2=Vector2.RIGHT) -> bool:
 if ultimate_reason(definition)!="":return false
 return role.begin(self,"ultimate",direction,definition)
func ultimate_reason(definition: Dictionary) -> String:
 if definition.is_empty() or definition.get("hero","")!=hero.id:return "非本角色绝技"
 if player.hp<=0:return "角色已倒下"
 if role.busy(self) or dash_time>0 or player.get("skill_left",0)>0:return "招式执行中"
 if player.resource<float(definition.get("cost",80)):return "资源不足"
 return ""
func can_switch() -> bool:
 return not role.busy(self) and player.get("skill_left",0)<=0 and dash_time<=0
func dash(direction: Vector2) -> bool:
 if dash_stock<=0 or dash_time>0 or not role.can_cancel(self):return false
 player.action={};player.action_phase="idle"
 player.delayed=player.delayed.filter(func(task):return task.kind!="chant")
 player.attack_left=0;player.lunge=Vector2.ZERO;player.skill_left=0.0
 dash_stock-=1;dash_direction=direction.normalized() if direction.length()>.05 else player.get("facing",Vector2.RIGHT);dash_time=preload("res://scripts/character_combat_kit.gd").for_hero(hero.id).dash_duration;invuln=minf(.18,dash_time);attack_cd=0;dash_power_until=time+2
 if dash_cd<=0:dash_cd=2.8/maxf(1,1+value("dash_cd"))
 if (has("dash_trail") or has("hero_dash_power")) and fields.size()<32:fields.append({"pos":player.pos,"radius":60+10*value("dash_trail"),"damage":(16+8*value("dash_trail"))*(1+value("hero_dash_power")),"life":1.1,"kind":"mine","tick":-.35})
 if has("lotus_steps"):
  for i in 3:
   var at: Vector2=geometry.move(player.pos,dash_direction*(40+i*70))
   if fields.size()<32:fields.append({"pos":at,"radius":45.0,"damage":18.0,"life":1.1,"kind":"mine","tick":-.35-i*.1})
   presentation.emit(self,"lotus_steps",at,dash_direction,45,.7+i*.1)
 synergy.trigger(self,"dash",dash_direction)
 feedback.emit("dash",player.pos,0);return true
func relic_reason(definition: Dictionary) -> String:
 if definition.is_empty():return "没有装备法宝"
 if relic_cd>0:return "法宝仍在调息"
 var eff: String=definition.effect
 var extension: String=preload("res://scripts/content_extension.gd").relic_reason(self,eff)
 if extension!="":return extension
 if eff in ["heal","regen"] and player.hp>=player.max_hp and player.poison<=0 and player.burn<=0:return "生命已满且没有异常"
 if eff in ["heal","regen","maxhp"] and trial=="noheal" and (eff!="maxhp" or player.get("fruit",false)):return "本试炼不能回复生命"
 if eff=="maxhp" and player.get("fruit",false) and player.hp>=player.max_hp:return "灵果已食且生命已满"
 if eff=="crit" and has("goldbody"):return "金身构筑已放弃暴击"
 if eff=="resource" and player.resource>=100:return "资源已满"
 if eff=="reset" and skill_cd[0]<=0 and skill_cd[1]<=0 and dash_stock==2:return "技能与闪避均已就绪"
 if eff=="reset" and player.hp<=1:return "生命不足"
 if eff in ["slow","root","gourd","thunder"] and enemies.is_empty():return "附近没有敌人"
 if eff=="purify" and player.poison<=0 and player.burn<=0 and not enemies.any(func(e):return not e.dead and e.pos.distance_to(player.pos)<180):return "没有异常或范围内敌人"
 return ""
func relic(definition: Dictionary, direction: Vector2) -> String:
 var reason: String=relic_reason(definition)
 if reason!="":return reason
 var eff: String=definition.effect
 var factor:=1.5 if has("relicmaster") else 1.0
 preload("res://scripts/content_extension.gd").relic(self,eff,direction,factor)
 match eff:
  "heal":heal(player.max_hp*.28*factor);player.poison=0;player.burn=0
  "regen":player.regen_until=time+12
  "maxhp":
   if not player.get("fruit",false):player.max_hp+=18;player.fruit=true
   heal(player.max_hp*.25)
  "crit":player.crit_until=time+10
  "waterguard","shield","barrier":player.shield+=35*factor;player.barrier_until=time+6
  "slow","root":
   for e in enemies:e.slow=7;e.root=.5 if e.kind=="boss" else 2
  "gourd":
   for e in enemies:
    if not e.dead:e.pos=geometry.move(e.pos,(player.pos-e.pos)*.2,e.radius);hit(e,45*factor,"法宝",false)
  "reset":player.hp=maxf(1,player.hp*.88);skill_cd=[0.0,0.0];dash_stock=2;dash_cd=0
  "wind","needles":summons.append({"pos":player.pos,"life":8.0,"cd":0.0,"damage":20*factor})
  "pagoda":add_field(player.pos,120,20*factor,8,"pagoda")
  "blink":player.pos=geometry.move(player.pos,direction*240);invuln=.4
  "thunder":
   for e in enemies.duplicate():
    if not e.dead:hit(e,65*factor,"法宝",false)
  "purify":player.poison=0;player.burn=0;area(player.pos,180,25*factor,"法宝",false)
  "resource":resource(40*factor)
 relic_cd=definition.cooldown*maxf(.35,1-value("relic_cd"))*(1.2 if has("relicmaster") else 1.0);feedback.emit("skill",player.pos,0);return ""
func nearest(position: Vector2) -> Dictionary:
 var target: Dictionary={};var best:=INF
 for e in enemies:
  if not e.dead and position.distance_squared_to(e.pos)<best:best=position.distance_squared_to(e.pos);target=e
 return target
func update(dt: float, movement: Vector2) -> void:
 if dt>.025:
  var steps: int=ceili(dt/.02)
  for i in steps:update(dt/steps,movement)
  return
 var dash_remaining: float=dash_time
 player.shield=clampf(player.shield,0,150)
 time+=dt;attack_cd=maxf(0,attack_cd-dt);invuln=maxf(0,invuln-dt);dash_time=maxf(0,dash_time-dt)
 for i in 2:skill_cd[i]=maxf(0,skill_cd[i]-dt)
 relic_cd=maxf(0,relic_cd-dt)
 if dash_stock<2:
  dash_cd-=dt
  if dash_cd<=0:dash_stock+=1;dash_cd=2.8/maxf(1,1+value("dash_cd")) if dash_stock<2 else 0
 var speed: float=hero.speed*(1+value("speed"))*(.8 if has("immovable") else 1)*(1.22 if time<boost_until else 1)
 player.slow=maxf(0,player.get("slow",0)-dt)
 if player.slow>0:speed*=.6
 var skill_origin: Vector2=player.pos
 var skill_active: bool=player.get("skill_left",0)>0
 role_step_dt=dt
 motion.step(self,dt,movement,speed,dash_remaining)
 role.tick(self,dt,movement)
 if skill_active:
  for target in enemies.duplicate():
   if not target.dead and target.uid not in player.skill_hits and Geometry2D.get_closest_point_to_segment(target.pos,skill_origin,player.pos).distance_to(target.pos)<target.radius+35 and geometry.visible(skill_origin,target.pos):
    player.skill_hits.append(target.uid);hit(target,player.skill_damage,"skill",false,25)
 player.pos=clamp_actor(player.pos)
 heal(value("regen")*dt)
 if time<player.get("regen_until",0):heal(2.2*dt)
 resource(value("hero_resource_regen")*5*dt)
 if movement.length()>.1 and has("hero_move_resource"):resource(10*value("hero_move_resource")*dt)
 player.poison=maxf(0,player.poison-dt);player.burn=maxf(0,player.burn-dt)
 player.dot=float(player.get("dot",0))-dt
 if player.dot<=0:
  player.dot=.8
  if player.poison>0:hurt(2,"余毒")
  if player.burn>0:hurt(2,"余火")
 bosses.update_hazards(self,dt)
 if trial in ["poison","fire"] and fmod(time,2)<dt:hurt(3,"毒雾" if trial=="poison" else "火域")
 if trial=="thunder" and fmod(time,3)<dt:shoot(Vector2(player.pos.x,150),Vector2.DOWN,14,{"friendly":false,"speed":180.0,"life":3.0,"color":Color("bc963e")})
 collect_caches()
 for drop in loot:
  drop.life-=dt
  var distance: float=drop.pos.distance_to(player.pos)
  if distance<80*(1+value("pickup")):drop.pos=drop.pos.move_toward(player.pos,dt*300)
  if distance<20:player.coins+=drop.coins;drop.life=0
 loot=loot.filter(func(drop):return drop.life>0)
 crowd.rebuild(enemies)
 for e in enemies.duplicate():
  if e.dead:continue
  for timer in ["ward","exposed","transition"]:
   if e.has(timer):e[timer]=maxf(0,float(e[timer])-dt)
  for k in ["slow","root","stagger","mark","flash"]:e[k]=maxf(0,e[k]-dt)
  e.burn=maxf(0,e.burn-dt);e.poison=maxf(0,e.poison-dt);e.dot-=dt
  if e.dot<=0:
   e.dot=.5
   if e.burn>0:hit(e,(2+value("burn"))*(1+value("burn_power")),"灼烧",false,0)
   if e.poison>0:hit(e,(2+.5*value("poison"))*(1+value("poison_power")),"中毒",false,0)
   if has("steam") and e.burn>0 and e.slow>0:hit(e,2+2*value("steam"),"蒸汽",false,0)
  if e.dead or e.stagger>0 or e.root>0:continue
  if e.has("profile"):
   bosses.update(self,e,dt)
   continue
  if e.kind!="dummy":enemy_ai.update(self,e,dt)
  e.pos=clamp_actor(e.pos,e.radius)
 for actor in enemies:
  if not actor.dead:preload("res://scripts/enemy_rig.gd").update(actor,dt)
 for b in bullets.duplicate():
  b.age+=dt;b.life-=dt
  if b.life<=0:continue
  if b.get("friendly",true) and b.homing:
   var target:=nearest(b.pos)
   if not target.is_empty():b.dir=b.dir.lerp((target.pos-b.pos).normalized(),minf(1,dt*5)).normalized()
  if b.get("friendly",true) and b["return"] and (b.back or b.age>float(b.get("turn_after",.55))):
   if not b.back:b.back=true;b.hit=[];b.damage*=float(b.get("back_power",1.0))
   b.dir=(player.pos-b.pos).normalized()
   if b.pos.distance_to(player.pos)<18:
    b.life=0
    RoleTraits.return_home(self,b)
    if b.get("manual_recall",false):
     if time>=player.get("recall_until",0):player.recall_charge=0
     player.recall_charge=mini(3,int(player.get("recall_charge",0))+1);player.recall_until=time+2
     resource(1)
    continue
  var previous_position: Vector2=b.pos
  var next: Vector2=b.pos+b.dir*b.speed*dt
  var contact: Dictionary=geometry.trace(b.pos,next,b.radius)
  if not contact.is_empty():
   b.pos=contact.pos+contact.normal*.5
   if b.get("friendly",true) and b["return"] and not b.back:
    b.back=true;b.hit=[];b.damage*=float(b.get("back_power",1.0));b.dir=(player.pos-b.pos).normalized()
   elif b.bounce>0:b.dir=b.dir.bounce(contact.normal);b.bounce-=1
   else:b.life=0
   if b.life<=0:
    if b.get("friendly",true):feedback.emit("wall",b.pos,0)
    continue
  else:b.pos=next
  if not arena_bounds().grow(20).has_point(b.pos):
   if b.bounce>0:b.dir=Vector2(-b.dir.x if b.pos.x<arena_origin.x-20 or b.pos.x>arena_origin.x+arena_size.x+20 else b.dir.x,-b.dir.y if b.pos.y<arena_origin.y-20 or b.pos.y>arena_origin.y+arena_size.y+20 else b.dir.y);b.bounce-=1
   elif not b["return"]:b.life=0
  if b.life<=0:continue
  if b.get("friendly",true):
   for e in enemies.duplicate():
    if e.dead or e.uid in b.hit:continue
    if Geometry2D.get_closest_point_to_segment(e.pos,previous_position,b.pos).distance_to(e.pos)<e.radius+b.radius:
     b.hit.append(e.uid);hit(e,b.damage,b.source,b.trigger,8,b.get("weapon_style",""),b.dir);RoleTraits.projectile(self,b,e)
     if b.get("apply_marks",false) or b.get("carry_marks",false) or (b.get("role","")=="shaseng" and b.source!="heavy"):
      if b.get("carry_marks",false) and b.back:
       if b.get("carried",0)>0:e.marks=mini(6,e.marks+int(b.carried));b.carried=0
      elif b.get("carry_marks",false):b.carried=mini(6,int(b.get("carried",0))+int(e.marks));e.marks=0
      else:e.marks=mini(6,e.marks+1)
     if b.get("role","")=="bailongma":e.dragon_mark=time+3
     if b.get("frost",false):e.slow=maxf(e.slow,1.4)
     if b.get("pull",0)>0:e.pos=geometry.move(e.pos,(player.pos-e.pos).normalized()*float(b.pull)*(.15 if e.kind=="boss" else 1.0),e.radius)
     if b.trigger and has("split"):
      for offset in [-.6,.6]:shoot(b.pos,b.dir.rotated(offset),b.damage*.35,{"trigger":false,"pierce":0,"source":"分裂","return":false})
     b.pierce-=1
     if b.pierce<0 and not b["return"]:b.life=0;break
  elif fields.any(func(f):return f.kind in ["waterwall","rake_wall"] and Geometry2D.get_closest_point_to_segment(f.pos,b.pos-b.dir*b.speed*dt,b.pos).distance_to(f.pos)<f.radius+b.radius):
   b.life=0;RoleTraits.wall(self)
  elif Geometry2D.get_closest_point_to_segment(player.pos,previous_position,b.pos).distance_to(player.pos)<18+b.radius:
   if time>=player.get("barrier_until",0) and invuln<=0:
    hurt(b.damage,b.get("source","妖术飞弹"))
    if b.get("status","")=="frost":player.slow=1.2
    elif b.get("status","")=="poison":player.poison=2.5
   if b.get("friendly",false):b.pos=geometry.move(player.pos,b.dir*28,b.radius)
   else:b.life=0
 for f in fields:
  if f.life<=0:continue
  if hero.id=="shaseng" and owns("shaseng_t1") and f.kind=="sand":
   f.erase("velocity");f.pos=geometry.move(f.pos,(player.pos-f.pos).limit_length(1)*70*dt,8)
  if f.has("velocity"):
   var next: Vector2=geometry.move(f.pos,f.velocity*dt,8)
   if next.distance_to(f.pos)<f.velocity.length()*dt*.5:f.life=0
   f.pos=next
  f.life-=dt
  if f.life<=0:continue
  if f.kind in ["waterwall","rake_wall"]:
   for projectile in bullets:
    if not projectile.get("friendly",true) and projectile.pos.distance_to(f.pos)<f.radius+projectile.radius:projectile.life=0
   continue
  if f.kind=="mine":
   f.tick+=dt
   if f.tick>=0:area(f.pos,f.radius,f.damage,"墨影",false);f.life=0
  else:
   f.tick-=dt
   if f.tick<=0:
    f.tick=.6
    if f.kind in ["sanctuary","lotus"] and player.pos.distance_to(f.pos)<f.radius:heal(2 if f.kind=="lotus" else 4)
    for e in enemies.duplicate():
     if not e.dead and e.pos.distance_to(f.pos)<f.radius:
      var first_contact: bool=f.get("attack_trigger",false) and e.uid not in f.get("hit",[])
      if first_contact:f.hit.append(e.uid)
      hit(e,f.damage,"领域",first_contact,5);e.slow=1
      if f.kind=="sand":e.pos=geometry.move(e.pos,(f.pos-e.pos)*.08,e.radius);e.marks=mini(6,e.marks+1)
    if has("pulse"):area(f.pos,f.radius*1.3,f.damage*.3,"阵脉",false)
 for s in summons:
  s.life-=dt;s.cd-=dt
  if not s.get("stationary",false):s.pos=s.pos.lerp(player.pos+Vector2(50,-30),dt*3)
  if s.cd<=0:
   s.cd=.65;var target:=nearest(s.pos)
   if not target.is_empty():shoot(s.pos,(target.pos-s.pos).normalized(),s.damage,{"trigger":not s.get("non_recursive",false),"source":"协战","return":false,"apply_marks":s.get("apply_marks",false),"visual":s.get("visual",""),"role":s.get("role",""),"weapon_style":s.get("weapon_style","")})
 if has("summoner") and summons.is_empty():summons.append({"pos":player.pos,"life":2.0,"cd":0.0,"damage":12})
 if has("orbit") or time<player.get("orbit_until",0):
  for i in 1+int(value("orbit_count")):
   var pos: Vector2=player.pos+Vector2.RIGHT.rotated(time*3*(1+value("orbit_speed"))+i*PI)*78
   if fmod(time,.4)<dt:area(pos,24,8,"护兵",true)
 for v in visuals:v.life-=dt
 bullets=bullets.filter(func(b):return b.life>0)
 fields=fields.filter(func(f):return f.life>0)
 summons=summons.filter(func(s):return s.life>0)
 visuals=visuals.filter(func(v):return v.life>0)
 if visuals.size()>160:visuals=visuals.slice(visuals.size()-160)
 enemies=enemies.filter(func(e):return not e.dead)

const SAVED_FIELDS=["player","arena_origin","arena_size","obstacles","layout_name","caches","owned","evolutions","enemies","hazards","bullets","fields","summons","visuals","loot","time","combo","combo_until","attack_cd","skill_cd","relic_cd","dash_cd","dash_stock","dash_direction","dash_time","invuln","boost_until","dash_power_until","cast_haste_until","shot_id","trial","deaths","dealt","passive_relic"]
func snapshot() -> Dictionary:
 var state: Dictionary={}
 for field in SAVED_FIELDS:state[field]=get(field)
 state.combat_version=4
 state.sources=damage_sources
 state.rng=str(rng.state)
 return state
func restore(state: Dictionary) -> void:
 evolutions={};arena_origin=Vector2(90,150);arena_size=Vector2(1100,470);caches=[];obstacles=[];layout_name="开阔地"
 for field in SAVED_FIELDS:
  if state.has(field):set(field,state[field])
 if not state.has("evolutions") and int(player.get("evolution",0)) in [1,2]:evolutions[weapon.id]=int(player.evolution)
 geometry.configure(arena_bounds(),obstacles)
 if not player.has("velocity"):motion.reset(player)
 if not player.has("action_schema"):role.reset(self)
 player.evolution=0
 damage_sources=state.get("sources",{})
 rng.state=int(state.get("rng",str(rng.state)))
 rebuild_effects()

func recall() -> int:
 var count: int=0
 for shot in bullets:
  if shot.get("friendly",true) and shot["return"] and not shot.back and shot.life>0:
   shot.back=true;shot.hit=[];shot.manual_recall=true;shot.damage*=float(shot.get("back_power",1.0));count+=1
 if count>0:presentation.emit(self,"recall",player.pos,Vector2.RIGHT,70,.35);feedback.emit("skill",player.pos,0)
 return count

