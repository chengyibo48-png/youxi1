extends SceneTree
var scene
var view: Node2D
var actor: Dictionary
var failures: Array=[]
var checks: int=0
const Cast=preload("res://scripts/painted_boss_cast.gd")
func _initialize() -> void:call_deferred("run")
func check(value: bool,label: String) -> void:
 checks+=1
 if not value:failures.append(label)
func run() -> void:
 root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
 scene=preload("res://tests/environment_main.gd").new();scene.storage.base_path="user://art-v9-visual-only.json";scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 root.add_child(scene);await process_frame;scene.set_physics_process(false);scene.start_demo();scene.panel.hide()
 var floors=preload("res://scripts/journey_scene_art.gd")
 for entry in [[0,"forest"],[12,"ember"],[15,"snow"]]:
  scene.chapter=entry[0];scene.benchmark_environment=entry[1]
  scene.fight.create_layout("combat",entry[1],entry[0]);scene.fight.player.pos=scene.fight.arena_bounds().get_center();scene.fight.enemies=[]
  scene.camera_initialized=false;scene.update_camera(.2);scene.update_hud();scene.queue_redraw();scene.sync_static_floor()
  await process_frame;await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://tests/art-v9-chapter-%02d.png"%entry[0])
  check(floors.chapter_floor(entry[0],entry[1])!=floors.complete_floor(entry[1]),"Dedicated chapter painting "+str(entry[0]))
 check(floors.chapter_floor(0,"river")==floors.complete_floor("river"),"Training biome override does not select wrong chapter terrain")
 actor=scene.fight.spawn("boss",scene.fight.player.pos+Vector2(300,0),0,"红孩儿").duplicate(true)
 actor.pos=Vector2(320,610);actor.action="fire";actor.transition=0;actor.stagger=0;actor.warning=.8;actor.pose_windup=.95;actor.motion_facing=Vector2.RIGHT
 check(Cast.frame_index(actor)==0,"Early anticipation")
 actor.warning=.3;check(Cast.frame_index(actor)==1,"Late anticipation")
 actor.warning=0;actor.pose_release=.23;actor.cast_released=false;check(Cast.frame_index(actor)==-1,"Cancelled windup does not emit a release pose")
 scene.fight.bosses.execute(scene.fight,actor);check(Cast.frame_index(actor)==2,"Committed fire release")
 actor.pose_release=.1;check(Cast.frame_index(actor)==3,"Recovery")
 scene.fight.bosses.interrupt(scene.fight,actor);check(Cast.frame_index(actor)==-1,"Interruption clears committed presentation")
 actor.cast_released=true;actor.motion_facing=Vector2.DOWN;check(Cast.frame_index(actor)==-1,"Unmade direction uses articulated fallback")
 actor.motion_facing=Vector2.RIGHT;actor.transition=1;check(Cast.frame_index(actor)==-1,"Phase transition suppresses casting pose")
 scene.set_process(false);scene.hide()
 for child in scene.get_children():
  if child is CanvasLayer:child.hide()
 view=Node2D.new();root.add_child(view);view.draw.connect(draw_review);view.queue_redraw()
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/redboy-fullbody-v9-review.png")
 var report={"checks":checks,"passed":checks-failures.size(),"failures":failures,"scope":"Three chapter floor selections and Red Boy cast phase/fallback/interruption contracts; AI-assisted four side poses, not 26 complete boss sets or human animation acceptance"}
 var file=FileAccess.open("res://tests/art-v9-contracts.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();print(JSON.stringify(report))
 scene.queue_free();view.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
func draw_review() -> void:
 view.draw_rect(Rect2(0,0,1280,720),Color("283731"))
 var font: Font=ThemeDB.fallback_font
 view.draw_string(font,Vector2(35,40),"红孩儿 · 独立全身吐火姿态 / AI辅助素材 · 侧向及镜像，非完整四朝向",HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("e3cda5"))
 for row in 2:
  for index in 4:
   var copy: Dictionary=actor.duplicate(true);copy.pos=Vector2(160+index*310,340+row*320);copy.transition=0;copy.stagger=0;copy.cast_released=true;copy.action="fire"
   copy.motion_facing=Vector2.RIGHT if row==0 else Vector2.LEFT
   copy.warning=[.8,.3,0,0][index];copy.pose_release=[0,0,.23,.1][index]
   view.draw_line(copy.pos+Vector2(-115,1),copy.pos+Vector2(115,1),Color("708f7c"),1)
   Cast.draw(view,copy,1)
   view.draw_string(font,copy.pos+Vector2(-110,35),["吸气蓄势","蓄势顶点","吐火释放","收势"][index],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("e3cda5"))
