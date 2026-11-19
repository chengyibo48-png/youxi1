extends RefCounted
const Kit = preload("res://scripts/character_combat_kit.gd")
const Traits = preload("res://scripts/role_traits.gd")
const Weapons = preload("res://scripts/weapon_arts.gd")
const Abilities = preload("res://scripts/ability_actions.gd")
const Geometry = preload("res://scripts/action_geometry.gd")

func busy(c) -> bool:
 return not c.player.get("action",{}).is_empty()

func can_cancel(c) -> bool:
 var a: Dictionary=c.player.get("action",{})
 if not a.is_empty() and a.kind=="skill" and a.definition.get("effect","")=="heal":return a.elapsed>=a.windup+.15
 return a.is_empty() or float(a.elapsed)>=float(a.cancel_at)

func reset(c) -> void:
 c.player.action={};c.player.seals=[];c.player.delayed=[];c.player.last_action={}
 c.player.stationary=0.0;c.player.still=0.0;c.player.precise_until=0.0;c.player.action_schema=4
 c.player.hit_history=[];c.player.sand_shadow=c.player.pos;c.player.guard_until=0.0

func begin(c, kind: String, direction: Vector2, definition: Dictionary={}, heavy: bool=false, charge: float=0.0) -> bool:
 if busy(c):
  var previous: Dictionary=c.player.action
  if kind!="attack" or heavy or previous.kind!="attack" or previous.heavy or previous.combo>=3 or previous.elapsed<previous.cancel_at:return false
  c.player.last_action=previous.duplicate(true);c.player.action={}
 if c.player.hp<=0 or c.dash_time>0 or c.player.get("skill_left",0)>0:return false
 var d: Vector2=direction.normalized() if direction.length_squared()>.001 else c.player.get("facing",Vector2.RIGHT)
 var next_combo: int=(c.combo%3+1) if c.time<c.combo_until else 1
 var kit=Kit.for_hero(c.hero.id)
 var spec=kit.action(next_combo,heavy)
 var cost: float=0.0
 if kind!="attack":
  cost=float(definition.get("cost",80 if kind=="ultimate" else 20))
  if c.player.resource<cost and (not c.has("blood") or kind=="ultimate" or c.player.hp<=cost+1):return false
  Abilities.apply(spec,c.hero.id,kind,definition)
 if heavy and kind=="attack" and c.has("heavy_line"):spec.windup+=.06
 var weapon_haste: float=1.0
 var haste: float=clampf(weapon_haste,.75,1.25)*maxf(.6,1+c.value("haste")+(c.value("cast_haste") if c.time<c.cast_haste_until else 0))
 var windup: float=spec.windup/haste
 var active: float=spec.active/haste
 var recovery: float=spec.recovery/haste
 if kind!="attack":
  if c.player.resource>=cost:c.resource(-cost)
  else:c.player.hp-=cost
 var empowered: bool=heavy and c.player.resource>=20 and c.hero.id in ["wukong","bajie","bailongma"]
 if empowered:c.resource(-20)
 if kind=="attack":c.combo=next_combo;c.combo_until=c.time+1.25
 var a: Dictionary={"kind":kind,"definition":definition.duplicate(true),"elapsed":0.0,"windup":windup,"active":active,"duration":windup+active+recovery,"cancel_at":windup+active,"combo":next_combo,"heavy":heavy,"charge":charge,"direction":d,"origin":c.player.pos,"hits":[],"resolved":false,"shape":spec.geometry_kind,"reach":spec.reach*(1+c.value("reach")),"width":spec.width,"clip":spec.clip,"empowered":empowered,"previous_tip":c.player.pos,"damage":float(c.weapon.damage)*(2.2+charge if heavy else 1.35 if next_combo==3 else 1.0)}
 if kind=="attack":Weapons.configure(c,a)
 if kind=="attack" and c.time<c.player.get("weapon_followup_until",0):a.reach+=c.player.get("weapon_followup_reach",0);c.player.weapon_followup_until=0
 if kind=="attack" and c.evolution()==1:a.damage*=.9;a.duration*=.88;a.cancel_at*=.88;a.windup*=.88;a.active*=.88
 elif kind=="attack" and c.evolution()==2:a.reach*=1.2;a.damage*=1.12;a.duration*=1.12;a.cancel_at*=1.12;a.windup*=1.12;a.active*=1.12
 if heavy:a.damage*=1+c.value("hero_heavy_power")+(.5 if empowered else 0)+(.25 if c.has("immovable") else 0)
 if heavy and c.has("combo_charge") and c.player.get("combo_charge",false):a.damage*=1.4+.2*c.value("combo_charge");c.player.combo_charge=false
 if next_combo==3 and c.has("combo_charge"):c.player.combo_charge=true
 if c.time<c.player.get("precise_until",0) and kind=="attack":a.damage*=1.35;c.player.precise_until=0.0
 if kind=="attack" and c.weapon.mode=="slash" and c.time<c.player.get("recall_until",0) and c.player.get("recall_charge",0)>0:
  a.damage*=1+.1*mini(3,int(c.player.recall_charge));c.player.recall_charge=0
 Traits.started(c,a)
 a.role=c.hero.id;a.sweep_scale=float(a.get("sweep_scale",1.0))*(1+c.value("wide"))
 if heavy and kind=="attack":
  if c.has("heavy_line"):a.reach*=1.35
  if c.hero.id=="bailongma" and a.weapon_style=="lance":a.shape="thrust";a.reach*=1.4 if empowered else 1.0
 c.player.action=a
 c.attack_cd=a.duration;c.motion.commit(c.player,d,heavy,next_combo,"ultimate" if kind=="ultimate" else "cast" if kind=="skill" else c.weapon.mode,a.duration)
 c.player.attack_duration=a.duration;c.player.attack_left=a.duration;c.player.pose_clip=a.clip
 c.player.lunge=Vector2.ZERO
 if kind=="ultimate":preload("res://scripts/ultimate_visual.gd").emit(c,a,"prepare")
 return true

