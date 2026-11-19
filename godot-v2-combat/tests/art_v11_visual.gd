extends SceneTree
var scene
var view: Node2D
var db=preload("res://scripts/content.gd").new()
var players: Array=[]
var pose_actors: Array=[]
var grid: String="heroes"
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
 view=Node2D.new();root.add_child(view);view.draw.connect(draw_grid)
 for hero in db.tables.heroes:
  var c=preload("res://scripts/combat.gd").new(db);c.reset(hero,db.for_hero("weapons",hero.id)[0]);c.player.travel_speed=150;c.player.gait=TAU*.625;c.player.facing=Vector2.RIGHT
  players.append({"role":hero.id,"name":hero.name,"player":c.player})
 view.queue_redraw();await capture("fullbody-v11-integrated-directions")
 grid="bosses"
 for id in ["boss_0","boss_1","boss_2","boss_11","boss_18","boss_23"]:
  var profile: Dictionary=db.find("bosses",id)
  var c=preload("res://scripts/combat.gd").new(db);c.reset(db.tables.heroes[0],db.tables.weapons[0]);c.configure_arena(Vector2(2400,1400))
  var e: Dictionary=c.spawn("boss",Vector2.ZERO,0,profile.name)
  e.action=profile.signature[0];e.dead=false;e.pos=Vector2.ZERO;e.motion_facing=Vector2.RIGHT;e.move_blend=0.0;e.gait=0.0;e.transition=0;e.stagger=0;e.pose_windup=1
  pose_actors.append(e)
 view.queue_redraw();await capture("boss-v11-choreography-comparison")
 view.hide()
 scene=preload("res://tests/environment_main.gd").new();scene.storage.base_path="user://art-v11-visual-only.json";scene.pause_on_focus_loss=false;scene.cinematics_enabled=false;root.add_child(scene);await process_frame
 scene.set_process(false);scene.set_physics_process(false);scene.start_demo();scene.panel.hide()
 for chapter in [3,5,7]:
  scene.chapter=chapter;scene.benchmark_environment=db.tables.chapters[chapter].biome;scene.hero_id="wukong";scene.state="playing"
  scene.fight.reset(db.tables.heroes[0],db.tables.weapons[0]);scene.fight.configure_arena(Vector2(2400,1400));scene.fight.create_layout("battle",scene.benchmark_environment,chapter)
  scene.fight.player.pos=scene.fight.arena_bounds().get_center();scene.fight.player.travel_speed=140;scene.fight.player.gait=TAU*.375;scene.fight.player.facing=Vector2.RIGHT
  scene.update_camera(.3);scene.update_hud();scene.sync_static_floor();scene.queue_redraw();await capture("art-v11-chapter-"+str(chapter))
 print("ART_V11_VISUAL screenshots=5 human_approved=0")
 scene.queue_free();view.queue_free();await process_frame;quit()
func capture(name: String) -> void:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/"+name+".png")
func draw_grid() -> void:
 view.draw_rect(Rect2(0,0,1280,720),Color("20352f"))
 var font: Font=ThemeDB.fallback_font
 view.draw_string(font,Vector2(25,30),"全身行走接入 · AI辅助暂用 / 保留原攻击握持" if grid=="heroes" else "首领招式曲线 · 蓄力 / 释放对照（非全套独立手绘）",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("ead6af"))
 if grid=="heroes":
  for row in players.size():
   for column in 4:
    var record: Dictionary=players[row];var player: Dictionary=record.player.duplicate(true);player.facing=[Vector2.DOWN,Vector2.RIGHT,Vector2.UP,Vector2.LEFT][column]
    var point=Vector2(170+column*300,151+row*132)
    preload("res://scripts/fullbody_locomotion.gd").draw(view,record.role,player,Transform2D(0,point),Color.WHITE,1)
    view.draw_set_transform_matrix(Transform2D.IDENTITY)
    view.draw_string(font,point+Vector2(-60,18),record.name+" · "+["正","右","背","左"][column],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("ead6af"))
 else:
  for index in pose_actors.size():
   for stage in 2:
    var e: Dictionary=pose_actors[index].duplicate(true);e.pos=Vector2(125+(index%3)*420+stage*160,340+(index/3)*340)
    e.warning=.3 if stage==0 else 0.0;e.pose_release=0.0 if stage==0 else .15;e.cast_released=stage==1
    preload("res://scripts/boss_rig.gd").draw(view,e)
    view.draw_set_transform_matrix(Transform2D.IDENTITY)
    view.draw_string(font,e.pos+Vector2(-85,22),e.name+" · "+("蓄力" if stage==0 else "释放"),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("ead6af"))
