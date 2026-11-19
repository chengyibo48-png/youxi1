extends SceneTree
var cases: Array=[]
var canvas: Node2D
var rig=preload("res://scripts/layered_rig.gd").new()
var font: Font
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(1280,800);root.content_scale_size=Vector2i(1280,800);font=load("res://assets/chinese.ttf")
 var content=preload("res://scripts/content.gd").new()
 for hero in content.tables.heroes:
  var c=preload("res://scripts/combat.gd").new(content);c.reset(hero,content.find("weapons",hero.id+"_w0"))
  for phase in [.12,.45,.85]:
   var actor: Dictionary=c.player.duplicate(true);actor.motion_state="dash";actor.dash_pose_phase=phase;actor.facing=Vector2.RIGHT;actor.visual_dt=.016;actor.travel_speed=0;actor.action={};actor.gait=0
   actor.erase("visual_pose");actor.visual_pose_frame=-1
   cases.append({"hero":hero,"player":actor,"phase":phase})
 canvas=Node2D.new();root.add_child(canvas);canvas.draw.connect(render);canvas.queue_redraw();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/dash-poses-v7.png");canvas.queue_free();await process_frame;quit()
func render() -> void:
 canvas.draw_rect(Rect2(0,0,1280,800),Color("22392f"))
 canvas.draw_string(font,Vector2(30,34),"五角色闪避姿态 · 蹬地 / 位移 / 落地 · 程序分层演示，非专业逐帧完成稿",HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("ead8b3"))
 for column in 3:canvas.draw_string(font,Vector2(300+column*300,68),["蹬地","位移","落地"][column],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("d0bc91"))
 for index in cases.size():
  var item: Dictionary=cases[index];var row: int=index/3;var column: int=index%3
  var point: Vector2=Vector2(340+column*300,200+row*142)
  if column==0:canvas.draw_string(font,Vector2(32,point.y-50),item.hero.name,HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("ead8b3"))
  canvas.draw_line(point+Vector2(-75,4),point+Vector2(75,4),Color("728374"),1)
  var base: Transform2D=Transform2D(0,Vector2(1.1,1.1),0,point)
  rig.draw(canvas,row,item.player,Color.WHITE,0,base,item.hero.id)
  canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
