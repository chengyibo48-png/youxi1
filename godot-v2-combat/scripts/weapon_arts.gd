extends RefCounted
# One stable kit per weapon. Neither parity nor character colour chooses the attack.
const KITS={
 "wukong_w0":["伸缩棍","extend",[.08,.13,.13],160.0,"arc","thrust","踏步横扫，第三击伸棍；重击贯穿长线"],
 "wukong_w1":["定海钉","pin",[.18,.08,.22],320.0,"seal","seal","连点三道金钉；重击沿瞄准线逐段落柱"],
 "wukong_w2":["火云推浪","flame",[.15,.12,.2],230.0,"seal","seal","推出火云；重击铺设三道持续火路"],
 "wukong_w3":["双棍交织","dual",[.06,.16,.1],110.0,"arc","spin","左右短棍交织，第三击补交叉棍影；重击绕身旋击"],
 "wukong_w4":["幽影接力","phantom",[.12,.08,.23],210.0,"seal","seal","远处棍影延迟接力；重击三影合击"],
 "tangseng_w0":["锡杖落印","stamp",[.12,.08,.2],230.0,"seal","seal","念珠点射，后两击落印；重击引爆已布法印"],
 "tangseng_w1":["法轮切线","mandala",[.18,.1,.22],270.0,"seal","seal","法轮横向切线；重击纵横交织法轮阵"],
 "tangseng_w2":["金铙回旋","rosary",[.08,.1,.16],220.0,"seal","seal","金铙抛出并返回；重击收铙，转为绕身护持"],
 "tangseng_w3":["念珠结阵","scripture",[.18,.08,.19],220.0,"seal","seal","念珠远射布双印；重击印间经文连爆"],
 "tangseng_w4":["钟鸣共振","bell",[.23,.12,.23],175.0,"seal","seal","钟鸣从身前扩散；重击三次相隔共振"],
 "bajie_w0":["九齿拖耙","rake",[.18,.19,.24],125.0,"arc","thrust","耙击后横拖；第三击踏地，重击勾摔"],
 "bajie_w1":["飞耙牵引","hook",[.14,.08,.22],260.0,"seal","seal","飞耙往返牵引；重击双向勾回"],
 "bajie_w2":["翻土犁沟","furrow",[.24,.08,.24],260.0,"seal","seal","沿地面逐段翻土；重击三叉犁沟"],
 "bajie_w3":["冰锤立柱","ice_hammer",[.23,.12,.24],150.0,"seal","seal","锤落身前冰圈；重击依次升起冰柱"],
 "bajie_w4":["天蓬流星","meteor",[.2,.2,.23],130.0,"spin","seal","链球绕身扫击；重击投掷回旋流星"],
 "shaseng_w0":["降妖刺切","crescent_staff",[.1,.13,.17],165.0,"thrust","thrust","直刺与月牙切割交替；重击定向消耗流沙印"],
 "shaseng_w1":["月刃搬印","crescent",[.12,.08,.18],300.0,"seal","seal","月刃飞出收印、回来转印；重击双月交错"],
 "shaseng_w2":["碎砂双刃","shards",[.07,.1,.14],240.0,"seal","seal","碎砂交叉飞射并布印；重击散射沙刃"],
 "shaseng_w3":["镇沙法印","sand_seal",[.2,.09,.21],210.0,"seal","seal","逐招铺沙阵；重击消耗印记并连爆沙阵"],
 "shaseng_w4":["双月刃轮转","twin_moon",[.12,.13,.2],240.0,"seal","seal","双月从两侧回返；重击四月绕身封锁"],
 "bailongma_w0":["龙角穿刺","lance",[.055,.11,.13],170.0,"thrust","thrust","连续挺枪穿身；重击踏浪突进"],
 "bailongma_w1":["踏浪回剑","wave_sword",[.08,.09,.15],280.0,"seal","seal","水剑外放返回；重击召回并推出宽浪"],
 "bailongma_w2":["寒刃冰扇","frost_sword",[.08,.13,.17],140.0,"arc","seal","短切伴随冰刃；重击五刃冻结扇面"],
 "bailongma_w3":["雷劫瞬剑","thunder",[.1,.08,.16],240.0,"seal","seal","雷光定向刺；第三击追身，重击多点落雷"],
 "bailongma_w4":["七星御剑","stars",[.15,.1,.19],300.0,"seal","seal","七星按连段逐步放出；重击七剑合流"],
 "wukong_w5":["金刚飞环", "disc", [0.14, 0.09, 0.19], 280, "seal", "seal", "金环往返贯穿；重击三环分向回收，管理回程命中"],
 "tangseng_w5":["照夜莲灯", "lotus_lantern", [0.24, 0.1, 0.24], 240, "seal", "seal", "在瞄准点点亮莲灯，靠近灯阵回复；重击三灯成列"],
 "bajie_w5":["山门巨盾", "gate_shield", [0.18, 0.2, 0.26], 125, "thrust", "seal", "举盾顶撞获得短格挡；重击消耗最多8护盾转为震击"],
 "shaseng_w5":["缚妖沙索", "tether", [0.16, 0.11, 0.21], 300, "seal", "seal", "飞索缚敌布印并牵引；重击定向引爆流沙印"],
 "bailongma_w5":["潮汐长弓", "tide_bow", [0.22, 0.09, 0.22], 350, "seal", "seal", "后撤放出穿透水箭；重击五箭扇射，需要保持射距"]
}

