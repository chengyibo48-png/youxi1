extends RefCounted
const Art=preload("res://scripts/painterly_assets.gd")
const ROOM_INDEX={"shop":3,"shrine":2,"event":5,"rest":6,"reward":1,"forge":4,"curse":5}
static func texture(index: int) -> Texture2D:return Art.tile("spirit-props-v5-alpha",index%4,index/4,4,2)
static func cache(canvas: CanvasItem,record: Dictionary,index: int,clock: float,font: Font,nearby: bool) -> void:
 var p: Vector2=record.pos
 var which: int=index%2
 var lift: float=sin(clock*1.5+index)*1.4 if which==0 else 0.0
 Art.stamp(canvas,texture(which),p+Vector2(0,-24+lift),Vector2(42,56))
 if nearby:
  canvas.draw_string(font,p+Vector2(-42,-60),("聚灵葫芦" if which==0 else "供养莲灯")+" · +%d文"%int(record.coins),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("f4ddb0"))
static func room(canvas: CanvasItem,kind: String,p: Vector2) -> void:
 var index: int=int(ROOM_INDEX.get(kind,5))
 Art.stamp(canvas,texture(index),p+Vector2(0,-120),Vector2(180,240),0,1,Color(.86,.83,.94) if kind=="curse" else Color.WHITE)
