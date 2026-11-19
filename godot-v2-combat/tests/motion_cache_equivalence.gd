extends SceneTree
var failures: Array=[]
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var content=preload("res://scripts/content.gd").new()
 var cases: int=0
 for hero in content.tables.heroes:
  var c=preload("res://scripts/combat.gd").new(content);c.reset(hero,content.find("weapons",hero.id+"_w0"));c.configure_arena(Vector2(2400,1400));c.geometry.configure(c.arena_bounds(),[])
  for direction in [Vector2.RIGHT,Vector2(-.7,.7).normalized(),Vector2.ZERO]:
   var initial: Dictionary=c.player.duplicate(true)
   c.motion.step(c,.016,direction,hero.speed,0);var first: Dictionary=c.player.duplicate(true)
   for frame in 29:c.motion.step(c,.016,direction,hero.speed,0)
   var reused: Dictionary=c.player.duplicate(true)
   c.player=initial.duplicate(true)
   for frame in 30:
    c.motion.motion_kit=null # Force the former per-frame allocation path.
    c.motion.step(c,.016,direction,hero.speed,0)
   if c.player.pos!=reused.pos or c.player.velocity!=reused.velocity or c.player.gait!=reused.gait:failures.append(hero.id+" cached movement differs")
   if c.player.foot_contacts!=reused.foot_contacts:failures.append(hero.id+" cached foot contacts differ")
   if not is_finite(first.gait):failures.append(hero.id+" invalid gait")
   cases+=1
  var kit=preload("res://scripts/character_combat_kit.gd").for_hero(hero.id)
  if kit.acceleration_time!=preload("res://scripts/character_combat_kit.gd").acceleration_for(hero.id):failures.append(hero.id+" acceleration accessor differs")
  if kit.resource_rule!=preload("res://scripts/character_combat_kit.gd").resource_rule_for(hero.id):failures.append(hero.id+" HUD resource differs")
  for phase in [0.0,1.0]:
   for value in preload("res://scripts/layered_rig.gd").dash_pose(hero.id,phase):
    if value!=0:failures.append(hero.id+" dash transition endpoint discontinuity")
 var report={"movement_sequences":cases,"failures":failures,"scope":"Five heroes: allocated versus reused movement, foot contact, gait, resource text and dash endpoint checks; no visual approval"}
 var file=FileAccess.open("res://tests/motion-cache-equivalence.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();print(JSON.stringify(report));quit(0 if failures.is_empty() else 1)
