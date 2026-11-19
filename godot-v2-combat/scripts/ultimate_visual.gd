extends RefCounted
static func legacy_draw(canvas: CanvasItem,v: Dictionary,reduced: bool=false) -> void:
 var p: Vector2=v.pos;var d: Vector2=v.dir;var side: Vector2=d.orthogonal();var r: float=v.radius
 var t: float=clampf(1-v.life/v.max,0,1);var col=Color(v.color,(1-t)*(.4 if reduced else .75))
 match v.ultimate_effect:
  "giant":
   var end: Vector2=p+d*r
   canvas.draw_line(p,end,Color(col,.12),65,true);canvas.draw_line(p,end,col,15,true)
   for i in 7:canvas.draw_line(p+d*i*r/7-side*25,p+d*i*r/7+side*25,Color(col,.45),3,true)
  "avatars":
   for i in 6:
    var point: Vector2=p+Vector2.RIGHT.rotated(i*TAU/6)*r*.38
    canvas.draw_circle(point-Vector2(0,40),8,col);canvas.draw_line(point-Vector2(0,30),point+Vector2(0,5),col,7,true)
    canvas.draw_line(point-Vector2(35,5),point+Vector2(50,15),col,4,true)
  "purification":
   for band in 3:
    var ring: float=r*(.25+band*.23)
    canvas.draw_arc(p,ring,0,TAU,48,Color(col,(1-t)*(.65-band*.15)),3,true)
    for i in 12:
     var axis=Vector2.RIGHT.rotated(i*TAU/12)
     canvas.draw_colored_polygon(PackedVector2Array([p+axis*ring,p+axis*ring*.72+axis.orthogonal()*13,p+axis*ring*.6,p+axis*ring*.72-axis.orthogonal()*13]),Color(col,.3))
  "chant":
   for i in 8:
    var point=p+d*(40+i*r/9)
    canvas.draw_rect(Rect2(point-Vector2(13,20),Vector2(26,40)),col,false,2)
    for j in 3:canvas.draw_line(point+Vector2(-7,-10+j*10),point+Vector2(7,-10+j*10),col,2,true)
   canvas.draw_line(p-side*32,p+d*r-side*32,Color(col,.4),3,true)
  "marshal":
   var end=p+d*r*.35
   canvas.draw_line(end-Vector2(0,130*(1-t)),end,col,14,true)
   for i in 9:canvas.draw_line(end+side*(i-4)*16-d*18,end+side*(i-4)*16+d*28,col,6,true)
   canvas.draw_arc(end,r*.45,0,TAU,48,Color(col,.35),5,true)
  "quakes":
   for j in 3:
    var points=PackedVector2Array()
    for i in 13:points.append(p+d*i*r/13+side*(j-1)*50+side*(12 if i%2==0 else -12))
    canvas.draw_polyline(points,col,4,true)
  "sandstorm":
   for i in 28:
    var angle: float=i*.48+t*TAU;var length: float=r*(.1+i/35.0)
    var point=p+Vector2.RIGHT.rotated(angle)*length
    canvas.draw_line(point,point+Vector2.RIGHT.rotated(angle+.7)*18,col,3,true)
  "sandburst":
   for i in 6:
    var angle: float=i*TAU/6+t
    canvas.draw_arc(p+Vector2.RIGHT.rotated(angle)*r*.55,r*.2,angle-2.2,angle+2.2,24,col,6,true)
  "dragonflight":
   var points=PackedVector2Array()
   for i in 30:points.append(p+d*i*r/30+side*sin(i*.5-t*8)*25)
   canvas.draw_polyline(points,Color(col,.1),45,true);canvas.draw_polyline(points,col,9,true)
   var end: Vector2=p+d*r
   canvas.draw_colored_polygon(PackedVector2Array([end+d*30,end-side*22,end-d*15,end+side*22]),col)
   for i in 8:canvas.draw_line(points[i*3],points[i*3]+side*(16 if i%2==0 else -16),col,3,true)
  "tide":
   for i in 7:
    var angle: float=i*TAU/7+t*2;var direction=Vector2.RIGHT.rotated(angle)
    var point=p+direction*r*(.5 if t<.5 else 1-t)
    canvas.draw_line(point-direction*20,point+direction*24,col,5,true);canvas.draw_line(point-direction.orthogonal()*10,point+direction.orthogonal()*10,col,2,true)

  "ring_storm":
   for i in 12:canvas.draw_arc(p+Vector2.RIGHT.rotated(i*TAU/12+t)*r*(.15+sin(t*PI)*.7),18,0,TAU,20,col,4,true)
  "golden_city":
   canvas.draw_rect(Rect2(p-Vector2.ONE*r*.6,Vector2.ONE*r*1.2),Color(col,.15));canvas.draw_rect(Rect2(p-Vector2.ONE*r*.6,Vector2.ONE*r*1.2),col,false,4)
   for axis in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:canvas.draw_line(p+axis*r*.25,p+axis*r*.55,col,6,true)
  "mountain_rake":
   for row in 3:
    for i in 9:canvas.draw_line(p+d*(60+row*85)+side*(i-4)*20-Vector2(0,60*(1-t)),p+d*(60+row*85)+side*(i-4)*20,col,4,true)
  "mark_collapse":
   for i in 8:
    var point=p+Vector2.RIGHT.rotated(i*TAU/8)*r*(1-t)
    canvas.draw_rect(Rect2(point-Vector2.ONE*13,Vector2.ONE*26),col,false,3);canvas.draw_line(point,p,Color(col,.2),2,true)
  "sky_bow":
   for i in 9:
    var axis=d.rotated((i-4)*.16);var end=p+axis*r*(.2+sin(t*PI)*.8)
    canvas.draw_line(end-axis*35,end,col,5,true);canvas.draw_line(end-axis*14-axis.orthogonal()*8,end,col,3,true)

