extends SceneTree
var failed: int=0
func check(value: bool,message: String) -> void:
 if not value:failed+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var feet=preload("res://scripts/foot_contacts.gd")
 var actor: Dictionary={"pos":Vector2(100,100),"gait":4.0}
 feet.update(actor,.016,Vector2(100,0))
 var fixed: Vector2=actor.foot_contacts[-1].point
 actor.pos.x+=3;actor.gait+=.1;feet.update(actor,.016,Vector2(100,0))
 check(actor.foot_contacts[-1].point.is_equal_approx(fixed),"Supporting foot must remain planted while the pelvis advances")
 for i in 90:
  actor.pos+=Vector2(10,0);actor.gait+=.85;feet.update(actor,.016,Vector2(625,0))
  for side in [-1,1]:check(actor.foot_contacts[side].point.distance_to(actor.pos+Vector2(side*9,2))<=18.001,"Foot must remain reachable at dash speed")
 var rig=preload("res://scripts/enemy_rig.gd")
 var enemy: Dictionary={"pos":Vector2(120,120),"radius":17.0,"target":Vector2(160,120),"telegraph":0.0}
 rig.update(enemy,.016);var phase: float=enemy.gait
 rig.update(enemy,.016);check(is_equal_approx(enemy.gait,phase),"Idle enemy must not walk in place")
 enemy.pos.x+=20;rig.update(enemy,.016);check(enemy.gait>phase,"Enemy gait must follow actual displacement")
 var art=preload("res://scripts/painterly_assets.gd")
 var db=preload("res://scripts/content.gd").new()
 for weapon in db.tables.weapons:check(art.weapon(weapon.id)!=null,"Missing weapon artwork: "+weapon.id)
 for relic in db.tables.relics:check(art.relic(relic.id)!=null,"Missing relic artwork: "+relic.id)
 for row in 5:
  for column in 6:check(art.tile("effects",column,row,6,5)!=null,"Missing effect animation frame")
 print("ART_MOTION_CHECKS failed=",failed);quit(1 if failed else 0)
