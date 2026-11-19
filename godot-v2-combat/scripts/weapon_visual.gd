extends RefCounted
const Arts=preload("res://scripts/weapon_arts.gd")
const PALETTE={"extend":"d7b965","pin":"b6d0bb","flame":"e47842","dual":"c9b073","phantom":"b3acc9","stamp":"cfb787","mandala":"d6ba68","rosary":"ba7758","scripture":"d9d0af","bell":"bc995c","rake":"aeb9a8","hook":"bcc6b9","furrow":"a88c65","ice_hammer":"a1d3d7","meteor":"a19d8d","crescent_staff":"b4c9bd","crescent":"b6d6cf","shards":"c3ab78","sand_seal":"ae936e","twin_moon":"c7d4c1","lance":"92d4de","wave_sword":"89c9d8","frost_sword":"c3e5e5","thunder":"b8adf0","stars":"d4c680","disc":"e8bb5c","lotus_lantern":"e0c4a0","gate_shield":"aabbb0","tether":"c9b082","tide_bow":"8ed5df"}
static var dual_parts: Dictionary={}
static func dual_part(id: String,side: int) -> Texture2D:
 var key: String=id+str(side)
 if not dual_parts.has(key):
  var painted=preload("res://scripts/painterly_assets.gd").weapon(id)
  var item=AtlasTexture.new();item.atlas=painted.atlas;item.region=painted.region
  if id=="wukong_w3":item.region.size.y*=.5;item.region.position.y+=item.region.size.y*side
  else:item.region.size.x*=.5;item.region.position.x+=item.region.size.x*side
  dual_parts[key]=item
 return dual_parts[key]
static func dual_extent(id: String,texture: Texture2D) -> Vector2:
 var width: float=28 if id=="tangseng_w2" else 38 if id=="shaseng_w4" else 48
 var size: Vector2=texture.get_size();var scale: float=width/size.x
 if id!="wukong_w3":scale=minf(scale,42/size.y)
 return size*scale
static func crystal(canvas: CanvasItem,p: Vector2,r: float,color: Color) -> void:
 canvas.draw_colored_polygon(PackedVector2Array([p+Vector2(0,-r),p+Vector2(r*.5,0),p+Vector2(0,r*.8),p-Vector2(r*.5,0)]),color)

