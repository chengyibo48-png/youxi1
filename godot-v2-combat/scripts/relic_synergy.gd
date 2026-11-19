extends RefCounted
const DESCRIPTIONS={
 "crit":"重击为附近目标留下2秒照妖印，后续攻击获得印记增益",
 "regen":"第三连击回复2生命，至少间隔1秒",
 "waterguard":"闪避净化灼烧与毒，并获得4护盾，至少间隔2秒",
 "slow":"闪避时减速120范围敌人1.5秒，至少间隔2秒",
 "maxhp":"击败敌人回复2生命，至少间隔1秒",
 "gourd":"重击轻摄180范围敌人，首领受拉扯较弱，至少间隔1秒",
 "heal":"施术时净化异常并回复2生命，至少间隔3秒",
 "barrier":"护盾受击反震14基础伤害，至少间隔2秒",
 "reset":"击败敌人使两个神通冷却各减少0.3秒，至少间隔1秒",
 "wind":"重击追加三道低伤风刃，至少间隔1秒",
 "pagoda":"施术留下持续2.4秒的近场镇妖阵，至少间隔4秒",
 "needles":"第三连击追加一枚追踪飞针，至少间隔1秒",
 "root":"重击束缚最近小妖0.5秒；对首领追加破势，至少间隔2秒",
 "blink":"闪避蓄势2秒，下一次重击追加两段直线攻击",
 "thunder":"第三连击向附近目标释放一次雷链，至少间隔1秒",
 "purify":"施术后0.3秒阻挡敌方飞弹，至少间隔3秒",
 "resource":"第三连击回复4角色资源，至少间隔1秒",
 "shield":"释放绝技额外获得12护盾，至少间隔2秒",
 "relic_recall":"第三连击追加一枚回旋环，至少间隔1秒",
 "relic_lotus":"施术额外回复2生命，至少间隔1秒",
 "relic_bell":"护盾受击反震，至少间隔2秒",
 "relic_hourglass":"重击为附近敌人追加流沙印，至少间隔1秒",
 "relic_quiver":"闪避追加穿透水箭，至少间隔1秒"
}
const EVENTS={"crit":"heavy","regen":"third","waterguard":"dash","slow":"dash","maxhp":"kill","gourd":"heavy","heal":"skill","barrier":"shield_hit","reset":"kill","wind":"heavy","pagoda":"skill","needles":"third","root":"heavy","blink":"dash","thunder":"third","purify":"skill","resource":"third","shield":"ultimate","relic_recall":"third","relic_lotus":"skill","relic_bell":"shield_hit","relic_hourglass":"heavy","relic_quiver":"dash"}
func trigger(c, event: String, direction: Vector2=Vector2.RIGHT) -> bool:
 var kind: String=c.passive_relic
 if kind=="blink" and event=="heavy" and c.time<c.player.get("relic_line_until",0):
  c.player.relic_line_until=0
  for i in 2:c.area(c.geometry.move(c.player.pos,direction*(100+i*60)),30,8,"遁符共鸣",false)
  c.presentation.emit(c,"heavy_line",c.player.pos,direction,190,.35)
  return true
 if EVENTS.get(kind,"")!=event:return false
 if not c.player.has("relic_cooldowns"):c.player.relic_cooldowns={}
 if c.time<c.player.relic_cooldowns.get(kind,0):return false
 var cd: float=4 if kind=="pagoda" else 3 if kind in ["heal","purify"] else 2 if kind in ["waterguard","slow","barrier","root","shield","relic_bell"] else 1
 c.player.relic_cooldowns[kind]=c.time+cd
 var at: Vector2=c.player.pos
 var target: Dictionary=c.nearest(at)
 preload("res://scripts/content_extension.gd").passive(c,kind,direction)
 match kind:
  "crit":
   if not target.is_empty() and target.pos.distance_to(at)<220:target.mark=maxf(target.mark,2)
  "regen","maxhp":c.heal(2)
  "waterguard":c.player.poison=0;c.player.burn=0;c.player.shield=minf(150,c.player.shield+4)
  "slow":
   for enemy in c.enemies:
    if not enemy.dead and enemy.pos.distance_to(at)<120:enemy.slow=maxf(enemy.slow,1.5)
  "gourd":
   for enemy in c.enemies:
    if not enemy.dead and enemy.pos.distance_to(at)<180 and c.geometry.visible(at,enemy.pos):enemy.pos=c.geometry.move(enemy.pos,(at-enemy.pos)*(.04 if enemy.kind=="boss" else .12),enemy.radius)
  "heal":c.player.poison=0;c.player.burn=0;c.heal(2)
  "barrier":c.area(at,100,14,"金环共鸣",false)
  "reset":
   for i in 2:c.skill_cd[i]=maxf(0,c.skill_cd[i]-.3)
  "wind":
   for i in 3:c.shoot(at,direction.rotated((i-1)*.24),7,{"source":"风刃共鸣","trigger":false,"return":false,"life":.8,"visual":"fan"})
  "pagoda":c.add_field(at,65,6,2.4,"pagoda")
  "needles":c.shoot(at,direction,14,{"source":"飞针共鸣","trigger":false,"return":false,"homing":true,"visual":"pursue"})
  "root":
   if not target.is_empty() and target.pos.distance_to(at)<160:
    if target.kind!="boss":target.root=maxf(target.root,.5)
    c.hit(target,6,"缚妖共鸣",false,12)
  "blink":c.player.relic_line_until=c.time+2
  "thunder":
   if not target.is_empty() and target.pos.distance_to(at)<240:c.hit(target,6,"雷符共鸣",false,6);c.chain(target,8,1)
  "purify":c.player.barrier_until=maxf(c.player.get("barrier_until",0),c.time+.3)
  "resource":c.resource(4)
  "shield":c.player.shield=minf(150,c.player.shield+12)
 c.presentation.emit(c,"resonance",at,direction,42,.3)
 return true