func tick(c, dt: float, movement: Vector2) -> void:
 c.player.stationary=float(c.player.get("stationary",0))+dt if movement.length()<.05 else 0.0
 c.player.still=float(c.player.get("still",0))+dt if movement.length()<.05 else 0.0
 if c.hero.id=="tangseng":
  if c.player.stationary>.35:c.resource(dt*3)
  elif movement.length()>.05 and c.player.resource>25:c.resource(-dt*.7)
 if c.hero.id=="bailongma":
  if movement.length()>.1:c.resource(dt*3)
  elif c.player.still>1.0:c.resource(-dt*4)
 if c.hero.id=="bailongma" and c.owns("bailongma_t0") and movement.length()>.1 and c.time>=c.player.get("wake_at",0):
  c.player.wake_at=c.time+.6;c.add_field(c.player.pos,32,5,1.1,"water")
 for seal in c.player.get("seals",[]):seal.life-=dt
 c.player.seals=c.player.get("seals",[]).filter(func(s):return s.life>0)
 if c.hero.id=="tangseng" and (c.has("pulse") or c.owns("tangseng_t4")):
  for i in maxi(0,c.player.seals.size()-1):
   var first: Vector2=c.player.seals[i].pos;var second: Vector2=c.player.seals[i+1].pos
   if not c.geometry.visible(first,second):continue
   for target in c.enemies.duplicate():
    if not target.dead and Geometry2D.get_closest_point_to_segment(target.pos,first,second).distance_to(target.pos)<target.radius+9 and c.time>=target.get("seal_tick",0):
     target.seal_tick=c.time+.5;c.hit(target,8,"连印",false,4)
 if c.player.delayed.size()>32:c.player.delayed=c.player.delayed.slice(0,32)
 for task in c.player.get("delayed",[]).duplicate():
  task.left-=dt
  if task.kind=="clone_melee":preload("res://scripts/clone_replay.gd").tick(c,task,dt)
  if task.left<=0:
   if task.kind=="echo":c.area(task.pos,task.radius,task.damage,task.get("source","迟影"),false,task.get("weapon_style",""),task.get("direction",Vector2.ZERO));art(c,"detonate",task.pos,Vector2.RIGHT,task.radius,.5)
   elif task.kind=="weapon_echo":
    c.area(task.pos,task.radius,task.damage,"兵器迟影",false);Weapons.fx(c,{"weapon_style":task.style,"weapon_id":task.weapon_id,"heavy":false,"combo":1},task.pos,task.dir,task.radius)
   elif task.kind=="chant":c.heal(3*task.get("power",1.0));c.area(task.pos,90,8*task.get("power",1.0),"念诵",false);Traits.chant(c,task.pos)
   elif task.kind=="detonate":
    for e in c.enemies.duplicate():
     if not e.dead and e.uid==task.uid:c.hit(e,task.damage,"印裂",false,20);Traits.detonate(c,e,task.damage)
   elif task.kind=="sand_refund":
    var consumed: int=0
    for enemy in c.enemies:
     if not enemy.dead and enemy.marks>0 and enemy.pos.distance_to(task.pos)<220 and consumed<3:enemy.marks-=1;consumed+=1
    c.resource(consumed*3)
   elif task.kind=="clone":clone_attack(c,task)
   c.player.delayed.erase(task)
 var a: Dictionary=c.player.get("action",{})
 if a.is_empty():return
 var previous_elapsed: float=a.elapsed
 a.elapsed+=dt
 c.player.attack_left=maxf(0,a.duration-a.elapsed)
 c.player.action_phase="windup" if a.elapsed<a.windup else "active" if a.elapsed<a.windup+a.active else "recovery"
 if a.elapsed>=a.windup and not a.resolved:
  a.resolved=true
  if a.kind=="skill":skill_payload(c,a)
  elif a.kind=="ultimate":ultimate_payload(c,a)
  else:attack_payload(c,a)
 if a.kind=="attack" and a.resolved and a.shape!="seal" and previous_elapsed<a.windup+a.active and a.elapsed>=a.windup:
  melee_contact(c,a)
 if a.kind=="skill" and a.resolved and a.definition.effect=="breath" and a.elapsed<a.windup+a.active and c.time>=c.player.get("breath_at",0):
  c.player.breath_at=c.time+.12
  for i in 3:c.shoot(c.player.pos,a.direction.rotated((i-1)*.12),8,{"source":"skill","trigger":false,"pierce":2,"return":false,"speed":390.0,"life":.65,"radius":12.0,"role":"bailongma","visual":"dragon_breath"})
 if a.elapsed>=a.duration:
  if a.kind=="attack":
   c.player.last_action=a.duplicate(true)
   if a.shape!="seal" and a.hits.is_empty():c.feedback.emit("wall" if a.get("wall_hit",false) else "empty",c.player.pos,0)
  c.player.action={};c.player.attack_left=0.0;c.player.action_phase="idle"

