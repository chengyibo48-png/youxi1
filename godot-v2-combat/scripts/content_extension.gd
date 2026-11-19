extends RefCounted
# Secondary attacks do not produce recursive triggers or extra rewards.
static func shot(c,pos: Vector2,d: Vector2,damage: float,style: String,visual: String,options: Dictionary={}) -> void:
 var config={"source":"派生术式","trigger":false,"return":true,"turn_after":.45,"life":1.8,"speed":500.0,"pierce":3,"weapon_style":style,"visual":visual,"role":c.hero.id}
 config.merge(options,true);c.shoot(pos,d,damage,config)
static func clear_bullets(c,pos: Vector2,radius: float) -> void:
 for b in c.bullets:
  if not b.get("friendly",true) and b.pos.distance_to(pos)<radius:b.life=0
static func picture(c,style: String,pos: Vector2,d: Vector2,radius: float,life: float=.8) -> void:
 c.visuals.append({"kind":"role_fx","effect":"weapon","role":c.hero.id,"weapon_style":style,"weapon_id":c.weapon.id,"heavy":true,"combo":1,"pos":pos,"dir":d,"radius":radius,"life":life,"max":life,"color":Color(c.hero.color)})
static func skill(c,a: Dictionary) -> bool:
 var p: Vector2=c.player.pos;var d: Vector2=a.direction;var power: float=1.35 if a.definition.get("branch",0)==1 else 1.0
 match a.definition.effect:
  "windwheel":
   for i in 3:shot(c,p,d.rotated((i-1)*.4),22*power,"disc","disc")
   picture(c,"disc",p,d,150)
  "wake_bell":
   clear_bullets(c,p,200);c.area(p,200,24*power,"梵钟",false)
   for e in c.enemies:
    if not e.dead and e.pos.distance_to(p)<200:c.role.controlled(c,e,.65)
   picture(c,"bell",p,d,200)
  "rake_wall":
   for i in 3:
    c.add_field(c.geometry.move(p,d*85+d.orthogonal()*(i-1)*60),42,0,3,"rake_wall")
   c.player.shield=minf(150,c.player.shield+12*power);picture(c,"gate_shield",p+d*85,d,100,1.0)
  "sand_guardian":
   if c.summons.size()<12:c.summons.append({"pos":p,"life":5.0,"cd":0.0,"damage":18*power,"stationary":true,"non_recursive":true,"apply_marks":true,"visual":"sand_shard","role":"shaseng","weapon_style":"shards"})
   picture(c,"sand_seal",p,d,80,1.0)
  "arrow_rain":
   for i in 4:shot(c,p+d.orthogonal()*(i-1.5)*40,d,22*power,"tide_bow","water_arrow",{"speed":650.0})
   picture(c,"tide_bow",p,d,240)
  _:return false
 return true
static func ultimate(c,a: Dictionary) -> void:
 var p: Vector2=c.player.pos;var d: Vector2=a.direction
 match a.definition.effect:
  "ring_storm":
   for i in 12:shot(c,p,Vector2.RIGHT.rotated(i*TAU/12),32,"disc","disc",{"turn_after":.65,"pierce":6})
  "golden_city":
   for i in 4:
    var point: Vector2=c.geometry.move(p,Vector2.RIGHT.rotated(PI*.25+i*PI*.5)*110)
    c.role.place_seal(c,point,90);c.add_field(point,80,0,5,"waterwall")
   c.add_field(p,170,16,5,"sanctuary");c.player.shield=minf(150,c.player.shield+25)
  "mountain_rake":
   for row in 3:
    for col in 3:c.role.delay(c,c.geometry.move(p,d*(70+row*90)+d.orthogonal()*(col-1)*90),60,65,.1+row*.22)
  "mark_collapse":
   for e in c.enemies.duplicate():
    if not e.dead and e.pos.distance_to(p)<400 and c.geometry.visible(p,e.pos):
     if e.marks>0:
      var damage: float=35+e.marks*24;e.marks=0;c.role.delay(c,e.pos,damage,65,.2)
     else:e.marks=mini(6,e.marks+3)
  "sky_bow":
   for i in 9:shot(c,p,d.rotated((i-4)*.16),45,"tide_bow","water_arrow",{"speed":720.0,"pierce":6,"turn_after":.65,"life":2.1})
   c.player.recall_until=c.time+4;c.player.recall_charge=3
static func relic_reason(c,effect: String) -> String:
 if effect=="relic_recall" and not c.bullets.any(func(b):return b.get("friendly",true) and b["return"] and b.life>0):return "没有可召回的兵器"
 if effect=="relic_lotus" and c.trial=="noheal":return "本试炼不能回复生命"
 if effect=="relic_lotus" and c.player.hp>=c.player.max_hp and c.player.poison<=0 and c.player.burn<=0:return "生命已满且没有异常"
 if effect=="relic_hourglass" and not c.enemies.any(func(e):return not e.dead and e.pos.distance_to(c.player.pos)<240 and c.geometry.visible(c.player.pos,e.pos)):return "附近没有可布印目标"
 if effect=="relic_bell" and not c.enemies.any(func(e):return not e.dead and e.pos.distance_to(c.player.pos)<180) and not c.bullets.any(func(b):return not b.get("friendly",true) and b.life>0 and b.pos.distance_to(c.player.pos)<180):return "范围内没有敌人或敌弹"
 return ""
static func relic(c,effect: String,d: Vector2,factor: float) -> void:
 var p: Vector2=c.player.pos
 match effect:
  "relic_recall":c.recall();c.resource(8);picture(c,"disc",p,d,100)
  "relic_lotus":c.player.poison=0;c.player.burn=0;c.add_field(p,90,0,4,"lotus");picture(c,"lotus_lantern",p,d,90,1.0)
  "relic_bell":clear_bullets(c,p,180);c.area(p,180,20*factor,"铜钟",false);picture(c,"bell",p,d,180)
  "relic_hourglass":
   for e in c.enemies:
    if not e.dead and e.pos.distance_to(p)<240 and c.geometry.visible(p,e.pos):e.marks=mini(6,e.marks+2);e.slow=maxf(2,e.slow)
   picture(c,"tether",p,d,200)
  "relic_quiver":
   for i in 6:shot(c,p,d.rotated((i-2.5)*.2),18*factor,"tide_bow","water_arrow")
static func passive(c,effect: String,d: Vector2) -> void:
 var p: Vector2=c.player.pos
 match effect:
  "relic_recall":shot(c,p,d,10,"disc","disc")
  "relic_lotus":c.heal(2)
  "relic_bell":c.area(p,100,12,"铜钟共鸣",false)
  "relic_hourglass":
   for e in c.enemies:
    if not e.dead and e.pos.distance_to(p)<180 and c.geometry.visible(p,e.pos):e.marks=mini(6,e.marks+1)
  "relic_quiver":shot(c,p,d,10,"tide_bow","water_arrow",{"return":false})

