extends RefCounted
const CHAINS={
 "extend":["横扫","挑棍","踏步穿刺"],"pin":["落钉","交错双钉","纵列三钉"],"flame":["火云推出","双翼火浪","聚焰直冲"],"dual":["右棍短打","左棍反挑","双棍交叉"],"phantom":["双影探路","侧影夹击","三影接力"],
 "stamp":["念珠点射","交错结印","远处落印"],"mandala":["横轮","纵轮","十字成阵"],"rosary":["抛铙","双铙交织","归铙回震"],"scripture":["念珠布印","双串结印","印间经爆"],"bell":["近鸣","侧钟回声","三层远鸣"],
 "rake":["直耙","拖耙反扫","踏地九齿"],"hook":["飞耙","侧翼双钩","收钩反震"],"furrow":["直犁","横沟","三叉翻土"],"ice_hammer":["前砸","左右冰裂","递进冰柱"],"meteor":["链球横扫","反向投球","回球震地"],
 "crescent_staff":["直刺","月牙反切","双刃封路"],"crescent":["出月搬印","交叉双月","回月印裂"],"shards":["碎砂点射","左右错刃","交叉砂瀑"],"sand_seal":["身前沙印","两翼布阵","聚印沙爆"],"twin_moon":["双月展开","左右交错","四月归心"],
 "lance":["挺枪","侧步反刺","穿身突进"],"wave_sword":["水剑出鞘","双浪交织","归剑推浪"],"frost_sword":["寒刃切入","反手冰锥","冻结冰扇"],"thunder":["雷矢","双线雷刺","追身落雷"],"stars":["双星起","四星织路","七星合流"],
 "disc":["抛环","双环交错","收环震击"],"lotus_lantern":["点灯","双莲开路","灯阵续明"],"gate_shield":["举盾顶撞","侧盾反推","进步盾震"],"tether":["掷索","双索牵引","缚印回裂"],"tide_bow":["后撤单箭","侧步双箭","蓄势穿云箭"]}
static func configure(a: Dictionary) -> void:
 if a.heavy:return
 var index: int=a.combo-1
 a.chain_name=CHAINS[a.weapon_style][index]
 var timing: Array=[[1.0,1.0,1.0],[.82,1.1,.9],[1.22,1.15,1.12]][index]
 var recovery: float=a.duration-a.windup-a.active
 a.windup*=timing[0];a.active*=timing[1];a.duration=a.windup+a.active+recovery*timing[2];a.cancel_at=a.windup+a.active
 if index==1:a.reach*=.95
 if index==2:a.reach*=1.15
 if a.weapon_style in ["extend","rake","dual","crescent_staff","lance","frost_sword","gate_shield"]:
  a.shape="arc" if index==1 else a.shape
  if index==2:a.shape="spin" if a.weapon_style=="rake" else "thrust" if a.weapon_style in ["extend","lance","gate_shield"] else "arc"
