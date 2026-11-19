extends RefCounted
const Art=preload("res://scripts/painterly_assets.gd")
const Geometry=preload("res://scripts/action_geometry.gd")
static var flame_meshes: Dictionary={}
static var ribbon_tapers: Dictionary={}
static func ribbon_taper(count: int) -> Array:
 if not ribbon_tapers.has(count):
  var factors: Array=[]
  for index in count-1:
   factors.append([sin((index+.5)/count*PI),.7+.3*sin(index*2.7),sin((index+1.5)/count*PI),.7+.3*sin((index+1)*2.7)])
  # Keep this geometry-only cache bounded for externally supplied long paths.
  if ribbon_tapers.size()>=64:ribbon_tapers.erase(ribbon_tapers.keys()[0])
  ribbon_tapers[count]=factors
 return ribbon_tapers[count]
# Distinct material, emission rule, particle count and size, not a role-colour swap.
const MATERIALS={
 "extend":["d9b96a","metal",5,2.0],"pin":["b2ccbc","pillar",5,3.0],"flame":["de713d","embers",8,3.0],"dual":["cbbb86","cross",4,2.0],"phantom":["a29ab4","echo",3,2.0],
 "stamp":["ceaa7c","stamp",4,3.0],"mandala":["c7ac69","paper",6,3.0],"rosary":["c6a563","chime",5,2.0],"scripture":["a96548","beads",4,3.0],"bell":["b79860","pressure",6,3.0],
 "rake":["a5af9a","teeth",9,3.0],"hook":["b5bca9","hook",4,2.0],"furrow":["987a53","earth",7,5.0],"ice_hammer":["a4c9d2","ice",5,4.0],"meteor":["a7a38c","chain",4,3.0],
 "crescent_staff":["99bbae","crescent",4,2.0],"crescent":["acd3c5","return_blade",4,2.0],"shards":["9faeac","shards",6,3.0],"sand_seal":["b2ad8d","sandprint",6,3.0],"twin_moon":["b0c1b1","twin_hook",5,2.0],
 "lance":["a1d0d6","pierce",3,2.0],"wave_sword":["80b5bf","foam",6,2.0],"frost_sword":["d0e2df","frost",5,3.0],"thunder":["b1a5c5","spark",4,2.0],"stars":["d4c295","sword_ash",7,2.0],
 "disc":["d2b568","ring_spark",4,2.0],"lotus_lantern":["d5ac99","petals",5,4.0],"gate_shield":["a7b1a1","shield_dust",6,4.0],"tether":["b5a179","rope_fibre",5,2.0],"tide_bow":["98c4cd","arrow_mist",4,2.0]}
static func shard(canvas: CanvasItem,p: Vector2,size: float,angle: float,color: Color) -> void:
 if size<.2 or color.a<.01:return
 var axis=Vector2.RIGHT.rotated(angle)
 var points=PackedVector2Array([p+axis*size,p+axis.orthogonal()*size*.4,p-axis*size*.8,p-axis.orthogonal()*size*.3])
 canvas.draw_primitive(points,PackedColorArray([color]),PackedVector2Array())
 canvas.draw_primitive(PackedVector2Array([p+axis*size,p+axis.orthogonal()*size*.4,p-axis*size*.3]),PackedColorArray([color.lightened(.22)]),PackedVector2Array())
static func flame_surface(p: Vector2,height: float,phase: float,color: Color,layer: int) -> Dictionary:
 var h: float=height*[1.08,1.0,.56][layer];var w: float=height*[.28,.19,.11][layer]
 var tint: Color=Color(color,color.a*.18) if layer==0 else color if layer==1 else Color("f4d6a0",color.a*.85)
 var outline=PackedVector2Array();var colors=PackedColorArray()
 # Vertical-monotone sides cannot cross. Include the zero-width tip only once.
 for index in 17:
  var u: float=index/8.0 if index<=8 else (16-index)/8.0
  var side: float=-1 if index<=8 else 1
  var spread: float=w*pow(1-u,.7)*(.78+.22*sin(phase*4+u*8))
  var bend: float=sin(phase*5.7+u*4)*w*u*.7
  outline.append(p+Vector2(bend+side*spread,-h*u))
  colors.append(Color(tint.lerp(Color("d06437",tint.a*.3),u),tint.a*(1-u*.65)))
 return {"outline":outline,"colors":colors}
