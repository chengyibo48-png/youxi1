extends RefCounted
const W=preload("res://scripts/weapon_effects.gd")
const Art=preload("res://scripts/painterly_assets.gd")
const COLORS={"wukong":"cdb26d","tangseng":"c9a77c","bajie":"a58b67","shaseng":"99b4a9","bailongma":"96c6cd"}
static func stream(canvas: CanvasItem,p: Vector2,d: Vector2,length: float,t: float,color: Color,width: float=3) -> void:
 var points=PackedVector2Array()
 for i in 10:points.append(p+d*i*length/9+d.orthogonal()*sin(i*.55+t*3)*4)
 W.ribbon(canvas,points,width,color)
static func draw(canvas: CanvasItem,v: Dictionary,reduced: bool=false) -> void:
 var p: Vector2=v.pos;var d: Vector2=v.dir;var r: float=minf(180,v.radius)
 var t: float=clampf(1-v.life/v.max,0,1);var alpha: float=(.4 if reduced else .7)*(1-t)
 var color=Color(COLORS.get(v.role,"cdb26d"),alpha)
 var effect: String=v.effect
 var material: Array=[COLORS.get(v.role,"cdb26d"),"dust",4,2.0]
 match effect:
  "anticipation":Art.stamp(canvas,Art.relic("relic_13"),p,Vector2(20,22),d.angle(),alpha*.35)
  "summon","clone","avatars":
   for sign in [-1,1]:
    var at: Vector2=p+d.orthogonal()*sign*24-Vector2(0,26)
    Art.stamp(canvas,Art.weapon("wukong_w4"),at,Vector2(56,16),d.angle(),alpha*.45)
    W.grains(canvas,at,d,24,t,material,alpha)
  "dash","lunge","charge","evade","pursue","blink":
   for sign in [-1,1]:stream(canvas,p-Vector2(0,20)+d.orthogonal()*sign*6,d,r*.7,t,color,1.8)
   W.grains(canvas,p,-d,28,t,material,alpha)
  "dragon":
   for sign in [-1,1]:stream(canvas,p-Vector2(0,24)+d.orthogonal()*sign*8,d,r,t,color,4)
   Art.stamp(canvas,Art.tile("effects",0,4,6,5),p+d*r*.7-Vector2(0,24),Vector2(52,24),d.angle(),alpha*.6)
  "beam","link":stream(canvas,p-Vector2(0,22),d,r,t,color,3.5)
  "breath","fan","arrow_rain":
   for i in 3:stream(canvas,p-Vector2(0,25),d.rotated((i-1)*.2),r*(.5+.3*t),t,color,2)
  "shield","guard","counter":
   Art.stamp(canvas,Art.relic("relic_7"),p+d*20-Vector2(0,25),Vector2(40,40),d.angle(),alpha*.6)
   W.grains(canvas,p+d*30,d,22,t,material,alpha)
  "rake_wall":
   for i in 3:Art.stamp(canvas,Art.weapon("bajie_w0"),p+Vector2((i-1)*32,-16),Vector2(40,24),-PI/2,alpha*.7)
  "pull","root":
   for sign in [-1,1]:stream(canvas,p+d.orthogonal()*sign*8,d,r*.75,t,color,1.5)
   Art.stamp(canvas,Art.relic("relic_12"),p+d*r*.55,Vector2(26,26),t,alpha*.6)
  "freeze","mark":Art.stamp(canvas,Art.relic("relic_13" if effect=="freeze" else "relic_0"),p+d*r*.3-Vector2(0,18),Vector2(28,32),0,alpha*.65)
  "seal","sanctuary","heal","lotus","waterwall","chant":
   var item: String="relic_19" if effect in ["sanctuary","lotus"] else "relic_13" if effect=="seal" else "relic_2" if effect=="waterwall" else "relic_1"
   Art.stamp(canvas,Art.relic(item),p-Vector2(0,8),Vector2(34,34),0,alpha*.5)
   for i in 5:W.shard(canvas,p+Vector2(sin(i*2.4)*r*.32,-t*20+cos(i*2.4)*r*.2),3,i,color)
  "wave","orbit","windwheel":
   for i in 3:
    var axis: Vector2=d.rotated((i-1)*.55+t*.2)
    stream(canvas,p,axis,r*.65,t,color,2)
    if effect!="wave":Art.stamp(canvas,Art.weapon("wukong_w5" if effect=="windwheel" else "wukong_w0"),p+axis*r*.55,Vector2(26,21),axis.angle()+t,alpha*.7)
  "quake","slam","detonate","sand_guardian":
   for i in 5:
    var point: Vector2=p+d*(i%3)*r*.25+d.orthogonal()*(i/3.0-.5)*32
    W.shard(canvas,point-Vector2(0,sin(t*PI)*18),6,i,color)
   W.grains(canvas,p,d,r*.5,t,[COLORS[v.role],"earth",5,4.0],alpha)
  "wake_bell":Art.stamp(canvas,Art.relic("relic_15"),p-Vector2(0,25),Vector2(34,34),sin(t*PI)*.3,alpha)
  "resource":W.grains(canvas,p-Vector2(0,12),Vector2.UP,28,t,material,alpha)
  _:W.grains(canvas,p,d,r*.5,t,material,alpha)
