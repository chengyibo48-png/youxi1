extends RefCounted
const Art=preload("res://scripts/painterly_assets.gd")
const TERRAIN={"forest":0,"wild":0,"web":0,"night":0,"temple":1,"river":2,"desert":3,"ember":4,"moon":5,"snow":5,"city":6,"cave":7,"grave":7}
const COMPLETE_FLOORS={"forest":"forest-v6","wild":"forest-v6","web":"forest-v6","night":"forest-v6","temple":"temple-v6","river":"river-v6","ember":"ember-v7","desert":"desert-v8","snow":"snow-v8","moon":"snow-v8","city":"city-v8","cave":"cave-v8","grave":"cave-v8"}
static var complete_floor_textures: Dictionary={}
const CHAPTER_FLOORS={0:"chapter-00-floor-v9",3:"chapter-03-floor-v11",5:"chapter-05-floor-v11",7:"chapter-07-floor-v11",12:"chapter-12-floor-v9",15:"chapter-15-floor-v9"}
const CHAPTER_FLOOR_BIOMES={0:["wild","forest"],3:["forest"],5:["desert"],7:["desert","temple"],12:["ember"],15:["snow"]}
static var chapter_floor_textures: Dictionary={}
static func chapter_floor(chapter: int,biome: String) -> Texture2D:
 if not CHAPTER_FLOORS.has(chapter) or biome not in CHAPTER_FLOOR_BIOMES[chapter]:return complete_floor(biome)
 if not chapter_floor_textures.has(chapter):chapter_floor_textures[chapter]=load("res://assets/painterly/"+CHAPTER_FLOORS[chapter]+".png")
 return chapter_floor_textures[chapter]
static func complete_floor(biome: String) -> Texture2D:
 if not COMPLETE_FLOORS.has(biome):return null
 var key: String=COMPLETE_FLOORS[biome]
 if not complete_floor_textures.has(key):
  var parts: PackedStringArray=key.split("-")
  complete_floor_textures[key]=load("res://assets/painterly/"+parts[0]+"-floor-"+parts[1]+".png")
 return complete_floor_textures[key]
static func texture(biome: String) -> Texture2D:
 var index: int=TERRAIN.get(biome,0)
 return Art.tile("terrain-v2",index%4,index/4,4,2)
static func floor_art(canvas: CanvasItem,bounds: Rect2,ground: Texture2D,biome: String,chapter: int=0) -> void:
 var tint=Color(.8,.85,.88) if biome in ["night","grave","cave"] else Color.WHITE
 tint*=preload("res://scripts/chapter_lighting.gd").grade(chapter,biome)
 var earth: Color=Color("555a4b")
 if biome=="river":earth=Color("92958a")
 elif biome=="desert":earth=Color("9b8059")
 elif biome in ["snow","moon"]:earth=Color("858b8c")
 elif biome in ["cave","grave","ember"]:earth=Color("454844")
 canvas.draw_rect(bounds.grow(100),earth)
 var painted_ground: Texture2D=chapter_floor(chapter,biome)
 if painted_ground!=null:
  canvas.draw_texture_rect(painted_ground,bounds,false,tint)
 elif ground!=null:
  for row in ceili(bounds.size.y/384.0):
   for col in ceili(bounds.size.x/288.0):
    var origin: Vector2=bounds.position+Vector2(col*288,row*384)
    var extent: Vector2=Vector2(minf(288,bounds.end.x-origin.x),minf(384,bounds.end.y-origin.y))
    # Alternate UV orientation rather than copying the same diagonal every tile.
    var corners=PackedVector2Array([Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN])
    var uv=PackedVector2Array()
    var vertices=PackedVector2Array()
    var shift: int=0
    var region: Rect2=ground.region if ground is AtlasTexture else Rect2(Vector2.ZERO,ground.get_size())
    var source: Texture2D=ground.atlas if ground is AtlasTexture else ground
    for i in 4:
     vertices.append(origin+corners[i]*extent)
     var point: Vector2=corners[(i+shift)%4]
     if (row+col)%2==1:point.x=1-point.x
     if (col+chapter)%3==1:point.y=1-point.y
     uv.append((region.position+point*region.size)/source.get_size())
    var surface: Color=tint;surface.a=.56
    canvas.draw_polygon(vertices,PackedColorArray([surface]),uv,source)
 # A subtle broad worn road follows the actually clear collision corridor.
 var upper=PackedVector2Array();var lower=PackedVector2Array()
 for i in 33:
  var x: float=bounds.position.x+i*bounds.size.x/32
  var deviation: float=sin(i*.44+chapter*.4)*16+sin(i*1.7)*4
  upper.append(Vector2(x,bounds.get_center().y-95+deviation))
  lower.append(Vector2(x,bounds.get_center().y+95+deviation))
 lower.reverse();upper.append_array(lower)
 canvas.draw_colored_polygon(upper,Color(.68,.60,.43,.085 if biome!="desert" else .06))
 for i in (0 if CHAPTER_FLOORS.has(chapter) and biome in CHAPTER_FLOOR_BIOMES[chapter] else 16):
  var x: float=bounds.position.x+(i+.5)*bounds.size.x/16
  var y: float=bounds.get_center().y+sin((i+chapter%7)*.65)*10
  var footprint=PackedVector2Array([Vector2(x-17,y-8),Vector2(x+17,y-6),Vector2(x+20,y+8),Vector2(x-20,y+6)])
  canvas.draw_colored_polygon(footprint,Color(.56,.48,.34,.10 if biome!="desert" else .18))
 var composition: Dictionary=preload("res://scripts/chapter_scenery.gd").composition(chapter)
 if not composition.is_empty():
  for route in composition.paths:
   var points=PackedVector2Array()
   for point in route:points.append(bounds.position+Vector2(point[0],point[1])*bounds.size/Vector2(2400,1400))
   canvas.draw_polyline(points,Color(.64,.57,.43,.05),94,true)
   canvas.draw_polyline(points,Color(.72,.65,.51,.055),66,true)
  ground_details(canvas,bounds,composition,biome,chapter)
 preload("res://scripts/chapter_lighting.gd").draw_edges(canvas,bounds,chapter,biome)