static func flame_mesh(phase: float,color: Color,layer: int) -> ArrayMesh:
 var sample: int=roundi(phase*40)
 var key: String=str(sample)+":"+str(layer)+":"+color.to_html(false)
 if not flame_meshes.has(key):
  var opaque: Color=Color(color,1)
  var surface: Dictionary=flame_surface(Vector2.ZERO,1,sample/40.0,opaque,layer)
  var vertices=PackedVector3Array()
  for point in surface.outline:vertices.append(Vector3(point.x,point.y,0))
  var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX)
  arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_COLOR]=surface.colors
  arrays[Mesh.ARRAY_INDEX]=Geometry2D.triangulate_polygon(surface.outline)
  var mesh=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
  if flame_meshes.size()>=2048:flame_meshes.erase(flame_meshes.keys()[0])
  flame_meshes[key]=mesh
 return flame_meshes[key]
static func flame(canvas: CanvasItem,p: Vector2,height: float,phase: float,color: Color) -> void:
 if height<1:return
 # Three curved gradient surfaces, rather than 24 separate quad commands per flame.
 for layer in 3:
  canvas.draw_mesh(flame_mesh(phase,color,layer),null,Transform2D(0,Vector2(height,height),0,p),Color(1,1,1,color.a))
static func ribbon_geometry(points: PackedVector2Array,width: float,color: Color) -> Dictionary:
 var vertices=PackedVector2Array();var colors=PackedColorArray();var indices=PackedInt32Array()
 # Same independent convex strips, in the same blend order, batched in one draw command.
 for i in points.size()-1:
  var delta: Vector2=points[i+1]-points[i]
  if delta.length_squared()<.04:continue
  var normal: Vector2=delta.normalized().orthogonal()
  var first: float=maxf(.1,sin((i+.5)/points.size()*PI)*width*(.7+.3*sin(i*2.7)))
  var second: float=maxf(.1,sin((i+1.5)/points.size()*PI)*width*(.7+.3*sin((i+1)*2.7)))
  for layer in [1.0,.3]:
   var quad=PackedVector2Array([points[i]+normal*first*layer,points[i+1]+normal*second*layer,points[i+1]-normal*second*layer,points[i]-normal*first*layer])
   var first_vertex: int=vertices.size();vertices.append_array(quad)
   for vertex in 4:colors.append(Color(color,color.a*(.23 if layer==1 else .55)))
   indices.append_array(PackedInt32Array([first_vertex,first_vertex+1,first_vertex+2,first_vertex,first_vertex+2,first_vertex+3]))
 return {"vertices":vertices,"colors":colors,"indices":indices}
static func ribbon(canvas: CanvasItem,points: PackedVector2Array,width: float,color: Color) -> void:
 if points.size()<2 or color.a<.01 or width<.05:return
 var tapers: Array=ribbon_taper(points.size())
 var outer_colors=PackedColorArray([Color(color,color.a*.23)])
 var inner_colors=PackedColorArray([Color(color,color.a*.55)])
 var uv=PackedVector2Array()
 for i in points.size()-1:
  var delta: Vector2=points[i+1]-points[i]
  if delta.length_squared()<.04:continue
  var normal: Vector2=delta.normalized().orthogonal()
  var factors: Array=tapers[i]
  var first: float=maxf(.1,factors[0]*width*factors[1])
  var second: float=maxf(.1,factors[2]*width*factors[3])
  for layer in [1.0,.3]:
   var quad=PackedVector2Array([points[i]+normal*first*layer,points[i+1]+normal*second*layer,points[i+1]-normal*second*layer,points[i]-normal*first*layer])
   canvas.draw_primitive(quad,outer_colors if layer==1 else inner_colors,uv)
