extends RefCounted

static func started(c, a: Dictionary) -> void:
 preload("res://scripts/combo_talents.gd").started(c,a)
 if a.kind!="attack":return
 if c.hero.id=="wukong" and c.owns("wukong_t0") and a.combo==3 and not a.heavy and a.shape!="seal":a.shape="spin"
 if c.hero.id=="bajie" and c.owns("bajie_t2") and a.heavy:a.reach*=1.2

static func guard(c) -> void:
 if c.hero.id!="bajie" or not c.owns("bajie_t1"):return
 for bullet in c.bullets:
  if bullet.life>0 and not bullet.get("friendly",true) and bullet.pos.distance_to(c.player.pos)<160:
   bullet.friendly=true;bullet.dir=-bullet.dir;bullet.trigger=false;bullet.source="架耙反弹";bullet.hit=[];bullet.color=Color(c.hero.color)
 c.role.art(c,"guard",c.player.pos,c.player.get("facing",Vector2.RIGHT),150,.5)

static func return_home(c, _bullet: Dictionary) -> void:
 preload("res://scripts/combo_talents.gd").return_home(c,_bullet)
 if c.hero.id=="shaseng" and c.owns("shaseng_t5"):c.resource(3)
 if c.hero.id=="bailongma" and c.owns("bailongma_t5"):
  if c.time>=c.player.get("recall_until",0):c.player.recall_charge=0
  c.player.recall_charge=mini(3,int(c.player.get("recall_charge",0))+1);c.player.recall_until=c.time+2;c.resource(2)

static func projectile(c, bullet: Dictionary, enemy: Dictionary) -> void:
 if c.hero.id=="tangseng" and c.owns("tangseng_t1") and bullet.source=="协战" and c.time>=c.player.get("guardian_seal_at",0):
  c.player.guardian_seal_at=c.time+.8;c.role.place_seal(c,enemy.pos,45)

static func chant(c, position: Vector2) -> void:
 if c.hero.id=="tangseng" and c.owns("tangseng_t3") and c.time>=c.player.get("lotus_at",0):
  c.player.lotus_at=c.time+.8;c.add_field(position,65,4,1.5,"sanctuary");c.role.art(c,"sanctuary",position,Vector2.RIGHT,65,.5)

static func detonate(c, enemy: Dictionary, damage: float) -> void:
 if c.hero.id=="shaseng" and c.owns("shaseng_t3"):
  for side in [-1,1]:c.shoot(enemy.pos,Vector2.RIGHT.rotated(side*.55),damage*.35,{"source":"印裂碎刃","trigger":false,"return":false,"visual":"sand_shard","role":"shaseng","pierce":0})

static func wall(c) -> void:
 if c.hero.id=="bailongma" and c.owns("bailongma_t1") and c.time>=c.player.get("wall_shield_at",0):
  c.player.wall_shield_at=c.time+.2;c.player.shield=minf(100,c.player.shield+3);c.feedback.emit("shield",c.player.pos,0)