static func ground_details(canvas: CanvasItem,bounds: Rect2,composition: Dictionary,biome: String,chapter: int) -> void:
 # Small non-colliding contact details follow authored props, leaving fighting lanes clear.
 var scale: Vector2=bounds.size/Vector2(2400,1400)
 for index in composition.props.size():
  var prop: Array=composition.props[index]
  var anchor: Vector2=bounds.position+Vector2(prop[0],prop[1])*scale
  for chip in 5:
   var phase: float=(chapter*.31+index*.73+chip*1.43)
   var point: Vector2=anchor+Vector2(cos(phase)*63,sin(phase)*29+22)
   var color: Color=Color(.26,.31,.22,.24) if biome in ["forest","wild","web"] else Color(.35,.28,.21,.20)
   if biome in ["snow","moon"]:color=Color(.78,.84,.82,.24)
   var width: float=7+chip%3*3
   canvas.draw_colored_polygon(PackedVector2Array([point+Vector2(-width,-2),point+Vector2(3,-5),point+Vector2(width,1),point+Vector2(-2,5)]),color)
  canvas.draw_colored_polygon(PackedVector2Array([anchor+Vector2(-74,0),anchor+Vector2(58,-2),anchor+Vector2(82,24),anchor+Vector2(-47,34)]),Color(0,0,0,.035))
 for landmark in composition.landmarks:
  var point: Vector2=bounds.position+Vector2(landmark[0],landmark[1])*scale
  # Local reflected light and a broad contact shadow establish the landmark's ground plane.
  for layer in 5:
   var radius: float=90-layer*14
   var polygon=PackedVector2Array()
   for vertex in 24:polygon.append(point+Vector2(cos(vertex*TAU/24)*radius,sin(vertex*TAU/24)*radius*.36))
   canvas.draw_colored_polygon(polygon,Color(.84,.74,.47,.008) if biome not in ["snow","river"] else Color(.66,.79,.83,.008))
static func gate(canvas: CanvasItem,point: Vector2,open: bool=true,entry: bool=false) -> void:
 # Upright posts frame an empty, passable opening; no collision sits in the doorway.
 var color: Color=Color.WHITE if open else Color(.55,.56,.52)
 canvas.draw_colored_polygon(PackedVector2Array([point+Vector2(-35,6),point+Vector2(35,6),point+Vector2(51,17),point+Vector2(-48,17)]),Color(0,0,0,.14))
 Art.stamp(canvas,preload("res://scripts/spirit_props.gd").texture(7),point-Vector2(0,60),Vector2(102,136),0,1,color)
 if not open and not entry:
  var ribbon=PackedVector2Array([point+Vector2(-27,-7),point+Vector2(28,-2),point+Vector2(28,5),point+Vector2(-27,0)])
  canvas.draw_colored_polygon(ribbon,Color("aa5140",.85))
static func room_extras(canvas: CanvasItem,kind: String,p: Vector2,biome: String,clock: float) -> void:
 var tint: Color=Color(.82,.86,.90) if biome in ["night","grave","cave"] else Color(.96,.94,.86) if biome=="desert" else Color.WHITE
 var items: Array=[]
 match kind:
  "shop":items=["relic_5","relic_0","relic_6"]
  "shrine":items=["relic_4","relic_1","relic_15"]
  "event":items=["relic_8","relic_13","relic_5"]
  "rest":items=["relic_16","relic_4","relic_6"]
  "reward":items=["relic_8","relic_17","relic_10"]
  "forge":items=["relic_20","relic_11","relic_14"]
  "curse":items=["relic_21","relic_12","relic_13"]
 for i in items.size():
  var at: Vector2=p+Vector2((i-1)*42,-43)
  Art.stamp(canvas,Art.relic(items[i]),at,Vector2(24,28),0,.75,tint)
 if kind=="forge":
  for i in 4:
   var phase: float=fmod(clock*.7+i*.21,1)
   preload("res://scripts/weapon_effects.gd").shard(canvas,p+Vector2(sin(i*2.4)*18,-78-phase*25),2.0,-PI/2,Color("df9c58",1-phase))