func art(c, kind: String, pos: Vector2, direction: Vector2, radius: float=120.0, duration: float=.42) -> void:
 c.visuals.append({"kind":"role_fx","role":c.hero.id,"effect":kind,"pos":pos,"dir":direction,"radius":radius,"life":duration,"max":duration,"color":Color(c.hero.color)})

func delay(c, position: Vector2, damage: float, radius: float, wait: float=.35) -> void:
 if c.player.delayed.size()>=32:return
 c.player.delayed.append({"kind":"echo","left":wait,"pos":position,"damage":damage,"radius":radius})
 art(c,"anticipation",position,Vector2.RIGHT,radius,wait)

func attack_payload(c, a: Dictionary) -> void:
 var pos: Vector2=c.player.pos;var d: Vector2=a.direction
 var role: String=c.hero.id
 Weapons.payload(c,a)
 preload("res://scripts/combo_talents.gd").payload(c,a)
 if (a.shape=="seal" and c.hero.id!="tangseng" or c.hero.id=="tangseng" and not a.heavy) and c.has("fork"):c.shoot(pos+d.orthogonal()*20,d,a.damage*.45,{"trigger":false,"source":"分叉","return":false})
 if c.has("seal_wheel") and c.time<c.player.get("seal_until",0):
  c.player.seal_until=0;c.area(pos,120,a.damage*.55,"法印回轮",false);art(c,"detonate",pos,d,120,.4)
 if c.has("sweep") and a.shape!="seal":c.player.pos=c.geometry.move(pos,d*18)
 if a.heavy:
  c.player.shield=minf(120,c.player.shield+c.value("heavy_shield"))
  if c.has("heavy_ring"):c.area(pos,130,a.damage*.35,"重波",false)
  if c.has("echo") or c.has("mine"):delay(c,pos+d*minf(a.reach*.7,180),a.damage*.5,75,.35 if c.has("echo") else 1.2)
 if a.combo==3 and not a.heavy and c.has("third_crescent"):
  for side in [-1,1]:delay(c,c.geometry.move(pos,d.rotated(side*.7)*90),a.damage*.3,55,.18)
 if c.has("rear"):c.area(pos-d*65,45,a.damage*.35,"背击",false)
 if c.hero.id=="bajie" and c.owns("bajie_t5") and a.empowered:delay(c,c.geometry.move(pos,d*80),a.damage*.3,70,.25)
 c.synergy.trigger(c,"heavy" if a.heavy else "attack",d)
 if a.combo==3 and not a.heavy:c.synergy.trigger(c,"third",d)

