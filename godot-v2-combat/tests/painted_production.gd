extends SceneTree
var passed: int=0
var failed: int=0
var db=preload("res://scripts/content.gd").new()
const Walk=preload("res://scripts/painted_walk.gd")
const Scenery=preload("res://scripts/chapter_scenery.gd")
func check(value: bool,message: String) -> void:
 if value:passed+=1
 else:failed+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func fresh():
 var c=preload("res://scripts/combat.gd").new(db)
 c.reset(db.find("heroes","wukong"),db.find("weapons","wukong_w0"));c.configure_arena(Vector2(2400,1400));c.player.pos=c.arena_bounds().get_center()
 return c
func run() -> void:
 for role in ["wukong","tangseng","bajie","shaseng","bailongma"]:
  var resource: SpriteFrames=Walk.frames(role)
  check(resource!=null and resource.get_animation_names().size()==4,"Four painted directions: "+role)
  for direction in Walk.DIRECTIONS:
   check(resource.get_frame_count(direction)==8,"Eight fixed frames: "+role+direction)
   for i in 8:
    var t: AtlasTexture=resource.get_frame_texture(direction,i)
    check(t.region.size==Vector2(192,256),"Fixed frame scale, no independent alpha fitting")
  var p: Dictionary={"facing":Vector2.RIGHT,"gait":.7,"velocity":Vector2(150,0),"travel_speed":150.0,"hp":100}
  var before: Texture2D=Walk.sample(role,p)
  var anchor: Vector2=Walk.pivot(role,p)
  check(anchor.x==96 and anchor.y>160 and anchor.y<=256,"Sole anchor remains inside fixed cell")
  check(Walk.sample(role,p)==before,"Pause/hitstop/redraw cannot advance gait")
  check(Walk.pivot(role,p)==anchor,"Frozen time also freezes sole anchor")
  p.gait+=TAU/8
  check(Walk.sample(role,p)!=before,"Actual travel advances drawing")
  p.action={"elapsed":.23};check(Walk.weight(p)>0,"Walking attack retains frame legs")
  p.motion_state="dash";check(Walk.weight(p)==0,"Dash returns to planted-foot rig")
  p.motion_state="idle";p.travel_speed=0;check(Walk.weight(p)==0,"No stationary walking loop")
  for facing in [Vector2.DOWN,Vector2.RIGHT,Vector2.UP,Vector2.LEFT]:
   check(Walk.direction(facing)==[Vector2.DOWN,Vector2.RIGHT,Vector2.UP,Vector2.LEFT].find(facing),"Four directional frames are not left-right mirroring")
 for profile in db.tables.bosses:
  var d: Resource=preload("res://scripts/boss_rig.gd").definition(profile.id)
  for column in 7:
   var t: Texture2D=preload("res://scripts/boss_rig.gd").body_texture(d,column)
   check(t!=null and t.get_size().x>5 and t.get_size().y>5,"Dedicated boss material: "+profile.id+str(column))
  var c=fresh();var e: Dictionary=c.spawn("boss",c.player.pos+Vector2(240,0),0,profile.name)
  for move in profile.phase_three:
   c.bosses.begin(c,e,move)
   var state: Dictionary=preload("res://scripts/boss_rig.gd").pose(e)
   check(state.bones.values().all(func(p):return p.is_finite()),"Boss windup preserves finite independent joints")
 for plan in Scenery.compositions if not Scenery.compositions.is_empty() else JSON.parse_string(FileAccess.get_file_as_string("res://data/chapter_compositions.json")):
  var c=fresh();c.rng.seed=123;c.create_layout("battle",db.tables.chapters[int(plan.chapter)].biome,int(plan.chapter))
  var saved: Array=c.obstacles.duplicate(true)
  c.rng.seed=987;c.create_layout("battle",db.tables.chapters[int(plan.chapter)].biome,int(plan.chapter))
  check(saved==c.obstacles,"Bespoke composition is stable, not generic random placement")
  check(c.obstacles.any(func(o):return o.has("landmark_index")),"Chapter has actual story landmark")
  check(c.geometry.visible(c.arena_origin+Vector2(120,700),c.exit_position(),25),"Safe entry-exit corridor")
  for route in plan.paths:
   for i in range(1,route.size()):
    var start: Vector2=c.arena_origin+Vector2(route[i-1][0],route[i-1][1])
    var end: Vector2=c.arena_origin+Vector2(route[i][0],route[i][1])
    check(c.geometry.visible(start,end,25),"Visible side route is physically traversable: "+plan.place)
  var restored=fresh();restored.restore(c.snapshot())
  check(restored.obstacles==c.obstacles,"Landmark layout survives saved combat")
  for kind in ["shop","shrine","event","rest","reward","forge","curse"]:
   var room=load("res://scenes/rewards/"+kind+".tscn").instantiate();room.chapter_index=int(plan.chapter);room.configure(c,ThemeDB.fallback_font)
   check(c.obstacles.any(func(o):return o.get("landmark_index",-1)==int(plan.landmark)),"Reward carries local story landmark")
   check(c.geometry.visible(c.player.pos,room.interaction,20) and c.geometry.visible(room.interaction,c.exit_position(),20),"Local reward landmark cannot block choices or exit")
   room.free()
 print("PAINTED_PRODUCTION passed=%d failed=%d"%[passed,failed]);quit(1 if failed else 0)