static func emit(c,a: Dictionary,phase: String) -> void:
 var effect: String=a.definition.effect
 var radius: float=460 if effect=="giant" else 500 if effect=="dragonflight" else 400 if effect=="chant" else 400 if effect=="sky_bow" else 300 if effect=="mountain_rake" else 230
 c.visuals.append({"kind":"role_fx","role":c.hero.id,"effect":"ultimate_stage","ultimate_effect":effect,"phase":phase,"pos":c.player.pos,"dir":a.direction,"radius":radius*(.45 if phase=="prepare" else 1),"life":a.windup if phase=="prepare" else 1.2,"max":a.windup if phase=="prepare" else 1.2,"color":Color(c.hero.color)})

static func draw(canvas: CanvasItem,v: Dictionary,reduced: bool=false) -> void:
 var t: float=clampf(1-v.life/v.max,0,1);var role: String=v.get("role","wukong")
 var art=preload("res://scripts/painterly_assets.gd");var r: float=v.radius
 var name: String=v.ultimate_effect
 if name in ["giant","marshal","dragonflight","sky_bow"]:
  for i in 4:art.burst(canvas,role,v.pos+v.dir*r*i/4,v.dir,r*.8,clampf(t-i*.07,0,1),.4 if reduced else .7,1)
  if name=="giant":art.stamp(canvas,art.weapon("wukong_w0"),v.pos+v.dir*r*.45,Vector2(r*1.3,r*.45),v.dir.angle(),(1-t)*.75)
  elif name=="marshal":art.stamp(canvas,art.weapon("bajie_w0"),v.pos+v.dir*r*.3-Vector2(0,80*(1-t)),Vector2(190,150),PI/2,(1-t)*.75)
  return
 if name in ["chant","golden_city","purification"]:
  var icon: String="relic_10" if name=="golden_city" else "relic_8" if name=="chant" else "relic_19"
  for i in 4:
   var at: Vector2=v.pos+Vector2((i%2-.5)*r,(i/2-.5)*r*.65)
   art.stamp(canvas,art.relic(icon),at,Vector2(110,110),sin(t*PI)*.12,(1-t)*.7)
   art.burst(canvas,role,at,Vector2.ZERO,r*.65,t,.45,2)
  return
 var count: int=3 if reduced else 5
 for i in count:
  var d: Vector2=v.dir.rotated((i-(count-1)*.5)*.38)
  if name in ["avatars","ring_storm","sandstorm","tide"]:d=Vector2.RIGHT.rotated(i*TAU/count+t*1.2)
  var p: Vector2=v.pos+d*r*(.12+i*.08)
  if name in ["ring_storm","avatars"]:art.stamp(canvas,art.weapon("wukong_w5" if name=="ring_storm" else "wukong_w4"),p,Vector2(90,72),d.angle()+t*TAU,(1-t)*.7)
  art.burst(canvas,role,p,d,r*.62,clampf(t-i*.05,0,1),.35 if reduced else .62,i%3)