static func configure(c,a: Dictionary) -> void:
 var kit: Array=KITS[c.weapon.id]
 a.weapon_id=c.weapon.id;a.weapon_style=kit[1];a.shape=kit[5] if a.heavy else kit[4]
 a.reach=float(kit[3])*(1+c.value("reach"))
 if a.heavy:a.reach*=1.25
 var times: Array=kit[2];var haste: float=clampf(1+c.value("haste")+(c.value("cast_haste") if c.time<c.cast_haste_until else 0),.65,2.0)/(1.2 if c.has("domain") else 1.0)
 a.windup=(float(times[0])*(1.7 if a.heavy else 1)+( .06 if a.heavy and c.has("heavy_line") else 0))/haste
 a.active=float(times[1])*(1.4 if a.heavy else 1)/haste;a.duration=a.windup+a.active+float(times[2])*(1.35 if a.heavy else 1)/haste
 a.cancel_at=a.windup+a.active;a.clip="weapon_"+kit[1]
 if a.weapon_style=="extend" and a.combo==3:a.shape="thrust";a.reach*=1.3
 if a.weapon_style=="crescent_staff" and a.combo==2:a.shape="arc"
 if a.weapon_style=="rake" and a.combo==3:a.shape="spin"
 a.sweep_scale=1.3 if a.weapon_style=="dual" else 1.0
 preload("res://scripts/weapon_combo.gd").configure(a)

static func fx(c,a: Dictionary,pos: Vector2,direction: Vector2,radius: float,style: String="",duration: float=.5) -> void:
 c.visuals.append({"kind":"role_fx","role":c.hero.id,"effect":"weapon","weapon_style":a.weapon_style if style=="" else style,"weapon_id":a.weapon_id,"heavy":a.heavy,"combo":a.combo,"shape":a.get("shape","seal"),"pos":pos,"dir":direction,"radius":radius,"life":duration,"max":duration,"color":Color(c.hero.color)})

static func shot(c,a: Dictionary,pos: Vector2,d: Vector2,damage: float,visual: String,options: Dictionary={}) -> void:
 var config={"role":c.hero.id,"visual":visual,"weapon_style":a.weapon_style,"weapon_id":a.weapon_id,"source":"heavy" if a.heavy else "attack","life":1.5,"speed":500.0,"return":c.has("return"),"trigger":true}
 config.merge(options,true)
 if c.evolution()==2:config.life*=1.2;config.turn_after=float(config.get("turn_after",.5))*1.2
 if config.trigger:
  config.pierce=int(config.get("pierce",0))+int(c.value("pierce"))
 if c.has("converge"):
  d=d.slerp(a.direction,.65);config.life*=1.15
  if config.get("return",false):config.turn_after=float(config.get("turn_after",.5))*1.15
 if c.has("fan") and config.trigger:
  if not a.get("fan_emitted",false):
   a.fan_emitted=true
   for sign in [-1,1]:c.shoot(pos,d.rotated(sign*.28),damage*.35,config)
  damage*=.85
 if c.has("swarm") and config.trigger:
  for side in [-1,1]:c.shoot(pos,d.rotated(side*.1),damage*.4,config)
  damage*=.65
 c.shoot(pos,d,damage,config)