static func ultimate(canvas: CanvasItem,v: Dictionary,reduced: bool=false) -> void:
 var p: Vector2=v.pos;var d: Vector2=v.dir;var r: float=v.radius
 var t: float=clampf(1-v.life/v.max,0,1);var alpha: float=(.4 if reduced else .75)*(1-t)
 var name: String=v.ultimate_effect;var color=Color(COLORS[v.role],alpha)
 if v.phase=="prepare":W.grains(canvas,p,Vector2.UP,25,t,[COLORS[v.role],"charge",5,2.0],alpha);return
 match name:
  "giant":
   Art.stamp(canvas,Art.weapon("wukong_w0"),p+d*r*.45-Vector2(0,35),Vector2(r*.75,24),d.angle(),alpha*.7)
   stream(canvas,p-Vector2(0,35),d,r,t,color,6)
  "avatars","ring_storm":
   for i in 6:
    var axis=Vector2.RIGHT.rotated(i*TAU/6+t*.5)
    Art.stamp(canvas,Art.weapon("wukong_w5" if name=="ring_storm" else "wukong_w4"),p+axis*r*.5-Vector2(0,20),Vector2(40,24),axis.angle()+t,alpha*.65)
    W.grains(canvas,p+axis*r*.4,axis,28,t,[COLORS[v.role],"metal",3,2.0],alpha)
  "purification","golden_city":
   for i in 4:
    var at: Vector2=p+Vector2((i%2-.5)*r,(i/2-.5)*r*.6)
    Art.stamp(canvas,Art.relic("relic_10" if name=="golden_city" else "relic_19"),at,Vector2(55,55),0,alpha*.55)
    W.grains(canvas,at,Vector2.UP,35,t,[COLORS[v.role],"lotus",4,3.0],alpha)
  "chant":
   for i in 7:Art.stamp(canvas,Art.relic("relic_8"),p+d*i*r/7-Vector2(0,25),Vector2(24,35),sin(i+t)*.15,alpha*.7)
  "marshal","quakes","mountain_rake":
   for i in (9 if name=="mountain_rake" else 6):
    var at: Vector2=p+d*(i%3)*r*.25+d.orthogonal()*(i/3.0-1)*32
    W.shard(canvas,at-Vector2(0,sin(t*PI)*22),10,i,color)
    W.grains(canvas,at,d,35,t,["a98b62","earth",3,4.0],alpha)
  "sandstorm","sandburst","mark_collapse":
   for i in 9:
    var axis=Vector2.RIGHT.rotated(i*2.399+t)
    var at: Vector2=p+axis*r*(.15+i*.05)
    W.grains(canvas,at,axis,28,t,["b1a887","sand",3,2.0],alpha)
    if name=="mark_collapse":W.shard(canvas,at,6,i,color)
  "dragonflight","tide","sky_bow":
   for i in (5 if name=="sky_bow" else 3):
    var axis: Vector2=d.rotated((i-(2 if name=="sky_bow" else 1))*.15)
    stream(canvas,p+d.orthogonal()*(i-1)*10-Vector2(0,30),axis,r,t,color,3.5 if name=="dragonflight" else 2)
    if name=="tide":W.grains(canvas,p+axis*r*.6,-axis,35,t,["b8d5d2","foam",5,2.0],alpha)