static func payload(c,a: Dictionary) -> bool:
 var Arts=load("res://scripts/weapon_arts.gd")
 if a.heavy or a.combo==1:return false
 var p: Vector2=c.player.pos;var d: Vector2=a.direction;var side: Vector2=d.orthogonal();var power: float=a.damage;var third: bool=a.combo==3
 match a.weapon_style:
  "extend":
   if third:c.player.pos=c.geometry.move(p,d*24)
   else:Arts.fx(c,a,p,d.rotated(-.7),a.reach,"extend",.45)
  "pin":
   for i in (3 if third else 2):
    var point: Vector2=c.geometry.move(p,d*(75+i*70) if third else d*110+side*(i*2-1)*48)
    c.role.delay(c,point,power*.6,38,.04+i*.09);Arts.field(c,a,point,30,power*.15,.8,"pin");Arts.fx(c,a,point,d,45,"pin",.6)
  "flame":
   if third:Arts.shot(c,a,p,d,power,"ember",{"pierce":5,"radius":19.0,"speed":580.0});Arts.field(c,a,c.geometry.move(p,d*140),65,power*.35,1.8,"fire")
   else:
    for sign in [-1,1]:Arts.shot(c,a,p,d.rotated(sign*.4),power*.65,"ember",{"speed":330.0});Arts.fx(c,a,p,d.rotated(sign*.4),150,"flame",.65)
  "dual":
   if third:c.role.delay(c,c.geometry.move(p,d*75),power*.45,50,.16)
   else:Arts.fx(c,a,p,d.rotated(-.6),110,"dual",.4)
  "phantom":
   for i in (3 if third else 2):
    var point: Vector2=c.geometry.move(p,d*(80+i*65) if third else d*110+side*(i*2-1)*55)
    if c.player.delayed.size()<32:c.player.delayed.append({"kind":"weapon_echo","left":.12+i*.15,"pos":point,"radius":55.0,"damage":power*.65,"style":"phantom","weapon_id":a.weapon_id,"dir":d})
    Arts.fx(c,a,point,d,55,"phantom",.8)
  "stamp":
   c.role.place_seal(c,c.geometry.move(p,d*(210 if third else 130)),60*(1+c.value("field_size")))
   for sign in ([-1,1] if not third else [0]):Arts.shot(c,a,p,d.rotated(sign*.25),power*.7,"bead",{"return":c.has("return")})
   c.resource(4)
  "mandala":
   var point: Vector2=c.geometry.move(p,d*140)
   Arts.lane(c,p,d,260,22,power,"attack");Arts.fx(c,a,p,d,260,"mandala",.65)
   if third:Arts.lane(c,point-side*100,side,200,22,power*.6);Arts.fx(c,a,point,side,180,"mandala",.65);c.role.place_seal(c,point,65)
  "rosary":
   if third:c.recall();c.area(p,100,power*.7,"归珠",false)
   for i in (5 if third else 2):Arts.shot(c,a,p+side*(i-1)*18,d.rotated((i-1)*.13),power*.5,"bead",{"return":true,"turn_after":.32,"pierce":2})
  "scripture":
   if third:
    for seal in c.player.seals:c.role.delay(c,seal.pos,power*.6,seal.radius,.15);Arts.fx(c,a,seal.pos,d,seal.radius,"scripture",.65)
    c.player.seals=[];Arts.shot(c,a,p,d,power*.7,"page",{"pierce":4})
   else:
    for sign in [-1,1]:Arts.shot(c,a,p+side*sign*30,d,power*.55,"page",{"pierce":2});c.role.place_seal(c,c.geometry.move(p,d*145+side*sign*65),42)
  "bell":
   for i in (3 if third else 2):
    var point: Vector2=p+d*(90 if third else 65)+side*(0 if third else (i*2-1)*55)
    c.role.delay(c,point,power*.55,90+i*25,.07+i*.17);Arts.fx(c,a,point,d,90+i*25,"bell",.9)
  "rake":
   if third:c.player.pos=c.geometry.move(p,d*18);c.role.delay(c,p+d*55,power*.35,65,.15)
   else:
    for e in c.enemies:
     if not e.dead and c.role.in_lane(p,d,e,a.reach,70):e.pos=c.geometry.move(e.pos,(p+d*60-e.pos)*(.04 if e.kind=="boss" else .18),e.radius)
  "hook":
   if third:c.recall();c.area(p+d*65,100,power*.7,"收耙",true)
   else:
    for sign in [-1,1]:Arts.shot(c,a,p+side*sign*20,d.rotated(sign*.25),power*.65,"hook",{"return":true,"turn_after":.3,"pull":45.0,"pierce":3})
  "furrow":
   for i in 3:
    var axis: Vector2=d.rotated((i-1)*.35) if third else side
    var point: Vector2=c.geometry.move(p,axis*(80+i*50) if third else d*90+side*(i-1)*65)
    c.role.delay(c,point,power*.65,45,.08+i*.1);Arts.fx(c,a,point,axis,55,"furrow",.7)
  "ice_hammer":
   for i in (3 if third else 2):
    var point: Vector2=c.geometry.move(p,d*(80+i*60) if third else d*90+side*(i*2-1)*45)
    c.role.delay(c,point,power*.65,50,.08+i*.12);Arts.field(c,a,point,45,3,1.5,"frost");Arts.fx(c,a,point,d,55,"ice_hammer",.8)
  "meteor":
   if third:c.recall();c.role.delay(c,p+d*75,power,80,.16);Arts.fx(c,a,p+d*75,d,100,"meteor",.6)
   else:Arts.shot(c,a,p,d.rotated(-.2),power*.8,"meteor",{"return":true,"turn_after":.3,"pierce":4,"radius":16.0})
  "crescent_staff":
   if third:
    for sign in [-1,1]:Arts.shot(c,a,p,d.rotated(sign*.32),power*.4,"crescent",{"apply_marks":true,"pierce":2})
  "crescent":
   if third:Arts.marks(c,a,p,d);c.recall()
   for sign in [-1,1]:Arts.shot(c,a,p+side*sign*25,d.rotated(sign*.3),power*.6,"crescent",{"return":true,"turn_after":.35,"carry_marks":not third,"apply_marks":not third,"pierce":3,"role":"" if third else "shaseng"})
  "shards":
   for i in (6 if third else 2):Arts.shot(c,a,p+side*(35 if i%2==0 else -35),d.rotated((i-2.5)*.13 if third else (i*2-1)*.35),power*.45,"sand_shard",{"apply_marks":true,"pierce":2})
  "sand_seal":
   if third:
    for field in c.fields.duplicate():
     if field.kind=="sand":c.role.delay(c,field.pos,power*.75,field.radius,.15);Arts.fx(c,a,field.pos,d,field.radius,"sand_seal",.7);field.life=0
    Arts.field(c,a,c.geometry.move(p,d*160),70,power*.35,1.5,"sand")
   else:
    for sign in [-1,1]:Arts.field(c,a,c.geometry.move(p,d*110+side*sign*65),55,power*.4,2.2,"sand");Arts.fx(c,a,p+d*110+side*sign*65,d,55,"sand_seal",.8)
  "twin_moon":
   if third:c.recall()
   for i in (4 if third else 2):Arts.shot(c,a,p+side*(i-1.5)*30,d.rotated((i-1.5)*.3),power*.55,"crescent",{"return":true,"turn_after":.25 if third else .4,"carry_marks":true,"pierce":3})
  "lance":c.player.pos=c.geometry.move(p,d*38 if third else side*18)
  "wave_sword":
   if third:c.recall();Arts.shot(c,a,p,d,power,"water_wave",{"pierce":5,"radius":19.0,"speed":350.0})
   else:
    for sign in [-1,1]:Arts.shot(c,a,p+side*sign*20,d.rotated(sign*.22),power*.65,"sword",{"return":true,"turn_after":.35,"pierce":2})
  "frost_sword":
   for i in (5 if third else 2):Arts.shot(c,a,p,d.rotated((i-2)*.2 if third else (i*2-1)*.25),power*.5,"ice_shard",{"pierce":2,"frost":true})
  "thunder":
   if third:
    c.player.pos=c.geometry.move(p,d*50);c.role.delay(c,c.geometry.move(p,d*150),power*.8,55,.15);Arts.fx(c,a,p+d*150,d,90,"thunder",.6)
   for sign in ([-1,1] if not third else [0]):Arts.shot(c,a,p+side*sign*25,d,power*.7,"lightning",{"speed":1000.0,"pierce":4})
  "stars":
   for i in (7 if third else 4):Arts.shot(c,a,p+side*(i-(3 if third else 1.5))*18,d.rotated((i-(3 if third else 1.5))*.08),power*.35,"star_sword",{"return":true,"turn_after":.45,"pierce":2})
  "disc":
   if third:c.recall();c.area(p+d*60,95,power*.7,"收环",true)
   else:
    for sign in [-1,1]:Arts.shot(c,a,p,d.rotated(sign*.35),power*.65,"disc",{"return":true,"pierce":4,"turn_after":.35})
  "lotus_lantern":
   for sign in ([0] if third else [-1,1]):
    var point: Vector2=c.geometry.move(p,d*(160 if third else 110)+side*sign*60)
    Arts.field(c,a,point,80 if third else 55,power*.5,3 if third else 2,"lotus");Arts.fx(c,a,point,d,80 if third else 55,"lotus_lantern",1.0)
   if third:c.area(p+d*160,80,power*.6,"灯明",true)
  "gate_shield":
   if third:c.player.pos=c.geometry.move(p,d*28);c.area(p+d*60,95,power*.7,"盾震",true)
   else:c.player.pos=c.geometry.move(p,side*16);c.player.guard_until=c.time+.15
  "tether":
   if third:Arts.marks(c,a,p,d)
   for sign in ([0] if third else [-1,1]):Arts.shot(c,a,p,d.rotated(sign*.25),power*.7,"tether",{"return":true,"turn_after":.3,"pull":55.0,"pierce":3,"apply_marks":not third,"role":"" if third else "shaseng"})
  "tide_bow":
   if third:Arts.shot(c,a,p,d,power*1.15,"water_arrow",{"speed":1100.0,"pierce":7,"radius":12.0})
   else:
    c.player.pos=c.geometry.move(p,side*20)
    for sign in [-1,1]:Arts.shot(c,a,c.player.pos,d.rotated(sign*.15),power*.6,"water_arrow",{"speed":750.0,"pierce":3})
 return true
