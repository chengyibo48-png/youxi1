extends SceneTree
# Candidate-sheet review only. Never writes approval into gameplay or art inventory.
const ROLES=["wukong","tangseng","bajie","shaseng","bailongma"]
const NAMES=["悟空","唐僧","八戒","沙僧","白龙马"]
const DIRECTIONS=["正面","右侧","背面","左侧"]
var role_index: int=0
var direction: int=0
var frame: int=0
var speed: float=.25
var elapsed: float=0
var playing: bool=false
var view: Node2D
var status: Label
var note: LineEdit
var hero_picker: OptionButton
var facing_picker: OptionButton
var sheets: Dictionary={}
var audit: Dictionary={}
var textures: Dictionary={}
var ready: bool=false
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
 root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
 if FileAccess.file_exists("res://tests/fullbody-walk-v10-audit.json"):
  var parsed=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fullbody-walk-v10-audit.json"))
  if parsed is Dictionary:
   for entry in parsed.get("assets",[]):audit[entry.role]=entry
 for role in ROLES:
  var path="res://assets/painterly/"+role+"-fullbody-walk-v10-draft.png"
  if ResourceLoader.exists(path):sheets[role]=load(path)
 view=Node2D.new();root.add_child(view);view.draw.connect(render)
 var box=VBoxContainer.new();box.position=Vector2(20,12);box.size=Vector2(1240,150);root.add_child(box)
 var title=Label.new();title.text="五角色 · 全身行走帧审查 / AI辅助候选，尚未通过步态及人工验收";box.add_child(title)
 var row=HBoxContainer.new();box.add_child(row)
 hero_picker=OptionButton.new();row.add_child(hero_picker)
 for name in NAMES:hero_picker.add_item(name)
 hero_picker.item_selected.connect(func(index):role_index=index;reset())
 facing_picker=OptionButton.new();row.add_child(facing_picker)
 for name in DIRECTIONS:facing_picker.add_item(name)
 facing_picker.item_selected.connect(func(index):direction=index;reset())
 var rates=OptionButton.new();row.add_child(rates)
 for name in ["1/4速度","1/2速度","正常速度"]:rates.add_item(name)
 rates.item_selected.connect(func(index):speed=[.25,.5,1.0][index])
 for pair in [["播放 / 暂停",func():playing=not playing], ["前一帧",func():step(-1)], ["后一帧",func():step(1)]]:
  var button=Button.new();button.text=pair[0];row.add_child(button);button.pressed.connect(pair[1])
 note=LineEdit.new();note.placeholder_text="记录：重复步态、脚底滑动、比例跳变、衣摆穿模等";box.add_child(note)
 var record_button=Button.new();record_button.text="保存检查记录（不等于专业美术验收）";record_button.pressed.connect(record);row.add_child(record_button)
 status=Label.new();status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;box.add_child(status)
 ready=true;reset()
 if "--snapshots" in OS.get_cmdline_user_args():
  for role in ROLES.size():
   role_index=role;direction=1;frame=0;hero_picker.select(role);facing_picker.select(1);view.queue_redraw()
   await process_frame;await process_frame;await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://tests/fullbody-v10-"+ROLES[role]+"-review.png")
  print("FIVE_ROLE_REVIEW snapshots=5 professional_approved=0")
  quit()
func reset() -> void:
 frame=0;elapsed=0;playing=false
func step(amount: int) -> void:
 playing=false;frame=posmod(frame+amount,8);elapsed=frame/12.0
func _process(dt: float) -> bool:
 if not ready:return false
 if playing:elapsed+=minf(dt,.05)*speed;frame=int(elapsed*12)%8
 var entry: Dictionary=audit.get(ROLES[role_index],{})
 var cells: Array=entry.get("cells",[])
 var edge: String="边界尚未检查" if cells.is_empty() else "裁切边界异常" if not cells[direction*8+frame].clear_edges else "裁切边界正常（不代表动作正确）"
 status.text="%s · %s · 第%d/8帧 · %s\n固定比例、脚底基准；上排当前步态，下方完整8帧。重点对比1/5、2/6、3/7、4/8帧的左右脚。"%[NAMES[role_index],DIRECTIONS[direction],frame+1,edge]
 view.queue_redraw();return false
func texture_at(column: int) -> Texture2D:
 var role: String=ROLES[role_index]
 if not sheets.has(role):return null
 var key=role+"/"+str(direction)+"/"+str(column)
 if not textures.has(key):
  var sheet: Texture2D=sheets[role];var size=Vector2(sheet.get_width()/8.0,sheet.get_height()/4.0)
  var tile=AtlasTexture.new();tile.atlas=sheet;tile.region=Rect2(Vector2(column,direction)*size,size);tile.filter_clip=true;textures[key]=tile
 return textures[key]
func draw_frame(column: int,point: Vector2,scale: float) -> void:
 var tile: Texture2D=texture_at(column)
 if tile==null:return
 var cells: Array=audit.get(ROLES[role_index],{}).get("cells",[])
 var pivot=Vector2(tile.get_width()*.5,tile.get_height())
 if not cells.is_empty():
  var values: Array=cells[direction*8+column].foot_pivot;pivot=Vector2(values[0],values[1])
 view.draw_line(point+Vector2(-85,1),point+Vector2(85,1),Color("58786c"),1)
 view.draw_texture_rect(tile,Rect2(point-pivot*scale,tile.get_size()*scale),false)
func render() -> void:
 view.draw_rect(Rect2(0,0,1280,720),Color("182b27"))
 var font=ThemeDB.fallback_font
 if not sheets.has(ROLES[role_index]):
  view.draw_string(font,Vector2(40,250),"素材尚未生成 / 不使用其他角色代替",HORIZONTAL_ALIGNMENT_LEFT,-1,24);return
 draw_frame(frame,Vector2(240,470),1.05)
 draw_frame((frame+4)%8,Vector2(600,470),1.05)
 view.draw_string(font,Vector2(120,500),"当前帧 / 应与对侧半步明显不同",HORIZONTAL_ALIGNMENT_LEFT,-1,19)
 view.draw_string(font,Vector2(500,500),"相隔半周期的帧",HORIZONTAL_ALIGNMENT_LEFT,-1,19)
 view.draw_string(font,Vector2(870,260),"注意：像素不同不代表步态正确",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e6bd7d"))
 view.draw_string(font,Vector2(870,300),"本检查台不修改游戏存档",HORIZONTAL_ALIGNMENT_LEFT,-1,18)
 for column in 8:
  var point=Vector2(82+column*158,680);draw_frame(column,point,.48)
  view.draw_string(font,point+Vector2(-12,27),str(column+1),HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("ead6aa"))
  if column==frame:view.draw_rect(Rect2(point+Vector2(-60,-132),Vector2(120,158)),Color("e6bd7d"),false,2)
func record() -> void:
 var path="user://five-role-fullbody-review.json"
 var records: Array=[]
 if FileAccess.file_exists(path):
  var parsed=JSON.parse_string(FileAccess.get_file_as_string(path))
  if parsed is Array:records=parsed
 var asset="res://assets/painterly/"+ROLES[role_index]+"-fullbody-walk-v10-draft.png"
 records.append({"hero":ROLES[role_index],"direction":direction,"frame":frame,"note":note.text,
  "asset_sha256":FileAccess.get_sha256(asset),"source":"manual workbench interaction", "professional_approval":false})
 var file=FileAccess.open(path,FileAccess.WRITE)
 if file==null:status.text="检查记录写入失败："+str(FileAccess.get_open_error());return
 file.store_string(JSON.stringify(records,"  "));file.close();note.clear()
