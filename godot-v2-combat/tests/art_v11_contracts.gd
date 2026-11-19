extends SceneTree
const Body=preload("res://scripts/fullbody_locomotion.gd")
const Choreo=preload("res://scripts/boss_choreography.gd")
const Rig=preload("res://scripts/boss_rig.gd")
const Lighting=preload("res://scripts/chapter_lighting.gd")
var db=preload("res://scripts/content.gd").new()
var failures: Array=[]
var checks: int=0
func _initialize() -> void:call_deferred("run")
func check(value: bool,label: String) -> void:
 checks+=1
 if not value:failures.append(label);push_error(label)
func run() -> void:
 for hero in db.tables.heroes:
  var c=preload("res://scripts/combat.gd").new(db);c.reset(hero,db.for_hero("weapons",hero.id)[0]);c.configure_arena(Vector2(2400,1400))
  c.update(.05,Vector2.RIGHT);c.player.travel_speed=80
  check(Body.weight(hero.id,c.player)>0,hero.id+" walking body enabled")
  var d: Dictionary=Body.definition(hero.id)
  for row in 4:
   for frame in 8:
    var texture: Texture2D=Body.frame_texture(hero.id,row,frame)
    var rect: Rect2=texture.region
    check(Rect2(Vector2.ZERO,texture.atlas.get_size()).encloses(rect),hero.id+" source crop within sheet")
    check(d.frames[row][frame].pivot[1]>0 and d.scale>0,hero.id+" grounded pivot / fixed scale")
    var mesh: ArrayMesh=Body.frame_mesh(hero.id,row,frame)
    var arrays: Array=mesh.surface_get_arrays(0)
    check(mesh==Body.frame_mesh(hero.id,row,frame),hero.id+" silhouette mesh cached")
    check(arrays[Mesh.ARRAY_VERTEX].size()==d.frames[row][frame].spans.size()*4,hero.id+" connected silhouette strips complete")
    check(Array(arrays[Mesh.ARRAY_TEX_UV]).all(func(uv):return uv.x>=0 and uv.x<=1 and uv.y>=0 and uv.y<=1),hero.id+" silhouette UVs inside original sheet")
  c.player.fullbody_walk_enabled=false;check(Body.weight(hero.id,c.player)==0,hero.id+" original-art fallback")
  c.player.fullbody_walk_enabled=true
  for weapon in db.for_hero("weapons",hero.id):
   c.reset(hero,weapon);c.player.travel_speed=80;c.attack(Vector2.RIGHT)
   check(not c.player.action.is_empty() and Body.weight(hero.id,c.player)==0,weapon.id+" attack retains actual hand rig")
  c.player.action={};c.player.motion_state="dash";check(Body.weight(hero.id,c.player)==0,hero.id+" dash retains original movement")
  c.player.motion_state="idle";c.player.hp=0;check(Body.weight(hero.id,c.player)==0,hero.id+" death fallback")
 for profile in db.tables.bosses:
  var c=preload("res://scripts/combat.gd").new(db);c.reset(db.tables.heroes[0],db.tables.weapons[0]);c.configure_arena(Vector2(2400,1400));c.player.pos=c.arena_bounds().get_center()
  var e: Dictionary=c.spawn("boss",c.player.pos+Vector2(240,0),0,profile.name)
  var definition: Dictionary=Choreo.definition(profile.id)
  var signatures: Array=[]
  for action in definition.actions:
   e.action=action;e.warning=.5;e.pose_windup=1.0;e.transition=0;e.stagger=0;e.dead=false
   var sampled: Dictionary=Choreo.sample(e);signatures.append(sampled.channels)
   check(sampled.channels.any(func(v):return not is_zero_approx(v)),profile.id+action+" nonzero authored preparation")
   check(Rig.pose(e).bones.values().all(func(point):return point.is_finite()),profile.id+action+" finite preparation joints")
   e.warning=0;e.cast_released=true;e.pose_release=.12
   var released: Dictionary=Choreo.sample(e)
   check(released.channels!=sampled.channels,profile.id+action+" release differs from anticipation")
   check(Rig.pose(e).bones.values().all(func(point):return point.is_finite()),profile.id+action+" finite release joints")
   e.pose_release=0
   check(Choreo.sample(e).channels.all(func(v):return is_zero_approx(v)),profile.id+action+" recovery returns neutral")
   e.warning=.4;e.transition=1
   check(Choreo.phase(e)==-1,profile.id+action+" phase change suspends old pose")
   e.transition=0;e.stagger=1
   check(Choreo.phase(e)==-1,profile.id+action+" break cancels old pose")
   e.stagger=0;e.warning=0;e.pose_release=.2;e.cast_released=false
   check(Choreo.phase(e)==-1,profile.id+action+" canceled attack cannot fake release")
  check(signatures.size()==definition.actions.size(),profile.id+" all declared moves covered")
 for index in db.tables.chapters.size():
  var chapter: Dictionary=db.tables.chapters[index]
  check(not Lighting.definition(index,chapter.biome).is_empty(),"chapter "+str(index)+" authored atmosphere")
  var c=preload("res://scripts/combat.gd").new(db);c.reset(db.tables.heroes[0],db.tables.weapons[0]);c.configure_arena(Vector2(2400,1400));c.create_layout("battle",chapter.biome,index)
  check(c.geometry.visible(c.arena_origin+Vector2(120,c.arena_size.y*.5),c.exit_position(),25),"chapter "+str(index)+" entry-exit stays reachable")
 check(Lighting.grade(3,"desert")==Color.WHITE,"different environment cannot inherit Black Wind grade")
 var report={"checks":checks,"passed":checks-failures.size(),"failures":failures,"scope":"Actual integration contracts, 26 boss/95 move pose transitions, 37 existing paths. Not normal complete boss fights or hand-painted/human acceptance."}
 var file=FileAccess.open("res://tests/art-v11-contracts.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();print(JSON.stringify(report));quit(0 if failures.is_empty() else 1)