static func held(canvas: CanvasItem,id: String,hand: Vector2,angle: float,length: float,base: Transform2D,tint: Color,off_hand: Vector2=Vector2.ZERO,off_angle: float=NAN) -> void:
 if not Arts.KITS.has(id):return
 var style: String=Arts.KITS[id][1];var color: Color=Color(PALETTE[style])*tint
 var l: float=clampf(length,50,360);var transform: Transform2D=base*Transform2D(angle,hand)
 canvas.draw_set_transform_matrix(transform)
 var painted=preload("res://scripts/painterly_assets.gd").weapon(id)
 if painted!=null:
  var grip: Array=preload("res://scripts/weapon_grips.gd").get_grip(id)
  var width: float=l+12
  if grip[3] in ["throw","scroll","beads","lantern","focus"]:width=48
  elif grip[3]=="shield":width=54
  elif grip[3]=="bow":width=62
  var height: float=width*painted.get_height()/painted.get_width()
  # Keep head, blade and tassel proportions instead of flattening the bitmap.
  var extent: Vector2=Vector2(width,height)
  var flipped: bool=id in ["tangseng_w0","tangseng_w4","bajie_w0","bajie_w1","bajie_w2","bajie_w3","bajie_w4","shaseng_w0","shaseng_w1","shaseng_w3"]
  var offset: float=-extent.x*float(grip[0])
  # Canvas draw_texture_rect does not anchor negative-width rectangles at the
  # handle reliably. Mirror the local transform and keep an ordinary positive rect.
  var rect: Rect2=Rect2(Vector2(-extent.x*(1-float(grip[0])) if flipped else offset,-extent.y*.5),extent)
  if flipped:canvas.draw_set_transform_matrix(transform*Transform2D(0,Vector2(-1,1),0,Vector2.ZERO))
  if grip[3]=="lantern":rect.position.y=-extent.y*.16
  if id in ["wukong_w3","tangseng_w2","shaseng_w4"] and off_hand!=Vector2.ZERO:
   for side in 2:
    var item: Texture2D=dual_part(id,side);var size: Vector2=dual_extent(id,item)
    canvas.draw_set_transform_matrix(base*Transform2D(angle if side==0 else angle+.4 if is_nan(off_angle) else off_angle,hand if side==0 else off_hand))
    canvas.draw_texture_rect(item,Rect2(Vector2(-size.x*float(grip[0]),-size.y*.5),size),false,tint)
   canvas.draw_set_transform_matrix(base);return
  canvas.draw_texture_rect(painted,rect,false,tint)
  if grip[3]=="bow" and off_hand!=Vector2.ZERO:
   var pull: Vector2=(off_hand-hand).rotated(-angle)
   var string=PackedVector2Array([Vector2(-extent.x*.18,-extent.y*.35),pull,Vector2(-extent.x*.18,extent.y*.35)])
   canvas.draw_polyline(string,Color("cbd3c2")*tint,1,true)
  canvas.draw_set_transform_matrix(base);return
 canvas.draw_line(Vector2(-14,0),Vector2(l*.65,0),Color("413e34")*tint,5,true)
 match style:
  "extend":canvas.draw_line(Vector2(-20,0),Vector2(l,0),color,7,true);canvas.draw_line(Vector2(l-15,-5),Vector2(l-15,5),Color("f3d888")*tint,4,true)
  "pin":canvas.draw_colored_polygon(PackedVector2Array([Vector2(0,-4),Vector2(l-18,-7),Vector2(l,0),Vector2(l-18,7),Vector2(0,4)]),color)
  "flame":
   canvas.draw_line(Vector2(-12,0),Vector2(l*.8,0),color,5,true)
   for i in 3:crystal(canvas,Vector2(l*(.5+i*.12),-5),9,color)
  "dual":
   for y in [-9,9]:canvas.draw_line(Vector2(-14,y),Vector2(l*.6,y),color,5,true)
  "phantom":
   for y in [-8,0,8]:canvas.draw_line(Vector2(0,y),Vector2(l*.8,y),Color(color,.35 if y!=0 else .85),3,true)
  "stamp":canvas.draw_circle(Vector2(l*.6,0),13,color,false,3,true);canvas.draw_line(Vector2(l*.5,-12),Vector2(l*.5,12),color,3,true)
  "mandala":
   var center=Vector2(l*.55,0);canvas.draw_arc(center,20,0,TAU,24,color,3,true)
   for i in 6:canvas.draw_line(center,center+Vector2.RIGHT.rotated(i*TAU/6)*18,color,2,true)
  "rosary":
   for i in 12:canvas.draw_circle(Vector2(22,0)+Vector2.RIGHT.rotated(i*TAU/12)*24,4,color)
  "scripture":canvas.draw_rect(Rect2(15,-17,34,34),color);canvas.draw_line(Vector2(32,-15),Vector2(32,15),Color("655541"),2,true)
  "bell":canvas.draw_colored_polygon(PackedVector2Array([Vector2(25,-8),Vector2(48,-15),Vector2(48,15),Vector2(25,8)]),color);canvas.draw_arc(Vector2(48,0),15,-PI/2,PI/2,12,color,3,true)
  "rake":
   canvas.draw_line(Vector2(l*.7,-24),Vector2(l*.7,24),color,5,true)
   for i in 9:canvas.draw_line(Vector2(l*.7,-24+i*6),Vector2(l*.85,-24+i*6),color,2,true)
  "hook":canvas.draw_arc(Vector2(l*.65,0),25,-PI*.8,PI*.55,18,color,5,true)
  "furrow":canvas.draw_colored_polygon(PackedVector2Array([Vector2(l*.5,-22),Vector2(l*.85,0),Vector2(l*.5,22),Vector2(l*.6,0)]),color)
  "ice_hammer":canvas.draw_rect(Rect2(l*.6,-19,28,38),color);crystal(canvas,Vector2(l*.65,-21),13,Color("d8f1ec")*tint)
  "meteor":
   for i in 6:canvas.draw_circle(Vector2(i*9,0),4,color,false,2,true)
   canvas.draw_circle(Vector2(64,0),16,color)
   for i in 6:crystal(canvas,Vector2(64,0)+Vector2.RIGHT.rotated(i*TAU/6)*18,5,color)
  "crescent_staff":canvas.draw_arc(Vector2(l*.7,0),22,-PI*.7,PI*.7,18,color,5,true)
  "crescent":canvas.draw_arc(Vector2(l*.3,0),32,-PI*.8,PI*.8,20,color,5,true)
  "shards":
   for y in [-9,9]:canvas.draw_colored_polygon(PackedVector2Array([Vector2(0,y-3),Vector2(50,y),Vector2(0,y+3)]),color)
  "sand_seal":canvas.draw_rect(Rect2(13,-15,30,30),color,false,5);canvas.draw_rect(Rect2(22,-6,12,12),color,false,2)
  "twin_moon":
   for y in [-18,18]:canvas.draw_arc(Vector2(25,y),22,-PI*.7,PI*.7,16,color,4,true)
  "lance":canvas.draw_colored_polygon(PackedVector2Array([Vector2(l-32,-8),Vector2(l+10,0),Vector2(l-32,8),Vector2(l-20,0)]),color)
  "wave_sword":canvas.draw_colored_polygon(PackedVector2Array([Vector2(16,-5),Vector2(l*.75,-8),Vector2(l*.9,0),Vector2(l*.75,4),Vector2(16,5)]),color)
  "frost_sword":canvas.draw_colored_polygon(PackedVector2Array([Vector2(16,-6),Vector2(l*.8,-4),Vector2(l,0),Vector2(l*.8,6),Vector2(16,6)]),color);crystal(canvas,Vector2(13,0),12,color)
  "thunder":canvas.draw_polyline(PackedVector2Array([Vector2(12,0),Vector2(32,-8),Vector2(45,5),Vector2(61,-6),Vector2(78,0)]),color,6,true)
  "stars":
   canvas.draw_line(Vector2(12,0),Vector2(l*.8,0),color,4,true)
   for i in 7:canvas.draw_circle(Vector2(20+i*8,-2 if i%2==0 else 2),2,Color("f3e2ae")*tint)
  "disc":canvas.draw_arc(Vector2(30,0),24,0,TAU,24,color,6,true);canvas.draw_circle(Vector2(30,0),5,color)
  "lotus_lantern":
   canvas.draw_line(Vector2(10,0),Vector2(50,0),color,3,true)
   for i in 5:crystal(canvas,Vector2(50,0)+Vector2.RIGHT.rotated(i*TAU/5)*10,11,color)
  "gate_shield":canvas.draw_colored_polygon(PackedVector2Array([Vector2(10,-28),Vector2(45,-22),Vector2(50,20),Vector2(25,35),Vector2(6,20)]),color);canvas.draw_line(Vector2(26,-20),Vector2(26,25),Color("465b50")*tint,5,true)
  "tether":
   var points=PackedVector2Array()
   for i in 15:points.append(Vector2(i*4,sin(i*.7)*12))
   canvas.draw_polyline(points,color,3,true);crystal(canvas,Vector2(60,0),10,color)
  "tide_bow":canvas.draw_arc(Vector2(15,0),32,-PI/2,PI/2,24,color,5,true);canvas.draw_line(Vector2(15,-32),Vector2(15,32),color,1,true);canvas.draw_line(Vector2(0,0),Vector2(62,0),color,3,true)
 canvas.draw_set_transform_matrix(base)