func in_lane(origin: Vector2, direction: Vector2, target: Dictionary, length: float, width: float) -> bool:
 var delta: Vector2=target.pos-origin
 return delta.dot(direction)>=-target.radius and delta.dot(direction)<=length+target.radius and absf(delta.cross(direction))<=width+target.radius

func melee_contact(c, a: Dictionary) -> void:
 var origin: Vector2=c.player.pos;var d: Vector2=a.direction
 var progress: float=clampf((a.elapsed-a.windup)/maxf(.01,a.active),0,1)
 var tip: Vector2=Geometry.sample(a,origin,progress).tip
 var previous: Vector2=a.previous_tip if a.elapsed>a.windup else origin
 for e in c.enemies.duplicate():
  if e.dead or e.uid in a.hits:continue
  if not c.geometry.visible(origin,e.pos):
   if e.pos.distance_to(origin)<a.reach+e.radius:a.wall_hit=true
   continue
  var contact: bool=Geometry2D.get_closest_point_to_segment(e.pos,origin,tip).distance_to(e.pos)<e.radius+a.width or Geometry2D.get_closest_point_to_segment(e.pos,previous,tip).distance_to(e.pos)<e.radius+a.width
  if a.shape=="spin" or c.has("spin") and a.combo==3 and not a.heavy:contact=e.pos.distance_to(origin)<a.reach+e.radius
  if contact:
   a.hits.append(e.uid);c.hit(e,a.damage,"heavy" if a.heavy else "attack",true,32 if a.heavy else 12)
   if c.hero.id=="wukong" and c.owns("wukong_t2") and a.heavy:e.slow=maxf(e.slow,1);c.hit(e,0,"镇棍破势",false,15);art(c,"freeze",e.pos,d,40,.4)
   var displacement: Vector2=d*(24 if a.heavy else 8)
   if c.hero.id=="bajie" and c.owns("bajie_t4") and a.combo==3:displacement=(origin-e.pos).normalized()*38
   if c.hero.id=="bajie" and a.combo==3 and int(str(c.weapon.id).right(1))%2==1:displacement=(origin-e.pos).normalized()*45
   e.pos=c.geometry.move(e.pos,displacement*(.15 if e.kind=="boss" else 1),e.radius)
   if c.hero.id=="wukong":
    c.resource(4 if a.combo==3 else 2)
    if c.owns("wukong_t4") and a.combo==3:e.mark=2
    if c.owns("wukong_t5") and a.heavy:c.resource(4)
    if c.owns("wukong_t1") and a.combo==3 and not a.heavy and c.player.delayed.size()<32:
     c.player.delayed.append({"kind":"clone","left":.2,"pos":origin+d.orthogonal()*45,"action":a.duplicate(true)})
   elif c.hero.id=="shaseng" and not a.heavy:e.marks=mini(6,e.marks+(1+int(ceil(c.value("hero_sand_gain")*5)) if c.owns("shaseng_t0") else 1));c.resource(5 if c.owns("shaseng_t5") and a.combo==3 else 2)
   elif c.hero.id=="bajie" and c.owns("bajie_t3") and a.combo==3:c.heal(2)
   elif c.hero.id=="bailongma":e.dragon_mark=c.time+3;c.resource(5 if a.combo==3 else 2)
 a.previous_tip=tip
 if c.hero.id in ["wukong","bailongma"] and not a.heavy:
  c.player.pos=c.geometry.move(c.player.pos,d*(15 if c.hero.id=="bailongma" else 7)*c.get("role_step_dt"))

