extends Control
var model: Dictionary={}
var font: Font
var icons
var text_wrap_cache: Dictionary={}
var text_wrap_hits: int=0
var text_wrap_misses: int=0
func configure(typeface: Font, catalog) -> void:
 text_wrap_cache.clear()
 font=typeface;icons=catalog;mouse_filter=Control.MOUSE_FILTER_IGNORE
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
func wrapped(value: String,size: int) -> String:
 var key: String=str(size)+":"+value
 if text_wrap_cache.has(key):text_wrap_hits+=1;return text_wrap_cache[key]
 text_wrap_misses+=1
 if text_wrap_cache.size()>=1024:text_wrap_cache.clear()
 var result: String=wrap_status(value,font,85,size)
 text_wrap_cache[key]=result
 return result
func present(view: Dictionary) -> void:
 if model==view:return
 model=view;queue_redraw()
func label_at(value: String, point: Vector2, size: int=15, color: Color=Color("ead8ac")) -> void:
 draw_string(font,point,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func bar(rect: Rect2, current: float, maximum: float, color: Color) -> void:
 draw_rect(rect,Color("344d48"));draw_rect(Rect2(rect.position,Vector2(rect.size.x*clampf(current/maxf(1,maximum),0,1),rect.size.y)),color)
func _draw() -> void:
 if model.is_empty():return
 draw_rect(Rect2(0,0,1280,115),Color("192e2d"))
 label_at(model.title,Vector2(24,26),20)
 if not model.has("hp"):return
 label_at("生命 %d/%d · 护盾 %d"%[model.hp,model.max_hp,model.shield],Vector2(24,47),14)
 bar(Rect2(24,54,270,10),model.hp,model.max_hp,Color("c06b55"))
 resource_display()
 label_at(model.resource_name+" %d"%model.resource+(" · 印%d"%model.get("marked",0) if model.get("role_id","")=="shaseng" else "")+" · 铜钱 %d"%model.coins,Vector2(24,101),14)
 label_at(model.weapon,Vector2(320,28),18)
 label_at(model.location,Vector2(320,52),14)
 label_at(model.action,Vector2(320,77),14,Color("d6bb76"))
 label_at(model.get("resource_note","") if model.get("resource_note","")!="" else model.help,Vector2(320,101),12)
 for index in model.slots.size():
  var slot: Dictionary=model.slots[index]
  var rect=Rect2(610+index*109,10,101,103)
  draw_rect(rect,Color("29443e"));draw_rect(rect,Color("9b8a61") if slot.ready else Color("5d7065"),false,1)
  var graphic=icons.icon(slot.id)
  if graphic!=null:draw_texture_rect(graphic,Rect2(rect.position+Vector2(8,7),32*Vector2.ONE),false,Color.WHITE if slot.ready else Color(.65,.7,.7))
  label_at(slot.key,rect.position+Vector2(49,28),16)
  draw_multiline_string(font,rect.position+Vector2(8,50),wrapped(str(slot.name),11),HORIZONTAL_ALIGNMENT_LEFT,85,11,-1,Color("ead8ac"))
  var status: String=wrapped(str(slot.status),9)
  draw_multiline_string(font,rect.position+Vector2(8,76),status,HORIZONTAL_ALIGNMENT_LEFT,85,9,-1,Color("e5ce91") if slot.ready else Color("adbbb0"))
  if slot.cooldown>0:draw_rect(Rect2(rect.position+Vector2(8,100),Vector2(85*clampf(slot.cooldown/maxf(1,slot.maximum),0,1),2)),Color("8caaa0"))

func resource_display() -> void:
 var role: String=model.get("role_id","wukong")
 var ratio: float=clampf(model.resource/100.0,0,1)
 match role:
  "wukong":
   for i in 5:bar(Rect2(24+i*55,74,48,8),clampf(model.resource-i*20,0,20),20,Color("d3b567"))
  "tangseng":
   bar(Rect2(24,74,220,7),model.resource,100,Color("c28261"))
   draw_arc(Vector2(271,76),10,-PI/2,-PI/2+maxf(.01,ratio*TAU),24,Color("e2bd79"),3,true)
  "bajie":
   bar(Rect2(24,74,270,10),model.resource,100,Color("b88f60"))
   for i in 9:draw_line(Vector2(24+i*30,74),Vector2(24+i*30,84),Color("263b34"),2)
  "shaseng":
   bar(Rect2(24,74,180,7),model.resource,100,Color("8eaca1"))
   for i in 6:
    var p=Vector2(218+i*13,77)
    draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(4,0),p+Vector2(0,4),p+Vector2(-4,0)]),Color("d5b57d") if i<model.get("marked",0) else Color("52665b"))
  "bailongma":
   bar(Rect2(24,74,270,7),model.resource,100,Color("82c9dc"))
   draw_line(Vector2(24,83),Vector2(24+270*ratio,83),Color("b8e8eb"),1)
static func wrap_status(value: String,typeface: Font,width: float,size: int) -> String:
 var result: String="";var line: String=""
 for character in value:
  if character=="\n":result+=line+"\n";line="";continue
  if not line.is_empty() and typeface.get_string_size(line+character,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>width:
   result+=line+"\n";line=""
  line+=character
 return result+line