static func grains(canvas: CanvasItem,p: Vector2,d: Vector2,r: float,t: float,material: Array,alpha: float) -> void:
 var count: int=material[2];var color=Color(material[0],alpha*(1-t))
 for i in count:
  var seed: float=i*2.399+float(material[1].hash()%31)*.1
  var axis: Vector2=d.rotated(sin(seed)*.9)
  var at: Vector2=p+axis*r*(.12+t*.45)+Vector2(0,18*t*t)
  shard(canvas,at,float(material[3])*(1-t*.5),seed+t,color)
static func action_trail(canvas: CanvasItem,a: Dictionary,origin: Vector2,reduced: bool=false) -> void:
 if a.is_empty() or a.get("shape","seal")=="seal" or a.elapsed<a.windup or a.elapsed>a.windup+a.active:return
 var style: String=a.get("weapon_style","")
 if not MATERIALS.has(style):return
 var progress: float=clampf((a.elapsed-a.windup)/maxf(.01,a.active),0,1)
 var points=PackedVector2Array()
 for i in 7:points.append(Geometry.sample(a,origin-Vector2(0,36),maxf(0,progress-.2+i*.2/6)).tip)
 var color=Color(MATERIALS[style][0],.5 if reduced else .9)
 ribbon(canvas,points,5 if a.heavy else 2.8,color)
 if style=="rake":
  for tooth in [-2,-1,1,2]:
   var furrow=PackedVector2Array()
   for point in points:furrow.append(point+a.direction.orthogonal()*tooth*4)
   ribbon(canvas,furrow,1,Color(color,.28))
 elif style=="dual":
  var second=PackedVector2Array()
  for i in 7:second.append(Geometry.sample(a,origin-Vector2(0,36),maxf(0,progress-.2+i*.2/6)).tip.rotated(0))
  for i in second.size():second[i]=origin-Vector2(0,36)+(second[i]-origin+Vector2(0,36)).rotated(-.32)*.74
  ribbon(canvas,second,1.8,Color(color,.45))
 elif style in ["lance","gate_shield"]:
  var parallel=PackedVector2Array()
  for point in points:parallel.append(point+a.direction.orthogonal()*5)
  ribbon(canvas,parallel,1,Color(color,.35))
 var tip: Vector2=Geometry.sample(a,origin-Vector2(0,36),progress).tip
 grains(canvas,tip-a.direction*8,a.direction,22,progress,MATERIALS[style],.7)