func place_seal(c, position: Vector2, radius: float) -> void:
 if c.player.seals.size()>=6:c.player.seals.pop_front()
 c.player.seals.append({"pos":position,"radius":radius*(1.5 if c.has("domain") else 1),"life":7.0*(1+c.value("field_time"))})
 if c.owns("tangseng_t0"):c.player.shield=minf(100,c.player.shield+4*(1+c.value("hero_shield_gain")))
 art(c,"seal",position,Vector2.RIGHT,radius,.5)

func controlled(c, e: Dictionary, duration: float) -> void:
 if e.kind=="boss":e.slow=maxf(e.slow,duration);c.hit(e,0,"破势",false,25)
 else:e.root=maxf(e.root,duration*(1+c.value("hero_control_time")))

func clone_attack(c, task: Dictionary) -> void:
 var a: Dictionary=task.action.duplicate(true)
 var pos: Vector2=task.pos;var d: Vector2=a.get("direction",Vector2.RIGHT)
 var damage: float=float(a.get("damage",20))*.55*(1+c.value("hero_summon_power"))*task.get("power",1.0)
 a.merge({"heavy":false,"combo":1,"weapon_id":c.weapon.id,"shape":"thrust","direction":d,"reach":135.0},false)
 preload("res://scripts/clone_replay.gd").start(c,a,pos,damage)
 if a.has("weapon_style"):Weapons.fx(c,a,pos,d,float(a.get("reach",135)))
 match a.get("weapon_style",""):
  "pin","phantom":
   for i in (3 if a.get("heavy",false) else 2):
    var at: Vector2=c.geometry.move(pos,d*(75+i*65)+d.orthogonal()*(0 if a.weapon_style=="pin" else (i*2-1)*25))
    if c.player.delayed.size()<32:c.player.delayed.append({"kind":"echo","source":"分身复招","weapon_style":a.weapon_style,"direction":d,"left":.1+i*.12,"pos":at,"damage":damage*.65,"radius":34.0 if a.weapon_style=="pin" else 50.0})
    Weapons.fx(c,a,at,d,45)
   return
  "flame":
   c.shoot(pos,d,damage,{"source":"分身复招","trigger":false,"return":false,"speed":330.0,"visual":"ember","weapon_style":"flame","weapon_id":a.weapon_id})
   c.add_field(c.geometry.move(pos,d*100),42,damage*.22,1.1,"fire")
   return
  "disc":
   for sign in [-1,1]:c.shoot(pos,d.rotated(sign*.25),damage*.6,{"source":"分身复招","trigger":false,"return":true,"turn_after":.35,"pierce":3,"weapon_style":"disc","weapon_id":a.weapon_id})
   return
 # Melee replay resolves contact during its own active phase, not all directions at once.

