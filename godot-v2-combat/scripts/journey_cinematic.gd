extends Control
var active=false
var elapsed=0.0
var duration=2.8
var title=""
var subtitle=""
var portrait: Texture2D
var hero_index=0
var font: Font
var boss=false
var boss_portrait: Texture2D
var animator=preload("res://scripts/character_pose.gd").new()
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter=Control.MOUSE_FILTER_STOP
 hide()
func play(heading: String, story: String, texture: Texture2D, index: int, type_boss: bool=false) -> void:
 title=heading;subtitle=story;portrait=texture;hero_index=index;boss=type_boss;elapsed=0;active=true;show();queue_redraw()
func skip() -> void:
 active=false;hide()
func advance(dt: float) -> void:
 if not active:return
 elapsed+=dt
 if elapsed>=duration:skip()
 else:queue_redraw()
func _process(dt: float) -> void:advance(dt)
func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.pressed:skip();accept_event()
func _draw() -> void:
 var t: float=clampf(elapsed/duration,0,1)
 var fade: float=minf(1,minf(t*8,(1-t)*8))
 draw_rect(Rect2(0,0,1280,720),Color(.04,.10,.09,fade*.92))
 draw_rect(Rect2(0,0,1280,90),Color(.025,.045,.04,fade))
 draw_rect(Rect2(0,630,1280,90),Color(.025,.045,.04,fade))
 for layer in 3:
  var mountains:=PackedVector2Array([Vector2(0,630)])
  for i in 17:mountains.append(Vector2(i*80,430-layer*45-sin(i*.8+layer+t*.6)*55))
  mountains.append(Vector2(1280,630));draw_colored_polygon(mountains,Color(.15+layer*.045,.22+layer*.04,.20+layer*.03,fade))
 draw_circle(Vector2(930,205),65,Color(.74,.60,.33,fade*.65))
 draw_line(Vector2(60,592),Vector2(1220,592),Color(.78,.65,.39,fade*.4),2)
 if portrait!=null:
  draw_set_transform(Vector2(lerpf(240,415,smoothstep(0,1,t)),540),0,Vector2(1.4,1.4))
  animator.draw(self,portrait,hero_index,{"velocity":Vector2(140,0),"gait":elapsed*8,"facing":Vector2.RIGHT},Color(1,1,1,fade),elapsed)
  draw_set_transform(Vector2.ZERO)
 if boss and boss_portrait!=null:
  var breathing: float=sin(elapsed*3)*3
  draw_texture_rect(boss_portrait,Rect2(940,410-breathing,150,205),false,Color(1,1,1,fade*.9))
 if font!=null:
  draw_string(font,Vector2(570,310),"妖王现身" if boss else "西行 · 启程",HORIZONTAL_ALIGNMENT_LEFT,600,20,Color(.78,.65,.39,fade))
  draw_string(font,Vector2(570,365),title,HORIZONTAL_ALIGNMENT_LEFT,630,38,Color(.94,.87,.69,fade))
  draw_string(font,Vector2(570,408),subtitle.substr(0,29),HORIZONTAL_ALIGNMENT_LEFT,610,18,Color(.79,.79,.66,fade))
  draw_string(font,Vector2(1010,678),"空格 / Esc / 点击跳过",HORIZONTAL_ALIGNMENT_LEFT,240,16,Color(.85,.80,.65,fade))
