extends SceneTree
var passed: int=0
var failed: int=0
const Frames=preload("res://scripts/painted_action_frames.gd")
const Walk=preload("res://scripts/painted_walk.gd")
const Boss=preload("res://scripts/boss_rig.gd")
func check(value: bool,message: String) -> void:
 if value:passed+=1
 else:failed+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var db=preload("res://scripts/content.gd").new()
 for role in ["wukong","tangseng","bajie","shaseng","bailongma"]:
  var frames: SpriteFrames=Frames.frames(role)
  for direction in Walk.DIRECTIONS:
   check(frames.get_frame_count(direction)==6,"Six attack stance frames per view")
   for i in 6:check(frames.get_frame_texture(direction,i).get_size()==Vector2(256,256),"Fixed attack scale")
  var action: Dictionary={"elapsed":.2,"windup":.1,"active":.12,"duration":.5,"direction":Vector2.UP}
  var p: Dictionary={"action":action,"facing":Vector2.RIGHT,"travel_speed":0,"hp":100}
  check(Frames.weight(p)>.99,"Planted action has full stance")
  check(Walk.visual_facing(p)==Vector2.UP,"Gait agrees with attack facing")
  var phase: int=Frames.phase_index(action)
  check(Frames.phase_index(action)==phase,"Redraw cannot advance attack frame")
  action.elapsed=0;check(Frames.weight(p)==0,"No pose pop at attack start")
  action.elapsed=.5;check(Frames.weight(p)==0,"Return to locomotion at recovery end")
  action.elapsed=.2;p.travel_speed=150;check(Frames.weight(p)==0,"Moving attacks retain travel gait")
  p.travel_speed=0;p.motion_state="dash";check(Frames.weight(p)==0,"Dash keeps its physical rig")
 var plans: Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/chapter_compositions.json"))
 check(plans.size()==37,"All chapter landmark compositions")
 for plan in plans:check(preload("res://scripts/chapter_scenery.gd").landmark_texture(plan.landmark)!=null,"Every story landmark resolves")
 for profile in db.tables.bosses:
  var c=preload("res://scripts/combat.gd").new(db)
  c.reset(db.find("heroes","wukong"),db.find("weapons","wukong_w0"))
  var e: Dictionary=c.spawn("boss",Vector2(800,400),0,profile.name)
  var base: Dictionary=Boss.pose(e)
  e.transition=.6;var changing: Dictionary=Boss.pose(e)
  check(changing.bones.spine!=base.bones.spine,"Phase change has body motion")
  e.transition=0;e.flash=.05
  check(Boss.pose(e).rotation!=base.rotation,"Hit recoil changes pose")
  e.flash=0;e.fall_progress=.75
  check(Boss.pose(e).bones.values().all(func(p):return p.is_finite()),"Fall joints remain finite")
  c.hazards.append({"owner":e.uid})
  c.die(e)
  var xp: float=c.player.xp;var loot: int=c.loot.size();var deaths: int=c.deaths
  c.die(e)
  check(c.player.xp==xp and c.loot.size()==loot and c.deaths==deaths,"Death animation cannot duplicate rewards")
  check(c.hazards.is_empty(),"Dead boss warnings removed")
  check(c.visuals.filter(func(v):return v.kind=="boss_fall").size()==1,"One isolated death visual")
  var saved: Dictionary=c.snapshot()
  var restored=preload("res://scripts/combat.gd").new(db);restored.restore(saved)
  check(restored.visuals==c.visuals,"Fall visual survives save without advancing")
 print("REMAINING_POLISH passed=%d failed=%d"%[passed,failed]);quit(1 if failed else 0)
