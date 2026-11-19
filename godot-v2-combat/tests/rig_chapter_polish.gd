extends SceneTree
var passed: int=0
var failed: int=0
var db=preload("res://scripts/content.gd").new()
func check(value: bool,message: String) -> void:
 if value:passed+=1
 else:failed+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func fresh():
 var c=preload("res://scripts/combat.gd").new(db)
 c.reset(db.find("heroes","wukong"),db.find("weapons","wukong_w0"));c.configure_arena(Vector2(2400,1400));c.player.pos=c.arena_bounds().get_center()
 return c
func run() -> void:
 var motion=preload("res://scripts/authored_motion.gd")
 var library: AnimationLibrary=load("res://animations/combat_motion.tres")
 check(library.get_animation_list().size()==50,"Fifty authored animation clips are editable resources")
 for key in library.get_animation_list():
  var clip: Animation=library.get_animation(key)
  check(clip.track_get_key_count(0)==8,"Each action has eight explicit poses: "+key)
  check(clip.value_track_interpolate(0,0).is_equal_approx(Vector3.ZERO) and clip.value_track_interpolate(0,1).is_equal_approx(Vector3.ZERO),"Clip returns to neutral: "+key)
 var action={"elapsed":.2,"windup":.2,"active":.15,"duration":.7,"kind":"attack","weapon_style":"extend","combo":1}
 check(is_equal_approx(motion.phase(action),.32),"First hit maps to first release key")
 action.elapsed=.35;check(is_equal_approx(motion.phase(action),.57),"Last hit maps to recoil key")
 action.elapsed=.7;check(is_equal_approx(motion.phase(action),1),"Recovery reaches neutral")
 action.elapsed=.22;var value: Vector3=motion.sample("wukong",action)
 check(motion.sample("wukong",action)==value,"Repeated draw with frozen combat time never advances animation")
 check(motion.sample("tangseng",action)!=value,"Character action weighting remains distinct")
 var fire_art=preload("res://scripts/weapon_effects.gd")
 check(fire_art.flame_mesh(.25,Color("d86e37"),0)==fire_art.flame_mesh(.25,Color("d86e37",.2),0),"Flame opacity does not rebuild the same curved mesh")
 check(fire_art.flame_mesh(.25,Color("d86e37"),0).get_surface_count()==1,"A flame layer is one cached indexed mesh")
 for height in [1.0,3.0,18.0,90.0]:
  for phase in 24:
   for layer in 3:
    var surface: Dictionary=preload("res://scripts/weapon_effects.gd").flame_surface(Vector2(50,50),height,phase*.25,Color("d86e37"),layer)
    check(not Geometry2D.triangulate_polygon(surface.outline).is_empty() and surface.outline.size()==surface.colors.size(),"Curved fire surfaces triangulate at tiny/large scales and changing bends")
 for profile in db.tables.bosses:
  var c=fresh();var e: Dictionary=c.spawn("boss",c.player.pos+Vector2(240,0),0,profile.name)
  var d: Resource=preload("res://scripts/boss_rig.gd").definition(profile.id)
  check(d.stable_id==profile.id and d.title==profile.name,"Stable boss rig identity: "+profile.id)
  var skeleton=load("res://scenes/boss_rigs/"+profile.id+".tscn").instantiate()
  check(count_bones(skeleton)==d.bone_names().size(),"Editable bone scene matches runtime definition: "+profile.id)
  skeleton.free()
  for attack in profile.phase_three:
   c.bosses.begin(c,e,attack)
   var pose: Dictionary=preload("res://scripts/boss_rig.gd").pose(e)
   check(pose.bones.size()>=d.bone_names().size(),"All named bones receive poses: "+profile.id+attack)
   check(pose.bones.values().all(func(point):return point.is_finite()),"No invalid IK joint: "+profile.id+attack)
   e.warning=0;e.pose_release=.24
   var released: Dictionary=preload("res://scripts/boss_rig.gd").pose(e)
   check(released.bones.right_hand_0!=pose.bones.right_hand_0,"Boss changes stance between preparation and release: "+profile.id+attack)
 for chapter in db.tables.chapters.size():
  var c=fresh();c.rng.seed=1000+chapter;c.create_layout("battle",db.tables.chapters[chapter].biome,chapter)
  check(c.obstacles.all(func(o):return o.has("art_index") and o.chapter_identity==chapter),"Chapter scenery carries stable identity")
  check(c.geometry.visible(c.arena_origin+Vector2(120,c.arena_size.y*.5),c.exit_position(),25),"Chapter entry to exit corridor stays open")
  check(c.obstacles.all(func(o):return o.pos.distance_to(c.exit_position())>o.radius+100),"Chapter exit remains unobstructed")
  var state: Dictionary=c.snapshot();var copy=fresh();copy.restore(state)
  check(copy.obstacles==c.obstacles,"Saving keeps actual scenery and collision arrangement")
 for kind in ["shop","shrine","event","rest","reward","forge","curse"]:
  var c=fresh();var room=load("res://scenes/rewards/"+kind+".tscn").instantiate();room.chapter_index=6;room.biome="river";room.configure(c,ThemeDB.fallback_font)
  check(c.obstacles.size()==11,"Reward room includes eight location-specific props")
  check(c.geometry.visible(c.player.pos,room.interaction,20),"Reward approach remains clear")
  check(c.geometry.visible(room.interaction,c.exit_position(),20),"Reward exit remains clear")
  var before: Array=c.obstacles.duplicate(true);room.configure(c,ThemeDB.fallback_font,false)
  check(c.obstacles==before,"Returning from selection never duplicates scenery")
  room.free()
 print("RIG_CHAPTER_POLISH passed=%d failed=%d"%[passed,failed]);quit(1 if failed else 0)
func count_bones(node: Node) -> int:
 var count: int=1 if node is Bone2D else 0
 for child in node.get_children():count+=count_bones(child)
 return count