func skill_payload(c, a: Dictionary) -> void:
 var effect: String=a.definition.effect;var d: Vector2=a.direction;var pos: Vector2=c.player.pos
 var power: float=1.35 if a.definition.get("branch",0)==1 else 1.0
 var display_direction: Vector2=d.orthogonal() if c.hero.id=="bailongma" and effect=="evade" else -d if c.hero.id=="bajie" and effect=="slam" else d
 art(c,effect,pos,display_direction,180,.65)
 c.feedback.emit("skill",pos,0)
 Weapons.synergy(c,a)
 if preload("res://scripts/content_extension.gd").skill(c,a):
  if c.has("cast_echo"):delay(c,pos,14+6*c.value("cast_echo"),70+10*c.value("cast_echo"),.3)
  if c.has("purify"):c.player.poison=0;c.player.burn=0;c.resource(2*c.value("purify"))
  if c.has("seal_wheel"):c.player.seal_until=c.time+3
  c.synergy.trigger(c,"skill",a.direction);c.changed.emit();return
 match c.hero.id:
  "wukong":
   match effect:
    "summon":
     var previous: Dictionary=c.player.last_action if not c.player.last_action.is_empty() else {"direction":d,"reach":135.0,"damage":float(c.weapon.damage),"combo":1}
     for i in 2:
      if c.player.delayed.size()<32:c.player.delayed.append({"kind":"clone","left":.15+i*.2,"pos":c.geometry.move(pos,d.orthogonal()*(55 if i==0 else -55)),"action":previous.duplicate(true),"power":power})
    "dash":movement_skill(c,d,850,55*power,.34);delay(c,c.geometry.move(pos,d*220),45*power,95,.32)
    "freeze":
     for e in c.enemies.duplicate():
      if not e.dead and e.pos.distance_to(pos)<250 and c.geometry.visible(pos,e.pos):controlled(c,e,1.7);c.hit(e,12*power,"skill",false,15)
    "lunge":movement_skill(c,d,1100,45*power,.22)
    "mark":
     for e in c.enemies:
      if not e.dead and in_lane(pos,d,e,400,140) and c.geometry.visible(pos,e.pos):e.mark=7*power
    "orbit":c.player.guard_until=c.time+1.0*power;c.player.orbit_until=c.time+5*power
  "tangseng":
   match effect:
    "heal":
     for i in 5:c.player.delayed.append({"kind":"chant","left":.2+i*.4,"pos":pos,"power":power})
    "convert":
     var e: Dictionary=c.nearest(pos)
     if not e.is_empty() and pos.distance_to(e.pos)<280 and c.geometry.visible(pos,e.pos):
      if e.kind=="boss":c.hit(e,45*power,"skill",false,45)
      else:e.root=4*power;c.summons.append({"pos":e.pos,"life":4.0*(1+c.value("hero_summon_time")),"cd":0.0,"damage":15.0*power,"non_recursive":true})
    "beam":
     if c.player.seals.size()<2:place_seal(c,c.geometry.move(pos,d*100),60);place_seal(c,c.geometry.move(pos,d*280),60)
     for i in c.player.seals.size()-1:
      var p: Vector2=c.player.seals[i].pos;var end: Vector2=c.player.seals[i+1].pos
      if not c.geometry.visible(p,end):continue
      for e in c.enemies.duplicate():
       if not e.dead and Geometry2D.get_closest_point_to_segment(e.pos,p,end).distance_to(e.pos)<e.radius+20:c.hit(e,48*power,"skill",false,20)
      art(c,"link",p,(end-p).normalized(),p.distance_to(end),.65)
    "sanctuary":place_seal(c,pos,135);c.add_field(pos,135,12*power,5,"sanctuary")
    "counter":c.player.parry_until=c.time+.8*power;place_seal(c,pos,65)
    "pull":
     for e in c.enemies.duplicate():
      if not e.dead and in_lane(pos,d,e,280,90) and c.geometry.visible(pos,e.pos):e.pos=c.geometry.move(e.pos,(pos+d*100-e.pos)*(.08 if e.kind=="boss" else .45),e.radius);c.hit(e,18*power,"skill",false,12);art(c,"link",pos,(e.pos-pos).normalized(),pos.distance_to(e.pos),.5)
  "bajie":
   match effect:
    "shield":c.player.guard_until=c.time+1.2;c.player.shield=minf(150,c.player.shield+25*power*(1+c.value("hero_shield_gain")))
    "slam":
     c.player.pos=c.geometry.move(pos,-d*55)
     for e in c.enemies.duplicate():
      if not e.dead and in_lane(pos,-d,e,170,100):c.hit(e,65*power,"skill",false,35)
     art(c,"back_rake",pos,-d,170,.6)
    "quake":
     for i in 3:delay(c,c.geometry.move(pos,d*(70+i*95)),30*power,80,.15+i*.22)
    "charge":movement_skill(c,d,680,55*power,.44)
    "pull":
     for e in c.enemies.duplicate():
      if not e.dead and in_lane(pos,d,e,290,55) and c.geometry.visible(pos,e.pos):e.pos=c.geometry.move(e.pos,(pos+d*55-e.pos)*(.10 if e.kind=="boss" else minf(.9,.75+c.value("hero_pull_power"))),e.radius);c.hit(e,32*power,"skill",false,30)
    "resource":c.heal(15*power);c.player.shield+=8
  "shaseng":
   match effect:
    "sand":
     var previous_count: int=c.fields.size();c.add_field(pos,130,12*power,5,"sand")
     if c.fields.size()>previous_count:c.fields.back().velocity=d*55
    "wave":c.shoot(pos,d,38*power,{"return":true,"pierce":8,"speed":440.0,"turn_after":.5,"life":2.2,"visual":"crescent","source":"skill","trigger":false,"role":"shaseng","carry_marks":true})
    "fan":
     for i in 5+int(round(c.value("hero_extra_skill_shots")*10)):c.shoot(pos,d.rotated((i-2)*.22),18*power,{"return":false,"pierce":1,"source":"skill","trigger":false,"role":"shaseng","visual":"sand_shard","apply_marks":true})
    "root":
     var marked: Array=c.enemies.filter(func(e):return not e.dead and e.marks>0 and e.pos.distance_to(pos)<400 and c.geometry.visible(pos,e.pos))
     for e in marked:controlled(c,e,1.3*power);art(c,"bind",e.pos,d,45,.7)
     for i in maxi(0,marked.size()-1):art(c,"link",marked[i].pos,(marked[i+1].pos-marked[i].pos).normalized(),marked[i].pos.distance_to(marked[i+1].pos),.7)
    "blink":
     var previous: Vector2=c.player.get("sand_shadow",pos)
     c.player.sand_shadow=pos;c.player.pos=c.clamp_actor(previous) if previous.distance_to(pos)>30 else c.geometry.move(pos,d*230)
     c.invuln=.25;c.player.precise_until=c.time+2*power
    "detonate":
     for e in c.enemies.duplicate():
      if not e.dead and e.marks>0 and e.pos.distance_to(pos)<500 and c.geometry.visible(pos,e.pos):
       var marks: int=e.marks;e.marks=0
       for i in marks:
        if c.player.delayed.size()<32:c.player.delayed.append({"kind":"detonate","left":.08+i*.09,"uid":e.uid,"damage":12*power*(1+c.value("sand_damage")+c.value("hero_sand_damage"))})
  "bailongma":
   match effect:
    "wave":
     c.fields.append({"pos":pos,"radius":70.0,"damage":22*power,"life":1.8,"kind":"wave","tick":0.0,"velocity":d*270})
     movement_skill(c,d,700,22*power,.25)
    "dragon":movement_skill(c,d,1150,70*power,.32);c.boost_until=c.time+4*(1+c.value("hero_buff_time"))
    "breath":
     for i in 5:c.shoot(pos,d.rotated((i-2)*.1),22*power,{"source":"skill","trigger":false,"pierce":3,"return":false,"speed":390.0,"life":1.0,"radius":14.0,"role":"bailongma","visual":"dragon_breath"})
    "evade":
     movement_skill(c,d.orthogonal(),950,30*power,.20);c.recall();c.player.precise_until=c.time+2
     if c.owns("bailongma_t3"):c.player.recall_charge=mini(3,int(c.player.get("recall_charge",0))+1);c.player.recall_until=c.time+2
    "waterwall":
     c.player.shield=minf(100,c.player.shield+6*power*(1+c.value("hero_shield_gain")))
     for i in 3:c.fields.append({"pos":c.geometry.move(pos,d*(50+i*65)),"radius":45.0,"damage":0.0,"life":3.0,"kind":"waterwall","tick":0.0})
    "pursue":
     var target: Dictionary={}
     for e in c.enemies:
      if not e.dead and c.time<e.get("dragon_mark",0) and e.pos.distance_to(pos)<400 and c.geometry.visible(pos,e.pos):target=e;break
     if not target.is_empty():movement_skill(c,(target.pos-pos).normalized(),1050,60*power,.25)
     else:c.shoot(pos,d,35*power,{"source":"skill","trigger":false,"homing":true,"return":false,"visual":"sword","role":"bailongma"})
 if c.has("cast_echo"):delay(c,pos,14+6*c.value("cast_echo"),70+10*c.value("cast_echo"),.3)
 if c.has("purify"):c.player.poison=0;c.player.burn=0;c.resource(2*c.value("purify"))
 if c.has("seal_wheel"):c.player.seal_until=c.time+3
 c.synergy.trigger(c,"skill",d);c.changed.emit()

