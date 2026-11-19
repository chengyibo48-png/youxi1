extends RefCounted
const COLORS={"beam":"e8d49b","breath":"ee9860","freeze":"91d4e1","root":"9cc790","waterwall":"7bc7cc","wave":"7bc7cc","sand":"c5a16a","sandstorm":"c5a16a","quake":"c29b73","slam":"e0b575","pull":"a29ac6","detonate":"dbb781"}
func emit(c, kind: String, origin: Vector2, direction: Vector2, radius: float, duration: float=.65) -> void:
 if c.visuals.size()>=160:return
 c.visuals.append({"kind":"spell","style":kind,"pos":origin,"direction":direction.normalized(),"radius":radius,"life":duration,"max":duration,"color":Color(COLORS.get(kind,c.hero.color))})
func draw(canvas: CanvasItem, v: Dictionary) -> void:
 var t: float=clampf(1-v.life/v.max,0,1)
 var col: Color=v.color;col.a=(1-t)*.8
 var pos: Vector2=v.pos;var dir: Vector2=v.direction;var r: float=v.radius
 var kind: String=v.style
 match kind:
  "beam","giant","heavy_line":
   var finish: Vector2=pos+dir*r
   canvas.draw_line(pos,finish,Color(col,.12*(1-t)),24 if kind=="beam" else 40,true)
   canvas.draw_line(pos,finish,col,3+sin(t*PI)*5,true)
   for i in 6:canvas.draw_line(pos+dir*(i*r/6)+dir.orthogonal()*12,pos+dir*(i*r/6)-dir.orthogonal()*12,col,2,true)
  "breath","fan","pursue","dragonflight","tide":
   var count: int=8 if kind=="tide" else 5
   for i in count:
    var angle: float=i*TAU/count if kind=="tide" else (i-2)*.18
    var d: Vector2=dir.rotated(angle)
    var center: Vector2=pos+d*r*t
    canvas.draw_line(center-d*35,center,col,4,true)
    canvas.draw_arc(center,7+t*13,0,TAU,12,col,2,true)
  "slam","quake","quakes":
   for i in 8:
    var d: Vector2=Vector2.RIGHT.rotated(i*TAU/8)
    var crack:=PackedVector2Array([pos+d*10,pos+d*r*.4+d.orthogonal()*7,pos+d*r*.7-d.orthogonal()*8,pos+d*r])
    canvas.draw_polyline(crack,col,3,true)
   canvas.draw_arc(pos,r*(.75+t*.25),0,TAU,40,col,4,true)
  "waterwall","shield","counter","marshal":
   canvas.draw_arc(pos,r,dir.angle()-PI*.42,dir.angle()+PI*.42,32,col,7,true)
   for i in 5:
    var center: Vector2=pos+dir.rotated((i-2)*.24)*r
    canvas.draw_line(center+Vector2(0,-18-t*12),center+Vector2(0,18),col,2,true)
  "pull","sandstorm","sand","detonate":
   for i in 3:
    var points:=PackedVector2Array()
    for j in 32:
     var a: float=j/31.0*TAU*1.3+i*TAU/3+t*3
     points.append(pos+Vector2.RIGHT.rotated(a)*(r*(1-j/40.0)*(1-t*.4)))
    canvas.draw_polyline(points,col,2,true)
  "freeze","root":
   for i in 10:
    var d: Vector2=Vector2.RIGHT.rotated(i*TAU/10)
    var at: Vector2=pos+d*r*(.3+t*.7)
    canvas.draw_line(at-d*14,at+d*14,col,3,true)
    canvas.draw_line(at-d.orthogonal()*8,at+d.orthogonal()*8,col,2,true)
  _:
   # Lotus petals, distinct from a generic damage ring.
   for i in 8:
    var d: Vector2=Vector2.RIGHT.rotated(i*TAU/8+t*.5)
    var petal:=PackedVector2Array([pos+d*r*.25,pos+d*r*.65+d.orthogonal()*r*.18,pos+d*r,pos+d*r*.65-d.orthogonal()*r*.18])
    canvas.draw_colored_polygon(petal,Color(col,.10*(1-t)))
    canvas.draw_polyline(petal,col,2,true)
   canvas.draw_arc(pos,r*.35,0,TAU,32,col,2,true)
