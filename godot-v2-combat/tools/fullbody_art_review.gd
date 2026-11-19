extends SceneTree
# Original AI-assisted draft. This viewer does not certify hand-drawn animation.
var frame: int=0
var direction: int=0
var speed: float=.25
var elapsed: float=0
var playing: bool=true
var view: Node2D
var status: Label
var sheet: Texture2D
var pivots: Array=[]
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
 root.size=Vector2i(1100,720)
 sheet=load("res://assets/painterly/wukong-fullbody-walk-v6-alpha.png")
 var image: Image=sheet.get_image()
 var cells: Array=[]
 for row in 4:
  var anchors: Array=[]
  for column in 8:
   var region: Rect2i=Rect2i(column*192,row*256,192,256)
   var left: int=192;var top: int=256;var right: int=0;var bottom: int=0
   for y in 256:
    for x in 192:
     if image.get_pixel(region.position.x+x,region.position.y+y).a>.1:
      left=mini(left,x);top=mini(top,y);right=maxi(right,x+1);bottom=maxi(bottom,y+1)
   var used: Rect2i=Rect2i(left,top,right-left,bottom-top)
   anchors.append(Vector2(96,used.end.y))
   cells.append({"direction":row,"frame":column,"alpha_bounds":[used.position.x,used.position.y,used.size.x,used.size.y],"edge_clear":used.position.x>0 and used.position.y>0 and used.end.x<192 and used.end.y<256})
  pivots.append(anchors)
 var report={"asset":"wukong-fullbody-walk-v6-alpha.png","origin":"Original AI-assisted painted draft","cell_size":[192,256],"frames":32,"background_alpha":image.get_pixel(0,0).a,"cells":cells,"human_slow_motion_review":"pending","professional_hand_drawn_acceptance":false,"combat_integration":"withheld: hand anchors, phase continuity and pose consistency require review"}
 var file=FileAccess.open("res://tests/fullbody-art-v6-audit.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
 view=Node2D.new();root.add_child(view);view.draw.connect(render)
 var panel=VBoxContainer.new();panel.position=Vector2(25,20);panel.size=Vector2(1050,130);root.add_child(panel)
 var title=Label.new();title.text="悟空 · 四朝向全身逐帧素材检查（AI辅助样板，尚未人工验收）";panel.add_child(title)
 var controls=HBoxContainer.new();panel.add_child(controls)
 var directions=OptionButton.new();controls.add_child(directions)
 for label in ["正面","右侧","背面","左侧"]:directions.add_item(label)
 directions.item_selected.connect(func(index):direction=index;frame=0;elapsed=0)
 var rates=OptionButton.new();controls.add_child(rates)
 for label in ["1/4速度","1/2速度","正常速度"]:rates.add_item(label)
 rates.item_selected.connect(func(index):speed=[.25,.5,1.0][index])
 for pair in [["播放 / 暂停",func():playing=not playing],["前一帧",func():playing=false;frame=posmod(frame-1,8)],["后一帧",func():playing=false;frame=(frame+1)%8]]:
  var button=Button.new();button.text=pair[0];controls.add_child(button);button.pressed.connect(pair[1])
 status=Label.new();panel.add_child(status)
 if "--snapshot" in OS.get_cmdline_user_args():
  view.queue_redraw();await process_frame;await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://tests/fullbody-art-v6-review.png");quit()
func _process(dt: float) -> bool:
 if sheet==null:return false
 if playing:
  elapsed+=dt*speed
  frame=int(elapsed*8)%8
 status.text="帧 %d / 8 · 样板仍存在帧间重复与边界问题，禁止当作完成版 · 检查重心、衣摆与握持"%[frame+1]
 view.queue_redraw()
 return false
func render() -> void:
 view.draw_rect(Rect2(0,0,1100,720),Color("20382f"))
 var texture=AtlasTexture.new();texture.atlas=sheet;texture.region=Rect2(frame*192,direction*256,192,256);texture.filter_clip=true
 var anchor: Vector2=pivots[direction][frame]
 view.draw_line(Vector2(80,620),Vector2(1020,620),Color("759887"),1)
 view.draw_texture_rect(texture,Rect2(Vector2(250,620)-anchor*1.8,Vector2(192,256)*1.8),false)
 for column in 8:
  var small=AtlasTexture.new();small.atlas=sheet;small.region=Rect2(column*192,direction*256,192,256);small.filter_clip=true
  view.draw_texture_rect(small,Rect2(Vector2(430+column%4*155,170+floori(column/4.0)*240),Vector2(134,179)),false)
  if column==frame:view.draw_rect(Rect2(Vector2(430+column%4*155,170+floori(column/4.0)*240),Vector2(134,179)),Color("ddbc7e"),false,2)
