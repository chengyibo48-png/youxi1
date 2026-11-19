extends RefCounted
const W=preload("res://scripts/weapon_effects.gd")
const Art=preload("res://scripts/painterly_assets.gd")
static func footprint(canvas: CanvasItem,p: Vector2,r: float,alpha: float,inner: float=0) -> void:
 if inner>0:
  for i in 32:
   var first: Vector2=Vector2.RIGHT.rotated(i*TAU/32);var second: Vector2=Vector2.RIGHT.rotated((i+1)*TAU/32)
   canvas.draw_primitive(PackedVector2Array([p+first*inner,p+first*r,p+second*r,p+second*inner]),PackedColorArray([Color(.65,.16,.10,alpha)]),PackedVector2Array())
  for edge in [inner,r]:
   for i in 16:
    var axis=Vector2.RIGHT.rotated(i*TAU/16);W.shard(canvas,p+axis*edge,3,axis.angle(),Color(.9,.42,.22,alpha*3))
  return
 var shape=PackedVector2Array()
 for i in 32:shape.append(p+Vector2.RIGHT.rotated(i*TAU/32)*r)
 canvas.draw_colored_polygon(shape,Color(.65,.16,.10,alpha))
 # Dashed etched edge is secondary warning information, never the attack itself.
 for i in 12:
  var axis=Vector2.RIGHT.rotated(i*TAU/12)
  W.shard(canvas,p+axis*r,3,axis.angle(),Color(.9,.42,.22,alpha*3))
static func hazard(canvas: CanvasItem,h: Dictionary,clock: float,reduced: bool=false) -> void:
 var warning: bool=h.warn>0;var p: Vector2=h.pos;var r: float=h.radius
 var count: int=5 if reduced else 9
 var outer: float=r+28 if h.kind=="ring" else r
 var inner: float=maxf(0,r-28) if h.kind=="ring" else 0
 if h.kind=="laser":
  var d: Vector2=(h.end-p).normalized();var side: Vector2=d.orthogonal()*r
  canvas.draw_colored_polygon(PackedVector2Array([p-side,h.end-side,h.end+side,p+side]),Color(.8,.22,.08,.13 if warning else .28))
  var points=PackedVector2Array()
  for i in 12:points.append(p+(h.end-p)*i/11+d.orthogonal()*sin(i*2.7+clock*21)*(3 if warning else 8))
  W.ribbon(canvas,points,2 if warning else 7,Color("e9b467",.6))
  if not warning:W.grains(canvas,h.end,d,28,fmod(clock*3,1),["da9d57","metal",7,3.0],.8)
  return
 if warning:
  footprint(canvas,p,outer,.1,inner)
  var tension: float=1-h.warn/maxf(.01,h.warning)
  for i in 4:
   var at: Vector2=p+Vector2.RIGHT.rotated(i*TAU/4)*(r if h.kind=="ring" else r*(.25+.1*tension))
   W.shard(canvas,at,3+i%2,-PI/2,Color("da744b",.35+.3*tension))
  return
 var seed: float=float(str(h.kind).hash()%31)*.17
 footprint(canvas,p,outer,.07,inner)
 for i in count:
  var angle: float=i*2.399+seed;var point: Vector2=p+Vector2.RIGHT.rotated(angle)*r*(.25+.6*(i%4)/4.0)
  var phase: float=fposmod(clock*1.6+i*.19,1)
  match h.kind:
   "fire":
    var base: Vector2=point+Vector2(0,4)
    var height: float=18+25*sin(phase*PI)
    W.flame(canvas,base,height,phase+i*.4,Color("d86e37",.55))
    W.shard(canvas,point-Vector2(0,phase*36),2,-PI/2,Color("efb765",1-phase))
   "ice":W.shard(canvas,point-Vector2(0,8),9+i%3*3,-PI/2,Color("9fc3cb",.85))
   "poison":
    var ooze=PackedVector2Array()
    for j in 9:ooze.append(point+Vector2(cos(j*TAU/9),sin(j*TAU/9)*.5)*(10+sin(j*3+clock)*3))
    canvas.draw_colored_polygon(ooze,Color("718350",.45));W.shard(canvas,point-Vector2(0,phase*15),3,clock,Color("a2a76e",.6*(1-phase)))
   "web":
    var axis: Vector2=Vector2.RIGHT.rotated(angle)
    W.ribbon(canvas,PackedVector2Array([p+axis*8,p+axis*r*.5+axis.orthogonal()*3,p+axis*r]),.9,Color("c6c1b0",.8))
   "pull","gust","fog":
    var points=PackedVector2Array()
    for j in 6:points.append(point+Vector2(j*9,sin(j*.6+clock*3)*8))
    W.ribbon(canvas,points,4 if h.kind=="fog" else 2,Color("a9b9ac",.23 if h.kind=="fog" else .42))
   "ring":
    var axis: Vector2=Vector2.RIGHT.rotated(i*TAU/count)
    W.grains(canvas,p+axis*r,axis,20,phase,["b99a6c","earth",3,4.0],.7)
   "summon","blink":W.grains(canvas,point,Vector2.UP,35,phase,["a998b3","shadow",3,3.0],.5)
   _:W.shard(canvas,point-Vector2(0,sin(phase*PI)*17),7+i%3*2,angle,Color("988268",.8))