func movement_skill(c, d: Vector2, speed: float, damage: float, duration: float) -> void:
 if not c.player.action.is_empty():c.player.action.direction=d
 c.player.facing=d;c.player.attack_direction=d
 c.player.skill_left=duration;c.player.skill_direction=d;c.player.skill_speed=speed;c.player.skill_damage=damage;c.player.skill_hits=[]
 c.invuln=minf(.25,duration)

func ultimate_payload(c, a: Dictionary) -> void:
 var effect: String=a.definition.effect;var pos: Vector2=c.player.pos;var d: Vector2=a.direction
 art(c,effect,pos,d,320,1.0);preload("res://scripts/ultimate_visual.gd").emit(c,a,"release");c.feedback.emit("ultimate",pos,0)
 preload("res://scripts/content_extension.gd").ultimate(c,a)
 match effect:
  "giant":
   for e in c.enemies.duplicate():
    if not e.dead and in_lane(pos,d,e,460,85) and c.geometry.visible(pos,e.pos):c.hit(e,170,"绝技",false,90)
  "avatars":
   var previous: Dictionary=c.player.last_action if not c.player.last_action.is_empty() else {"damage":80.0,"reach":180.0,"direction":d}
   for i in 6:c.player.delayed.append({"kind":"clone","left":i*.18,"pos":c.geometry.move(pos,d.orthogonal()*((i%3)-1)*60),"action":previous.duplicate(true)})
  "purification":
   for i in 3:place_seal(c,c.geometry.move(pos,d.rotated((i-1)*1.5)*90),140)
   c.player.poison=0;c.player.burn=0;c.heal(25);c.add_field(pos,220,25,5,"sanctuary")
  "chant":
   for i in 8:c.player.delayed.append({"kind":"echo","left":i*.15,"pos":c.geometry.move(pos,d*(45+i*45)),"damage":28.0,"radius":70.0})
  "marshal":c.player.guard_until=c.time+1.5;c.player.shield+=50;c.area(pos,180,120,"绝技",false)
  "quakes":c.boost_until=c.time+8;c.resource(25);c.player.guard_until=c.time+.6
  "sandstorm":
   c.add_field(pos,230,22,7,"sand")
   for e in c.enemies:
    if not e.dead and e.pos.distance_to(pos)<280:e.marks=mini(6,e.marks+3)
  "sandburst":
   for i in 6:c.shoot(pos,d.rotated(i*TAU/6),38,{"source":"绝技","return":true,"pierce":8,"trigger":false,"speed":450.0,"turn_after":.65,"life":2.4,"role":"shaseng","visual":"crescent","carry_marks":true})
  "dragonflight":movement_skill(c,d,1200,150,.42);c.invuln=.42
  "tide":
   for i in 8:c.shoot(pos,Vector2.RIGHT.rotated(i*TAU/8),40,{"source":"绝技","trigger":false,"return":true,"speed":650.0,"turn_after":.45,"life":2.0,"pierce":3,"visual":"sword","role":"bailongma"})
   c.player.recall_until=c.time+4;c.player.recall_charge=3
 Weapons.synergy(c,a)
 c.synergy.trigger(c,"ultimate",d)

func skill_reason(c, definition: Dictionary, slot: int) -> String:
 if c.player.hp<=0:return "角色已倒下"
 if definition.is_empty() or definition.get("hero","")!=c.hero.id:return "非本角色神通"
 if slot<0 or slot>=2:return "无效技能槽"
 if c.skill_cd[slot]>0:return "调息 %.1fs"%c.skill_cd[slot]
 if busy(c) or c.dash_time>0:return "招式执行中"
 var cost: float=float(definition.cost)
 if c.player.resource<cost and (not c.has("blood") or c.player.hp<=cost+1):return "资源不足：需%d"%cost
 if definition.effect in ["root","detonate"] and c.hero.id=="shaseng":
  var range_limit: float=400.0 if definition.effect=="root" else 500.0
  if not c.enemies.any(func(e):return not e.dead and e.marks>0 and e.pos.distance_to(c.player.pos)<range_limit and c.geometry.visible(c.player.pos,e.pos)):return "附近没有流沙印目标"
 if definition.effect=="heal" and c.player.hp>=c.player.max_hp and c.enemies.is_empty():return "生命已满且没有目标"
 return ""