static func bitmap_projectile(canvas: CanvasItem,b: Dictionary) -> bool:
 var style: String=b.get("weapon_style","");var type: String=b.get("visual","")
 if not PALETTE.has(style):return false
 var p: Vector2=b.pos;var d: Vector2=b.dir;var col=Color(PALETTE[style])
 var role: String="wukong"
 for id in Arts.KITS:
  if Arts.KITS[id][1]==style:role=id.split("_w")[0];break
 var bitmap=preload("res://scripts/painterly_assets.gd").tile("effects",1,preload("res://scripts/painterly_assets.gd").ROLES.find(role),6,5)
 var object=preload("res://scripts/painterly_assets.gd").weapon(b.get("weapon_id",role+"_w0"))
 preload("res://scripts/painterly_assets.gd").stamp(canvas,bitmap,p-d*12,Vector2(60,36),d.angle(),.75)
 if object!=null:preload("res://scripts/painterly_assets.gd").stamp(canvas,object,p,Vector2(42,34),d.angle()+(.8 if type in ["disc","hook","crescent"] else 0),1)
 return true

static func legacy_projectile(canvas: CanvasItem,b: Dictionary) -> bool:
 var type: String=b.get("visual","");var p: Vector2=b.pos;var d: Vector2=b.dir;var col=Color("d1c49c")
 match type:
  "ember":
   canvas.draw_colored_polygon(PackedVector2Array([p+d*16,p-d*18+d.orthogonal()*9,p-d*6,p-d*18-d.orthogonal()*9]),col)
  "page":
   canvas.draw_colored_polygon(PackedVector2Array([p+d*13,p+d.orthogonal()*8,p-d*12,p-d.orthogonal()*8]),col);canvas.draw_line(p-d*5,p+d*6,Color("7d6b4d"),2,true)
  "hook":canvas.draw_arc(p,14,d.angle()-PI*.8,d.angle()+PI*.6,16,col,4,true);canvas.draw_line(p,p-d*30,Color(col,.5),2,true)
  "meteor":canvas.draw_circle(p,16,col);canvas.draw_arc(p,20,0,TAU,16,Color(col,.4),2,true)
  "water_wave":canvas.draw_arc(p,24,d.angle()-PI*.6,d.angle()+PI*.6,20,col,5,true)
  "ice_shard":canvas.draw_colored_polygon(PackedVector2Array([p+d*16,p-d*8+d.orthogonal()*6,p-d*13,p-d*8-d.orthogonal()*6]),col)
  "star_sword":
   canvas.draw_line(p-d*16,p+d*13,col,3,true);canvas.draw_line(p-d.orthogonal()*8,p+d.orthogonal()*8,Color("e8ddb3"),2,true)
  "lightning":canvas.draw_polyline(PackedVector2Array([p-d*28,p-d*17+d.orthogonal()*6,p-d*10-d.orthogonal()*6,p+d*6]),col,3,true)
  "disc":canvas.draw_arc(p,13,0,TAU,24,col,4,true);canvas.draw_line(p-d*8,p+d*8,col,2,true)
  "tether":canvas.draw_line(p-d*40,p,col,3,true);canvas.draw_arc(p,10,d.angle()-2,d.angle()+2,14,col,3,true)
  "water_arrow":canvas.draw_line(p-d*22,p+d*17,col,3,true);canvas.draw_polyline(PackedVector2Array([p+d*6-d.orthogonal()*7,p+d*17,p+d*6+d.orthogonal()*7]),col,3,true)
  _:return false
 return true