static func field(c,a: Dictionary,pos: Vector2,radius: float,damage: float,duration: float,kind: String) -> void:
 var previous: int=c.fields.size();c.add_field(pos,radius*(1.2 if c.evolution()==2 else 1.0),damage,duration,kind)
 if c.fields.size()>previous:c.fields.back().attack_trigger=true;c.fields.back().hit=[];c.fields.back().weapon_id=a.weapon_id

static func lane(c,origin: Vector2,d: Vector2,length: float,width: float,damage: float,source: String="attack") -> void:
 for e in c.enemies.duplicate():
  if not e.dead and c.role.in_lane(origin,d,e,length,width) and c.geometry.visible(origin,e.pos):c.hit(e,damage,source,source!="兵器共鸣",20)

static func marks(c,a: Dictionary,pos: Vector2,d: Vector2) -> void:
 for e in c.enemies.duplicate():
  if not e.dead and e.marks>0 and c.role.in_lane(pos,d,e,a.reach*1.7,90) and c.geometry.visible(pos,e.pos):
   c.hit(e,a.damage*(.5+e.marks*.2*(1+c.value("sand_damage")+c.value("hero_sand_damage"))),"印裂",false,30);c.role.art(c,"detonate",e.pos,d,55,.45);e.marks=0

static func payload(c,a: Dictionary) -> void:
 var p: Vector2=c.player.pos;var d: Vector2=a.direction;var power: float=a.damage
 var h: bool=a.heavy;var n: int=a.combo;var source: String="heavy" if h else "attack"
 fx(c,a,p,d,a.reach,"",.65 if h else .4)
 c.feedback.emit("heavy" if h else "swing",p,power)
 if preload("res://scripts/weapon_combo.gd").payload(c,a):return
 match a.weapon_style:
  "extend":
   if h:c.player.pos=c.geometry.move(p,d*20)
  "pin":
   for i in (4 if h else n):
    var point: Vector2=c.geometry.move(p,d*(75+i*75))
    c.role.delay(c,point,power/(2.0 if h else 1.5),34,.05+i*.09);field(c,a,point,28,power*.12,.7,"pin");fx(c,a,point,d,45,"pin",.5)
  "flame":
   for i in (3 if h else 1):
    var point: Vector2=c.geometry.move(p,d*(70+i*75))
    field(c,a,point,58 if h else 45,power*.4,2.0 if h else 1.1,"fire");fx(c,a,point,d,55,"flame",1.1)
   if not h:shot(c,a,p,d,power*.6,"ember",{"speed":300.0,"radius":13.0})
  "dual":
   if n==3 and not h:c.role.delay(c,c.geometry.move(p,d*75),power*.45,50,.16)
  "phantom":
   for i in (3 if h else 2):
    var point: Vector2=c.geometry.move(p,d*(85+i*55)+d.orthogonal()*(35 if i%2==0 else -35))
    c.player.delayed.append({"kind":"weapon_echo","left":.12+i*.14,"pos":point,"radius":55.0,"damage":power*.55,"style":"phantom","weapon_id":a.weapon_id,"dir":d})
    field(c,a,point,32,power*.12,.8,"shadow")
    fx(c,a,point,d,65,"phantom",.7)
  "stamp":
   if h:
    for seal in c.player.seals:
     var radius: float=seal.radius*(1.35 if c.has("heavy_line") else 1)
     c.area(seal.pos,radius,power,source,true);fx(c,a,seal.pos,d,radius,"stamp",.7)
     if c.has("echo"):c.role.delay(c,seal.pos,power*.35,radius*.7)
    if c.owns("tangseng_t5"):c.resource(c.player.seals.size()*3)
    c.player.seals=[];c.area(p+d*90,65,power*.6,source,true)
   else:
    var count: int=1
    for i in count:shot(c,a,p+d*20,d.rotated((i-(count-1)*.5)*.14),power/maxf(1,sqrt(count)),"bead",{"return":c.has("return"),"turn_after":.35})
    if n>=2:c.role.place_seal(c,c.geometry.move(p,d*(130 if n==2 else 210)),60*(1+c.value("field_size")))
    if c.owns("tangseng_t2") and n==2:
     for side in [-1,1]:shot(c,a,p,d.rotated(side*.45),power*.4,"bead",{"trigger":false})
    c.resource(4)
  "mandala":
   var point: Vector2=c.geometry.move(p,d*135)
   for i in (2 if h else 1):
    var axis: Vector2=d if i==1 else d.orthogonal()
    lane(c,point-axis*100,axis,230,22,power*.8,source);fx(c,a,point,axis,120,"mandala",.65)
   c.role.place_seal(c,point,45);c.resource(3)
  "rosary":
   if h:c.recall();c.player.orbit_until=c.time+2;c.area(p,110,power*.8,source,false)
   for i in (6 if h else 2+n):shot(c,a,p,d.rotated((i-2)*.2),power*.45,"bead",{"return":true,"turn_after":.28,"pierce":1})
   c.resource(3)
  "scripture":
   if h:
    for seal in c.player.seals:c.role.delay(c,seal.pos,power*.8,seal.radius,.15);fx(c,a,seal.pos,d,seal.radius,"scripture",.7)
    c.player.seals=[]
   else:
    for i in 1:shot(c,a,p,d.rotated(i*.17),power*.75,"page",{"pierce":2})
    for side in [-1,1]:c.role.place_seal(c,c.geometry.move(p,d*(100+n*25)+d.orthogonal()*side*65),42)
   c.resource(3)
  "bell":
   field(c,a,p+d*55,85,power*.15,.9,"resonance")
   for i in (3 if h else 1):
    var radius: float=95+i*38
    c.role.delay(c,p+d*55,power*.55,radius,.08+i*.24);fx(c,a,p+d*55,d,radius,"bell",.65+i*.24)
   c.resource(3)
  "rake":
   if h:
    for e in c.enemies:
     if not e.dead and c.role.in_lane(p,d,e,a.reach,80) and c.geometry.visible(p,e.pos):e.pos=c.geometry.move(e.pos,(p+d*55-e.pos)*(.1 if e.kind=="boss" else .55),e.radius)
  "hook":
   var count: int=(2 if h else 1)
   for i in count:shot(c,a,p,d.rotated((i-(count-1)*.5)*.35),power*.8,"hook",{"return":true,"turn_after":.3,"pierce":3,"pull":45.0})
  "furrow":
   for side in ([-1,0,1] if h else [0]):
    for i in 3:
     var point: Vector2=c.geometry.move(p,d.rotated(side*.4)*(75+i*65))
     c.role.delay(c,point,power*.6,40,.04+i*.12);field(c,a,point,32,power*.12,.8,"furrow");fx(c,a,point,d.rotated(side*.4),50,"furrow",.65)
  "ice_hammer":
   for i in (3 if h else 1):
    var point: Vector2=c.geometry.move(p,d*(75+i*60))
    c.role.delay(c,point,power*.7,60,.1+i*.18);field(c,a,point,55,2,1.4,"frost");fx(c,a,point,d,65,"ice_hammer",.9)
  "meteor":
   if h:shot(c,a,p,d,power,"meteor",{"return":true,"turn_after":.45,"pierce":5,"radius":21.0,"speed":370.0})
   else:c.player.guard_until=c.time+.12
  "crescent_staff":
   if h:marks(c,a,p,d)
   elif n==3:shot(c,a,p,d,power*.35,"crescent",{"apply_marks":true,"trigger":false})
  "crescent":
   var count: int=(2 if h else 1)
   for i in count:shot(c,a,p,d.rotated((i-(count-1)*.5)*.3),power/maxf(1,sqrt(count)),"crescent",{"return":true,"turn_after":.42,"pierce":3,"carry_marks":true})
   if h:marks(c,a,p,d)
  "shards":
   var count: int=(7 if h else 2+n)
   for i in count:shot(c,a,p,d.rotated((i-(count-1)*.5)*.17),power*.45,"sand_shard",{"apply_marks":true,"pierce":1})
  "sand_seal":
   if h:
    marks(c,a,p,d)
    for field in c.fields.duplicate():
     if field.kind=="sand":c.role.delay(c,field.pos,power,field.radius,.18);field.life=0;fx(c,a,field.pos,d,field.radius,"sand_seal",.65)
   else:
    var point: Vector2=c.geometry.move(p,d*(85+n*30))
    field(c,a,point,60,power*.4,2.6,"sand");fx(c,a,point,d,60,"sand_seal",1.0)
  "twin_moon":
   for i in (4 if h else 2):
    var direction: Vector2=Vector2.RIGHT.rotated(i*PI*.5) if h else d.rotated(-.55 if i==0 else .55)
    shot(c,a,p+direction.orthogonal()*25,direction,power*.6,"crescent",{"return":true,"turn_after":.28,"pierce":4,"carry_marks":true,"speed":390.0})
  "lance":
   if h:c.role.movement_skill(c,d,650,power,.2)
   else:c.player.pos=c.geometry.move(p,d*(18 if n==3 else 7))
  "wave_sword":
   if h:c.recall();shot(c,a,p,d,power,"water_wave",{"radius":23.0,"pierce":8,"speed":360.0})
   else:
    var count: int=2 if c.owns("bailongma_t2") else 1
    for i in count:shot(c,a,p,d.rotated((i-(count-1)*.5)*.18),power/maxf(1,sqrt(count)),"sword",{"return":true,"turn_after":.35,"pierce":2})
  "frost_sword":
   for i in (5 if h else 1):shot(c,a,p,d.rotated((i-2)*.23 if h else 0),power*.6,"ice_shard",{"frost":true,"pierce":2})
  "thunder":
   if h:
    var targets: Array=c.enemies.filter(func(e):return not e.dead and e.pos.distance_to(p)<350 and c.geometry.visible(p,e.pos))
    for i in mini(3,targets.size()):c.role.delay(c,targets[i].pos,power*.7,50,.1+i*.15);fx(c,a,targets[i].pos,d,90,"thunder",.8)
    if targets.is_empty():fx(c,a,p+d*160,d,90,"thunder",.6)
   else:
    if n==3:c.player.pos=c.geometry.move(p,d*60);c.invuln=maxf(c.invuln,.1)
    for i in 1:shot(c,a,c.player.pos,d.rotated(i*.16),power,"lightning",{"pierce":4,"speed":1000.0,"life":1.3})
    fx(c,a,c.player.pos,d,a.reach,"thunder",.45)
  "stars":
   var count: int=7 if h else n+1
   for i in count:
    var offset: Vector2=d.orthogonal()*(i-(count-1)*.5)*18
    shot(c,a,p+offset,d.rotated((i-(count-1)*.5)*(.035 if h else .13)),power*(.28 if h else .5),"star_sword",{"return":true,"turn_after":.5,"pierce":2})
  "disc":
   for i in (3 if h else 1):shot(c,a,p,d.rotated((i-1)*.4 if h else 0),power*.7,"disc",{"return":true,"pierce":5,"turn_after":.5,"speed":430.0})
  "lotus_lantern":
   for i in (3 if h else 1):
    var point: Vector2=c.geometry.move(p,d*(90+i*65))
    field(c,a,point,65,power*.5,2.5,"lotus");fx(c,a,point,d,65,"lotus_lantern",1.0)
  "gate_shield":
   if h:
    var spent: float=minf(8,c.player.shield);c.player.shield-=spent
    c.area(p+d*75,120,power+spent*3,source,true);fx(c,a,p+d*75,d,120,"gate_shield",.6)
   else:c.player.guard_until=c.time+.2
  "tether":
   if h:marks(c,a,p,d)
   shot(c,a,p,d,power*.6,"tether",{"pull":65.0,"apply_marks":not h,"pierce":3,"return":true,"turn_after":.35})
  "tide_bow":
   if not h:c.player.pos=c.geometry.move(p,-d*16)
   for i in (5 if h else 1):shot(c,a,c.player.pos,d.rotated((i-2)*.18 if h else 0),power*.7,"water_arrow",{"pierce":3,"speed":780.0,"life":1.2})
 if c.hero.id=="tangseng" and h and c.owns("tangseng_t5"):c.resource(3)

