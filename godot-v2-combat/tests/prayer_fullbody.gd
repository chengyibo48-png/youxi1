extends SceneTree
const Prayer=preload("res://scripts/painted_prayer.gd")
var actor: Dictionary
var scene
var view: Node2D
var failures: Array=[]
var checks: int=0
func _initialize() -> void:call_deferred("run")
func check(value: bool,label: String) -> void:
 checks+=1
 if not value:failures.append(label)
func run() -> void:
 root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
 scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://prayer-fullbody-test-only.json";scene.pause_on_focus_loss=false;root.add_child(scene);await process_frame
 scene.set_process(false);scene.set_physics_process(false);scene.mode="training";scene.role_demo("tangseng");scene.slot=0;scene.weapon_ids=["tangseng_w3","tangseng_w0"]
 scene.fight.reset(scene.db.find("heroes","tangseng"),scene.db.find("weapons","tangseng_w3"));scene.sync_sources()
 scene.fight.player.resource=100
 scene.fight.player.hp=scene.fight.player.max_hp*.5
 check(scene.fight.skill(scene.db.find("skills","tangseng_s0"),0,Vector2.DOWN),"Real healing ability starts")
 if scene.fight.player.action.is_empty():push_error("Healing failed to start: "+scene.fight.skill_reason(scene.db.find("skills","tangseng_s0"),0));scene.queue_free();await process_frame;quit(1);return
 actor=scene.fight.player.duplicate(true);actor.action.elapsed=.1
 check(Prayer.weight("tangseng",actor)>0,"Rosary prayer uses full-body drawings")
 for direction in [Vector2.DOWN,Vector2.RIGHT,Vector2.UP,Vector2.LEFT]:
  actor.action.direction=direction
  for row in 3:
   actor.action.elapsed=[.1,actor.action.windup+.05,actor.action.windup+actor.action.active+.01][row]
   check(Prayer.phase(actor)==row,"Authoritative action timeline selects pose "+str(row))
   check(Prayer.frame_texture(row,preload("res://scripts/painted_walk.gd").direction(direction))!=null,"Full-body direction exists")
 actor.travel_speed=40;check(Prayer.weight("tangseng",actor)==0,"Moving uses existing locomotion instead of sliding planted drawing")
 actor.travel_speed=0;actor.weapon_id="tangseng_w0";check(Prayer.weight("tangseng",actor)==0,"Staff retains its own two-handed grip")
 actor.weapon_id="tangseng_w3";actor.motion_state="dash";check(Prayer.weight("tangseng",actor)==0,"Dash does not retain planted prayer")
 actor.motion_state="idle";actor.action.elapsed=actor.action.duration;check(Prayer.weight("tangseng",actor)==0,"Recovery blends back at action end")
 scene.hide()
 for child in scene.get_children():
  if child is CanvasLayer:child.hide()
 view=Node2D.new();root.add_child(view);view.draw.connect(draw_review);view.queue_redraw()
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/tangseng-prayer-fullbody-v9-review.png")
 var report={"checks":checks,"passed":checks-failures.size(),"failures":failures,"scope":"12 AI-assisted full-body prayer poses; actual heal timeline and moving/dash/staff fallback. Not complete professional five-role animation or human approval."}
 var file=FileAccess.open("res://tests/prayer-fullbody-v9.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();print(JSON.stringify(report))
 scene.queue_free();view.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
func draw_review() -> void:
 view.draw_rect(Rect2(0,0,1280,720),Color("283731"))
 var font: Font=ThemeDB.fallback_font
 view.draw_string(font,Vector2(30,35),"唐僧 · 念诵全身素材 / AI辅助 · 四朝向三阶段，非完整专业逐帧",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("e3cda5"))
 for row in 3:
  for column in 4:
   var copy: Dictionary=actor.duplicate(true);copy.action.direction=[Vector2.DOWN,Vector2.RIGHT,Vector2.UP,Vector2.LEFT][column]
   copy.action.elapsed=[.1,copy.action.windup+.05,copy.action.windup+copy.action.active+.01][row]
   var point=Vector2(170+column*305,235+row*210)
   view.draw_line(point+Vector2(-80,1),point+Vector2(80,1),Color("708f7c"),1)
   Prayer.draw(view,copy,Transform2D(Vector2(1.45,0),Vector2(0,1.45),point),Color.WHITE,1)
   view.draw_set_transform_matrix(Transform2D.IDENTITY)
   view.draw_string(font,point+Vector2(-55,25),["正面","右侧","背面","左侧"][column]+" · "+["起手","合掌","收势"][row],HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("e3cda5"))