static func effect(canvas: CanvasItem,v: Dictionary,reduced: bool=false) -> void:
 var style: String=v.weapon_style
 if not MATERIALS.has(style):return
 if v.get("shape","") in ["arc","thrust","spin"]:return # Continuous active-phase trajectory handles these.
 var m: Array=MATERIALS[style];var p: Vector2=v.pos;var d: Vector2=v.dir;var r: float=minf(v.radius,160)
 var t: float=clampf(1-v.life/v.max,0,1);var alpha: float=.4 if reduced else .75
 var color=Color(m[0],alpha*(1-t))
 match m[1]:
  "pillar":
   Art.stamp(canvas,Art.weapon(v.get("weapon_id","wukong_w1")),p-Vector2(0,30*(1-t)),Vector2(18,70),PI/2,alpha*(1-t))
  "echo":Art.stamp(canvas,Art.weapon(v.get("weapon_id","wukong_w4")),p-Vector2(0,24),Vector2(72,22),d.angle(),alpha*(1-t)*.5)
  "paper":
   for i in 3:Art.stamp(canvas,Art.relic("relic_8"),p+Vector2((i-1)*17,-12-t*15),Vector2(12,18),sin(i+t)*.6,alpha*(1-t))
  "stamp","petals":
   Art.stamp(canvas,Art.relic("relic_19" if m[1]=="petals" else "relic_13"),p,Vector2(38,38),d.angle()*.15,alpha*(1-t)*.6)
  "earth","shield_dust":
   for i in 4:shard(canvas,p+d*(i-1)*12+Vector2(0,-sin(t*PI)*14),8*(1-t),i,Color(m[0],alpha*(1-t)))
  "teeth":
   for i in 9:
    var at: Vector2=p+d.orthogonal()*(i-4)*6
    ribbon(canvas,PackedVector2Array([at-d*8,at+d*15,at+d*24]),1.5,color)
  "ice","frost","shards":
   for i in 4:shard(canvas,p+Vector2.RIGHT.rotated(i*1.7)*r*.35,5+sin(t*PI)*6,i,color)
  "pressure","chime","sandprint":
   var points=PackedVector2Array()
   for i in 16:
    var angle: float=i*TAU/15
    points.append(p+Vector2(cos(angle),sin(angle)*.45)*r*(.35+t*.55)*(1+.035*sin(i*3)))
   ribbon(canvas,points,2,color)
  "spark":
   var points=PackedVector2Array()
   for i in 7:points.append(p+d*i*r/6+d.orthogonal()*sin(i*4+t)*6)
   ribbon(canvas,points,1.8,color)
  "rope_fibre","chain","twin_hook":
   var points=PackedVector2Array()
   for i in 10:points.append(p+d*i*r/10+d.orthogonal()*sin(i*.7+t*2)*9)
   ribbon(canvas,points,1.5,color)
  "foam","arrow_mist","pierce","crescent","return_blade","cross":
   var points=PackedVector2Array()
   for i in 8:points.append(p+d*i*r/8+d.orthogonal()*sin(i*.4)*12)
   ribbon(canvas,points,2.5,color)
  "beads","ring_spark","sword_ash":
   Art.stamp(canvas,Art.weapon(v.get("weapon_id","wukong_w5")),p-Vector2(0,18),Vector2(25,22),d.angle()+t*2,alpha*(1-t))
  "embers":
   for i in 5:shard(canvas,p+Vector2(sin(i*3)*r*.25,-t*32+i*3),3*(1-t),i,Color("dd8246",alpha*(1-t)))
 grains(canvas,p,d,r*.6,t,m,alpha)
static func projectile(canvas: CanvasItem,b: Dictionary) -> bool:
 var style: String=b.get("weapon_style","")
 if not MATERIALS.has(style):return false
 var m: Array=MATERIALS[style];var p: Vector2=b.pos;var d: Vector2=b.dir
 var points=PackedVector2Array([p-d*24,p-d*12+d.orthogonal()*sin(b.get("age",0)*12)*2,p])
 ribbon(canvas,points,1.8,Color(m[0],.6))
 if style in ["rosary","scripture"]:
  Art.stamp(canvas,Art.weapon(b.get("weapon_id","tangseng_w2" if style=="rosary" else "tangseng_w3")),p,Vector2(16,14),d.angle()+b.get("age",0)*4,.9)
 elif style in ["disc","hook","meteor","crescent","stars","twin_moon","wave_sword","tether"]:
  var ids: Dictionary={"disc":"wukong_w5","hook":"bajie_w1","meteor":"bajie_w4","crescent":"shaseng_w1","stars":"bailongma_w4","twin_moon":"shaseng_w4","wave_sword":"bailongma_w1","tether":"shaseng_w5"}
  Art.stamp(canvas,Art.weapon(b.get("weapon_id",ids.get(style,"wukong_w0"))),p,Vector2(32,18),d.angle()+b.get("age",0)*3,.9)
 else:shard(canvas,p,7,d.angle(),Color(m[0]))
 return true