static func actor(canvas: CanvasItem,e: Dictionary,clock: float) -> void:
 var warning: float=maxf(e.get("telegraph",0),e.get("warning",0))
 var action: String=e.get("action",e.get("attack",""))
 if not e.has("profile"):action=e.get("attack","")
 var direction: Vector2=(e.target-e.pos).normalized()
 if warning>0 and action in ["rush","charge","shot","spread","volley","fan","wave","burst"]:
  var end: Vector2=e.pos+direction*(375 if e.kind=="boss" else 190)
  var side: Vector2=direction.orthogonal()*(23 if action in ["rush","charge"] else 8)
  canvas.draw_colored_polygon(PackedVector2Array([e.pos-side,end-side,end+side,e.pos+side]),Color(.72,.2,.13,.13))
  W.shard(canvas,end,8,direction.angle(),Color("bc5d40",.7))
 if e.get("rush_time",0)>0 or e.get("charging",0)>0:
  W.grains(canvas,e.pos-direction*20,-direction,40,fmod(clock*3,1),["b29a75","earth",5,4.0],.6)
 if e.get("pose_release",0)>0 and action in ["bite","sweep","slam","leap"]:
  var t: float=1-e.pose_release/.24
  var points=PackedVector2Array()
  for i in 7:points.append(e.pos-Vector2(0,25)+direction.rotated(-.7+i*.2)*60)
  W.ribbon(canvas,points,3,Color("b59876",.7*(1-t)))
 if e.get("ward",0)>0:Art.stamp(canvas,Art.relic("relic_7"),e.pos-Vector2(0,38),Vector2(58,58),clock*.2,.4)
static func projectile(canvas: CanvasItem,b: Dictionary) -> void:
 var p: Vector2=b.pos;var d: Vector2=b.dir;var type: String=b.get("visual","arrow")
 var status: String=b.get("status","")
 var color: Color=Color("c76f46")
 if status=="frost":color=Color("a4b7c6")
 elif status=="poison":color=Color("8b9c60")
 elif type in ["fan","wave"]:color=Color("b79b7b")
 var points=PackedVector2Array([p-d*20,p-d*10+d.orthogonal()*sin(b.get("age",0)*16)*2,p])
 W.ribbon(canvas,points,1.8,color)
 if type in ["fan","wave"]:
  var curl=PackedVector2Array()
  for i in 7:curl.append(p+d.orthogonal()*(i-3)*4-d*sin(i*PI/6)*5)
  W.ribbon(canvas,curl,2.3,color)
 else:W.shard(canvas,p,7 if status=="frost" else 5,d.angle(),color)