static func legacy_effect(canvas: CanvasItem,v: Dictionary,reduced: bool=false) -> void:
 var style: String=v.weapon_style;var t: float=clampf(1-v.life/v.max,0,1);var p: Vector2=v.pos;var d: Vector2=v.dir;var r: float=v.radius
 var col=Color(PALETTE[style],(1-t)*(.5 if reduced else .85));var side: Vector2=d.orthogonal()
 match style:
  "extend":
   if v.get("shape","thrust")=="arc":
    var direction: float=-1 if v.combo==2 else 1
    canvas.draw_arc(p,r*.85,d.angle()+direction*(-1.15),d.angle()+direction*(-1.15+2.3*t),32,col,5,true)
   else:canvas.draw_line(p-d*15,p+d*r,Color(col,.12),20,true);canvas.draw_line(p,p+d*r,col,5,true);canvas.draw_line(p+d*r-side*12,p+d*r+side*12,col,3,true)
  "pin":
   for i in 3:canvas.draw_line(p+side*(i-1)*10-Vector2(0,70*(1-t)),p+side*(i-1)*10,col,4,true)
   canvas.draw_rect(Rect2(p-Vector2(14,4),Vector2(28,8)),col,false,2)
  "flame":
   var points=PackedVector2Array()
   for i in 12:points.append(p+d*i*r/12+side*sin(i*.9-t*8)*18)
   canvas.draw_polyline(points,Color(col,.15),25,true);canvas.draw_polyline(points,col,5,true)
   for i in 5:crystal(canvas,p+d*i*r/6+side*sin(i+t*7)*25,6,col)
  "dual":
   for axis in ([-.6,.6] if v.heavy or v.combo==3 else [-.6] if v.combo==1 else [.6]):canvas.draw_line(p-d.rotated(axis)*r*.4,p+d.rotated(axis)*r,col,4,true)
  "phantom":
   for i in 3:canvas.draw_line(p+side*(i-1)*15-d*30,p+side*(i-1)*15+d*r*.65,Color(col,(1-t)*(.65-i*.15)),4,true)
  "stamp":
   canvas.draw_rect(Rect2(p-Vector2.ONE*r*.35,Vector2.ONE*r*.7),col,false,3)
   for i in [-1,1]:canvas.draw_line(p+Vector2(i*r*.13,-r*.25),p+Vector2(i*r*.13,r*.25),col,3,true)
  "mandala":
   canvas.draw_arc(p,r*.45,0,TAU,32,col,3,true)
   for i in 8:canvas.draw_arc(p+Vector2.RIGHT.rotated(i*TAU/8+t)*r*.25,r*.16,0,TAU,16,col,2,true)
   canvas.draw_line(p-d*r,p+d*r,Color(col,.55),4,true)
  "rosary":
   for i in 16:canvas.draw_circle(p+Vector2.RIGHT.rotated(i*TAU/16+t*4)*r*(.3+t*.25),4,col)
  "scripture":
   for i in 5:
    var point=p+d.rotated((i-2)*.3)*r*(.3+t*.4);canvas.draw_rect(Rect2(point-Vector2(7,11),Vector2(14,22)),col,false,2)
    canvas.draw_line(point-Vector2(3,7),point+Vector2(3,7),col,1,true)
  "bell":
   for i in 3:canvas.draw_arc(p,r*(.25+t*.6+i*.08),0,TAU,40,Color(col,(1-t)*(.65-i*.16)),3-i*.5,true)
  "rake":
   if not v.heavy and v.combo==3:
    for i in 9:canvas.draw_line(p+Vector2.RIGHT.rotated(i*TAU/9)*r*.3,p+Vector2.RIGHT.rotated(i*TAU/9)*r*(.5+t*.4),col,3,true)
   elif not v.heavy and v.combo==2:
    for i in 9:canvas.draw_arc(p,r*.6+i*4,d.angle()-1.2,d.angle()+.7,24,col,2,true)
   else:
    for i in 9:canvas.draw_line(p+side*(i-4)*7,p+d*r+side*(i-4)*7,col,2,true)
  "hook":canvas.draw_arc(p+d*r*.65,r*.22,d.angle()-2,d.angle()+1.3,24,col,4,true);canvas.draw_line(p,p+d*r*.65,col,2,true)
  "furrow":
   for i in 5:canvas.draw_polyline(PackedVector2Array([p+d*i*r/6-side*13,p+d*(i+.5)*r/6,p+d*(i+1)*r/6+side*13]),col,4,true)
  "ice_hammer":
   for i in 3:crystal(canvas,p+side*(i-1)*22-Vector2(0,t*25),25*(1-t*.3),col)
  "meteor":canvas.draw_arc(p,r*.75,-t*TAU,-t*TAU+PI*.7,24,col,5,true);canvas.draw_circle(p+Vector2.RIGHT.rotated(-t*TAU)*r*.75,13,col)
  "crescent_staff":canvas.draw_arc(p,r*.75,d.angle()-1,d.angle()+1,24,col,5,true);canvas.draw_line(p,p+d*r,col,2,true)
  "crescent":canvas.draw_arc(p+d*r*.4,r*.35,d.angle()-2,d.angle()+2,28,col,5,true)
  "shards":
   for i in 5:crystal(canvas,p+d.rotated((i-2)*.23)*r*(.3+t*.5),9,col)
  "sand_seal":
   canvas.draw_rect(Rect2(p-Vector2.ONE*r*.5,Vector2.ONE*r),col,false,3)
   for i in [-1,0,1]:canvas.draw_line(p+Vector2(i*r*.3,-r*.5),p+Vector2(i*r*.3,r*.5),Color(col,.45),2,true)
  "twin_moon":
   for axis in [-1,1]:canvas.draw_arc(p+side*axis*r*.25,r*.4,d.angle()-2,d.angle()+2,24,col,4,true)
  "lance":canvas.draw_polyline(PackedVector2Array([p-d*r*.2,p+d*r,p+d*r-d*20+side*10,p+d*r,p+d*r-d*20-side*10]),col,4,true)
  "wave_sword":
   for j in 3:
    var points=PackedVector2Array()
    for i in 16:points.append(p+d*i*r/16+side*(sin(i*.5-t*7)*9+j*10))
    canvas.draw_polyline(points,Color(col,(1-t)*(.8-j*.2)),3,true)
  "frost_sword":
   for i in 5:canvas.draw_line(p,p+d.rotated((i-2)*.3)*r,col,2,true);crystal(canvas,p+d.rotated((i-2)*.3)*r,8,col)
  "thunder":
   var points=PackedVector2Array()
   for i in 10:points.append(p+d*i*r/10+side*(0 if i%3==0 else 12 if i%2==0 else -12))
   canvas.draw_polyline(points,Color(col,.15),12,true);canvas.draw_polyline(points,col,3,true)
  "stars":
   var points=PackedVector2Array()
   for i in 7:
    var point=p+Vector2.RIGHT.rotated(i*TAU/7+t)*r*.4;points.append(point);canvas.draw_circle(point,4,col)
   canvas.draw_polyline(points,col,2,true)
  "disc":
   for i in 3:canvas.draw_arc(p+d*r*.4+side*(i-1)*24,r*.2,0,TAU,24,col,3,true)
  "lotus_lantern":
   for i in 8:crystal(canvas,p+Vector2.RIGHT.rotated(i*TAU/8)*r*.45,r*.2,col)
   canvas.draw_circle(p,r*.1,col)
  "gate_shield":
   canvas.draw_colored_polygon(PackedVector2Array([p+d*20-side*r*.4,p+d*50-side*r*.3,p+d*70,p+d*50+side*r*.3,p+d*20+side*r*.4]),Color(col,.2))
   canvas.draw_line(p+d*45-side*r*.4,p+d*45+side*r*.4,col,6,true)
  "tether":
   var points=PackedVector2Array()
   for i in 20:points.append(p+d*i*r/20+side*sin(i*.7-t*10)*10)
   canvas.draw_polyline(points,col,3,true);canvas.draw_arc(p+d*r,r*.12,0,TAU,20,col,3,true)
  "tide_bow":
   canvas.draw_arc(p,r*.25,d.angle()-PI/2,d.angle()+PI/2,24,col,3,true)
   for i in 5:
    var axis=d.rotated((i-2)*.15);var end=p+axis*r*(.3+t*.6)
    canvas.draw_line(end-axis*22,end,col,3,true);canvas.draw_line(end-axis*10-axis.orthogonal()*5,end,col,2,true)

