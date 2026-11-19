extends Control
signal chosen(mode: String)
signal utility(action: String)
var typeface: Font
var clock: float=0
var resume_button: Button
var merit: int=0
var unlocked: int=0
func configure(font: Font) -> void:
 typeface=font;set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for i in 4:
  var titles=["启程历劫","三十七章西行","兵器与神通试炼","继续上次旅途"]
  var hints=["三域挑战 · 随机路线与局内构筑","章节战役 · 按章推进，功德留存","五角色 · 三十兵器 · 免费试用","恢复已保存的路线与本局修行"]
  var b=Button.new();b.position=Vector2(855,168+i*92);b.size=Vector2(350,78);b.text=titles[i]+"\n"+hints[i];b.alignment=HORIZONTAL_ALIGNMENT_LEFT
  b.add_theme_font_override("font",font);b.add_theme_font_size_override("font_size",17)
  var style=StyleBoxFlat.new();style.bg_color=Color("203834");style.border_color=Color("7e886a");style.set_border_width_all(1);style.content_margin_left=20;style.content_margin_top=12
  b.add_theme_stylebox_override("normal",style);var hover=style.duplicate();hover.bg_color=Color("375347");hover.border_color=Color("d8c28a");hover.set_border_width_all(2)
  b.add_theme_stylebox_override("hover",hover);b.add_theme_stylebox_override("focus",hover);b.add_theme_color_override("font_color",Color("eee0bb"));b.add_theme_color_override("font_hover_color",Color("fff1ca"));b.add_theme_color_override("font_focus_color",Color("fff1ca"))
  add_child(b)
  var action: String=["short","campaign","training","resume"][i]
  b.pressed.connect(func():chosen.emit(action))
  if i==3:resume_button=b
 var labels=["功德阁","设置与操作","导入进度"]
 for i in 3:
  var b=Button.new();b.position=Vector2(850+i*122,600);b.size=Vector2(116,42);b.text=labels[i];b.add_theme_font_override("font",font);b.add_theme_font_size_override("font_size",15);add_child(b)
  var action: String=["merit","settings","import"][i];b.pressed.connect(func():utility.emit(action))
func present(can_resume: bool, progress: int, count: int) -> void:
 resume_button.disabled=not can_resume;merit=progress;unlocked=count;queue_redraw()
 get_child(0).call_deferred("grab_focus")
func _process(dt: float) -> void:
 if visible:clock+=dt;queue_redraw()
func words(value: String,p: Vector2,size: int,color: Color) -> void:
 draw_string(typeface,p,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func _draw() -> void:
 if typeface==null:return
 draw_rect(Rect2(0,0,1280,720),Color("e4ddc7"))
 for layer in 4:
  var points=PackedVector2Array([Vector2(0,720)])
  for i in 25:points.append(Vector2(i*38,455+layer*45-sin(i*.46+layer)*75-cos(i*.73)*35))
  points.append(Vector2(930,720));draw_colored_polygon(points,Color(.22+.05*layer,.32+.045*layer,.30+.04*layer,.13+.09*layer))
 draw_rect(Rect2(800,0,480,720),Color("132b28"))
 draw_line(Vector2(802,45),Vector2(802,675),Color("b89e6e"),2,true)
 words("重生之我",Vector2(76,142),64,Color("213b34"));words("也要取经",Vector2(76,220),64,Color("213b34"))
 draw_rect(Rect2(77,247,51,51),Color("a64f39"));words("西行",Vector2(81,279),21,Color("f4e4bf"))
 words("兵器有道  ·  神通有相  ·  每局不同",Vector2(149,280),20,Color("596551"))
 words("执棍破阵，念珠归心，沙印成局。",Vector2(80,339),18,Color("445d4e"))
 words("选择你的兵器，让修行改变下一招。",Vector2(80,371),18,Color("445d4e"))
 var art=preload("res://scripts/weapon_visual.gd")
 for i in 5:
  var x: float=115+i*128
  draw_line(Vector2(x,425),Vector2(x,575),Color("69735d",.35),1,true)
  art.held(self,["wukong_w0","tangseng_w2","bajie_w4","shaseng_w1","bailongma_w4"][i],Vector2(x,484),-PI*.48,78,Transform2D.IDENTITY,Color(1,1,1,.75))
 words("国风动作肉鸽 / 本地战斗重做",Vector2(856,104),18,Color("d0bd86"))
 words("踏上西行路",Vector2(856,137),30,Color("ecddbc"))
 words("功德 %d   ·   已解锁角色 %d / 5"%[merit,unlocked],Vector2(80,645),16,Color("526655"))
 words("本人主导设计与迭代 · AI辅助开发",Vector2(80,680),14,Color("677566"))
 words("WASD移动 · 鼠标瞄准 · 按键可重设",Vector2(856,680),14,Color("b4bea8"))
