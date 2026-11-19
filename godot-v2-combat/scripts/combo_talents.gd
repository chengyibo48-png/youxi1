extends RefCounted
static func started(c,a: Dictionary) -> void:
 if a.kind!="attack":return
 if not a.heavy:
  if c.owns("combo_open") and a.combo==1:a.shape="thrust";a.reach*=1.25;a.damage*=.9
  if c.owns("combo_lateral") and a.combo==2:a.damage*=.9
  if c.owns("combo_final") and a.combo==3 and c.player.resource>=10:c.resource(-10);a.damage*=1.25;a.reach*=1.15
  if c.owns("combo_return") and a.combo==3:a.damage*=.8
  if c.owns("combo_draw") and a.combo==3:a.damage*=.8;c.player.combo_draw_ready=true
  if c.owns("b_shield_spend") and a.combo==3 and c.player.shield>=8:c.player.shield-=8;a.damage*=1.3
  if c.owns("d_tide_precision") and a.combo==3 and c.player.resource>=50:c.resource(-12);a.reach*=1.2;a.damage*=1.2
 elif c.owns("combo_draw") and c.player.get("combo_draw_ready",false):a.damage*=1.2;c.player.combo_draw_ready=false
static func payload(c,a: Dictionary) -> void:
 if a.heavy:return
 var p: Vector2=c.player.pos;var d: Vector2=a.direction;var n: int=a.combo;var Arts=load("res://scripts/weapon_arts.gd")
 if c.owns("combo_lateral") and n==2:
  for sign in [-1,1]:Arts.shot(c,a,p,d.rotated(sign*.65),a.damage*.15,"star_sword",{"trigger":false,"source":"侧翼派生","return":false})
 if c.owns("combo_return") and n==3:c.recall();Arts.fx(c,a,p,d,100,"",.6)
 if c.owns("combo_anchor") and n==2:Arts.field(c,a,c.geometry.move(p,d*100),42,a.damage*.12,1.2,"ink");Arts.fx(c,a,p+d*100,d,42,"sand_seal",.8)
 if c.owns("combo_aegis") and n==3 and c.player.resource>=6:c.resource(-6);c.player.shield=minf(100,c.player.shield+8);Arts.fx(c,a,p,d,60,"gate_shield",.5)
 if c.owns("combo_stride"):c.player.pos=c.geometry.move(p,-d*20 if n==2 else d*35 if n==3 else Vector2.ZERO)
 if c.owns("combo_ink") and n==3:c.role.delay(c,p+d*100,a.damage*.25,45,.35);Arts.fx(c,a,p+d*100,d,45,"phantom",.7)
 if c.owns("combo_frugal"):
  if n==1:c.resource(2)
  elif n==3 and c.player.resource>=4:c.resource(-4);c.skill_cd[0]=maxf(0,c.skill_cd[0]-.25);c.skill_cd[1]=maxf(0,c.skill_cd[1]-.25)
 if c.owns("w_combo_vault") and n==3:c.player.pos=c.geometry.move(p,d*35);c.role.delay(c,c.player.pos,a.damage*.25,65,.18);Arts.fx(c,a,c.player.pos,d,65,"extend",.6)
 if c.owns("w_echo_staff") and n==2:c.role.delay(c,p+d*100,a.damage*.22,42,.22);Arts.fx(c,a,p+d*100,d,42,"phantom",.6)
 if c.owns("t_combo_lotus") and n==3:c.add_field(p,55,2,1.8,"lotus");Arts.fx(c,a,p,d,55,"lotus_lantern",.8)
 if c.owns("b_combo_guard") and n==2:c.player.guard_until=c.time+.15;Arts.fx(c,a,p,d,55,"gate_shield",.4)
 if c.owns("s_combo_transfer") and n==2:
  var nearby: Array=c.enemies.filter(func(e):return not e.dead and e.pos.distance_to(p)<250 and c.geometry.visible(p,e.pos))
  if nearby.size()>1 and nearby[0].marks>0:nearby[0].marks-=1;nearby[1].marks=mini(6,nearby[1].marks+1);c.role.art(c,"link",nearby[0].pos,(nearby[1].pos-nearby[0].pos).normalized(),nearby[0].pos.distance_to(nearby[1].pos),.6)
 if c.owns("s_combo_refund") and n==3:
  if c.player.delayed.size()<32:c.player.delayed.append({"kind":"sand_refund","left":a.active+.02,"pos":p})
  Arts.fx(c,a,p,d,75,"tether",.6)
 if c.owns("d_combo_recall") and n==3:c.recall();c.player.recall_until=c.time+2;c.player.recall_charge=mini(3,c.player.get("recall_charge",0)+1)
static func return_home(c,b: Dictionary) -> void:
 if c.owns("t_recall_print") and c.time>=c.player.get("recall_print_at",0):
  c.player.recall_print_at=c.time+1.2;c.role.place_seal(c,c.player.pos,45)
static func points(c) -> int:
 var total: int=0
 for level in c.owned.values():total+=int(level)
 return total
static func budget(c) -> int:return int(c.player.get("talent_budget",0))
static func full(c) -> bool:return budget(c)>0 and points(c)>=budget(c)