static func bitmap_effect(canvas: CanvasItem,v: Dictionary,reduced: bool=false) -> void:
 var style: String=v.weapon_style;var role: String="wukong";var id: String="wukong_w0"
 for key in Arts.KITS:
  if Arts.KITS[key][1]==style:role=key.split("_w")[0];id=key;break
 var t: float=clampf(1-v.life/v.max,0,1);var r: float=v.radius;var d: Vector2=v.dir;var p: Vector2=v.pos
 var alpha: float=.48 if reduced else .82
 var art=preload("res://scripts/painterly_assets.gd")
 var stage: int=int(v.get("combo",1))
 if style in ["disc","rosary","twin_moon","stars","meteor"]:
  for i in (3 if stage==3 else 2):
   var axis: Vector2=d.rotated((i-.5)*.65+t*.3)
   art.stamp(canvas,art.weapon(id),p+axis*r*.55,Vector2(55,44),axis.angle()+t*TAU,alpha)
   art.burst(canvas,role,p+axis*r*.3,axis,r*.42,t,alpha*.6,1)
 elif style in ["pin","flame","furrow","ice_hammer","sand_seal","lotus_lantern"]:
  for i in (3 if stage==3 else 1):art.burst(canvas,role,p+d*r*(.2+i*.24),d,r*.62,clampf(t-i*.07,0,1),alpha,2)
 elif style in ["dual","shards"]:
  for sign in [-1,1]:art.burst(canvas,role,p+d.orthogonal()*sign*12,d.rotated(sign*.28),r*.8,t,alpha,1)
 else:art.burst(canvas,role,p,d.rotated(-.25 if stage==2 else .16 if stage==3 else 0),r,t,alpha,1 if v.get("shape","")=="thrust" else 0)
static func effect(canvas: CanvasItem,v: Dictionary,reduced: bool=false) -> void:
 preload("res://scripts/weapon_effects.gd").effect(canvas,v,reduced)
static func projectile(canvas: CanvasItem,b: Dictionary) -> bool:
 return preload("res://scripts/weapon_effects.gd").projectile(canvas,b)