static func synergy(c,a: Dictionary) -> void:
 # Weapon interactions change skills without changing their button layout.
 var style: String=KITS[c.weapon.id][1]
 a.weapon_style=style;a.weapon_id=c.weapon.id
 var p: Vector2=c.player.pos;var d: Vector2=a.direction
 fx(c,a,p,d,100,"",.45)
 match style:
  "extend":c.player.weapon_followup_until=c.time+2;c.player.weapon_followup_reach=25
  "pin":lane(c,p,d,220,18,12,"兵器共鸣")
  "flame":c.add_field(p,55,6,1.4,"fire")
  "dual":c.role.delay(c,c.geometry.move(p,d*90),10,50,.15)
  "phantom":
   if c.player.delayed.size()<32:c.player.delayed.append({"kind":"weapon_echo","left":.25,"pos":c.geometry.move(p,d*140),"radius":50.0,"damage":12.0,"style":"phantom","weapon_id":a.weapon_id,"dir":d})
  "stamp":c.role.place_seal(c,c.geometry.move(p,d*100),35)
  "mandala":lane(c,p-d.orthogonal()*65,d.orthogonal(),130,18,10,"兵器共鸣")
  "rosary":c.recall()
  "scripture":shot(c,a,p,d,10,"page",{"trigger":false,"source":"兵器共鸣","pierce":2})
  "bell":c.area(p,70,8,"兵器共鸣",false)
  "rake":lane(c,p,d,110,40,12,"兵器共鸣")
  "hook":shot(c,a,p,d,8,"hook",{"trigger":false,"source":"兵器共鸣","return":true,"pull":20.0,"turn_after":.25})
  "furrow":c.role.delay(c,c.geometry.move(p,d*90),12,40,.18)
  "ice_hammer":c.add_field(p,65,4,1.3,"frost")
  "meteor":c.player.shield=minf(100,c.player.shield+4)
  "crescent_staff":
   for e in c.enemies:
    if not e.dead and e.pos.distance_to(p)<180 and c.geometry.visible(p,e.pos):e.marks=mini(6,e.marks+1)
  "crescent":c.recall()
  "shards":
   for side in [-1,1]:shot(c,a,p,d.rotated(side*.4),8,"sand_shard",{"trigger":false,"source":"兵器共鸣","apply_marks":true})
  "sand_seal":c.add_field(c.geometry.move(p,d*100),50,4,1.7,"sand")
  "twin_moon":
   for side in [-1,1]:shot(c,a,p,d.rotated(side*.8),8,"crescent",{"trigger":false,"source":"兵器共鸣","return":true,"carry_marks":true,"turn_after":.3})
  "lance":c.player.pos=c.geometry.move(p,d*15)
  "wave_sword":shot(c,a,p,d,10,"water_wave",{"trigger":false,"source":"兵器共鸣","radius":16.0,"pierce":3})
  "frost_sword":c.add_field(c.geometry.move(p,d*70),40,3,.8,"frost")
  "thunder":lane(c,p,d,150,12,10,"兵器共鸣")
  "stars":shot(c,a,p,d,12,"star_sword",{"trigger":false,"return":true,"source":"兵器共鸣"})
  "disc":shot(c,a,p,d,10,"disc",{"return":true,"trigger":false,"pierce":3})
  "lotus_lantern":c.add_field(p,50,5,1.5,"lotus")
  "gate_shield":c.player.shield=minf(150,c.player.shield+6)
  "tether":shot(c,a,p,d,8,"tether",{"pull":30.0,"apply_marks":true,"trigger":false})
  "tide_bow":shot(c,a,p,d,12,"water_arrow",{"pierce":3,"trigger":false,"speed":780.0})
