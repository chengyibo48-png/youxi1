extends SceneTree
var db=preload("res://scripts/content.gd").new()
var records: Array=[]
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("run")
func run() -> void:
 for profile in db.tables.bosses:
  for narrow in [false,true]:
   var c=preload("res://scripts/combat.gd").new(db);c.reset(db.find("heroes","wukong"),db.find("weapons","wukong_w0"));preload("res://scripts/journey_balance.gd").activate(c)
   c.configure_arena(Vector2(1000,600) if narrow else Vector2(2400,1400));c.player.pos=c.arena_bounds().get_center();c.visible_bounds=c.arena_bounds();c.rng.seed=profile.id.hash()
   if narrow:
    c.obstacles=[{"pos":c.player.pos+Vector2(0,-130),"radius":65.0,"kind":"pillar"},{"pos":c.player.pos+Vector2(0,130),"radius":65.0,"kind":"pillar"}];c.geometry.configure(c.arena_bounds(),c.obstacles)
   var boss: Dictionary=c.spawn("boss",c.player.pos+Vector2(220,0),12,profile.name)
   var moves: Array=[]
   for phase in [profile.phase_one,profile.phase_two,profile.phase_three]:
    for move in phase:
     if move not in moves:moves.append(move)
   var cases: Array=[]
   for move in moves:
    c.clear_room();c.player.pos=c.arena_bounds().get_center();c.player.hp=c.player.max_hp;c.player.resource=25;c.invuln=0
    boss=c.spawn("boss",c.player.pos+Vector2(220,0),12,profile.name);boss.phase=3
    for offset in [Vector2(-220,80),Vector2(-200,-80)]:c.spawn("ranged",c.player.pos+offset,12)
    var accepted: bool=c.bosses.begin(c,boss,move)
    var quota_peak: int=0
    var invalid_route: bool=false
    for hazard in c.hazards:
     if hazard.has("escape_route") and not preload("res://scripts/escape_planner.gd").valid(c,PackedVector2Array(hazard.escape_route),[hazard]):invalid_route=true
    for frame in 300:
     var movement: Vector2=Vector2.RIGHT.rotated(frame*.025)
     var route: PackedVector2Array=preload("res://scripts/escape_planner.gd").find(c,c.hazards)
     if route.size()>1:movement=(route[1]-c.player.pos).normalized()
     if frame%60==0 and c.hazards.any(func(h):return h.warn<.25 and preload("res://scripts/escape_planner.gd").contains(h,c.player.pos)):c.dash(movement)
     if c.player.hp<=0:break
     c.update(1.0/60,movement)
     var quota: int=0
     for enemy in c.enemies:quota+=preload("res://scripts/attack_director.gd").weight(enemy,c.hazards,c.bullets)
     quota_peak=maxi(quota_peak,quota)
    if invalid_route:failures.append(profile.id+" invalid recorded route: "+move)
    if quota_peak>3:failures.append(profile.id+" quota exceeded: "+move)
    cases.append({"action":move,"accepted":accepted,"hp_after":c.player.hp,"quota_peak":quota_peak,"invalid_initial_route":invalid_route,"no_invulnerability_injection":true})
   records.append({"boss":profile.id,"name":profile.name,"narrow":narrow,"arena":str(c.arena_size),"cases":cases,"scope":"Normal vitality/damage, two ranged reinforcements, deterministic evade bot. Rejected moves are recorded; no human fairness or visual acceptance implied."})
   await process_frame
 var file=FileAccess.open("res://tests/boss-fairness-matrix.json",FileAccess.WRITE);file.store_string(JSON.stringify({"records":records,"failures":failures,"low_effect_visual_review":"未验收"},"  "));file.close()
 print("BOSS_FAIRNESS_MATRIX records=%d failures=%d"%[records.size(),failures.size()]);print(failures)
 quit(1 if not failures.is_empty() else 0)
