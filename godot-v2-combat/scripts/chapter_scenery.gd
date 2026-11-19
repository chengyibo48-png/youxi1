extends RefCounted
const Art=preload("res://scripts/painterly_assets.gd")
static var chapters: Array=[]
static var compositions: Array=[]
static var contact_shadow: GradientTexture2D
static func shadow_texture() -> GradientTexture2D:
 if contact_shadow==null:
  var gradient=Gradient.new()
  gradient.offsets=PackedFloat32Array([0.0,.35,.7,1.0])
  gradient.colors=PackedColorArray([Color(0,0,0,.19),Color(0,0,0,.12),Color(0,0,0,.04),Color(0,0,0,0)])
  contact_shadow=GradientTexture2D.new();contact_shadow.gradient=gradient
  contact_shadow.width=128;contact_shadow.height=64
  contact_shadow.fill=GradientTexture2D.FILL_RADIAL
  contact_shadow.fill_from=Vector2(.5,.5);contact_shadow.fill_to=Vector2(1,.5)
 return contact_shadow
static func composition(chapter: int) -> Dictionary:
 if compositions.is_empty():compositions=JSON.parse_string(FileAccess.get_file_as_string("res://data/chapter_compositions.json"))
 for item in compositions:
  if int(item.chapter)==chapter:return item
 return {}
static func apply_composition(c,chapter: int) -> bool:
 var plan: Dictionary=composition(chapter)
 if plan.is_empty():return false
 var scale: Vector2=c.arena_size/Vector2(2400,1400)
 for p in plan.props:
  c.obstacles.append({"pos":c.arena_origin+Vector2(p[0],p[1])*scale,"radius":float(p[3])*minf(scale.x,scale.y),"kind":"rock","art_index":int(p[2]),"art_scale":1.0,"chapter_identity":chapter})
 for p in plan.landmarks:
  c.obstacles.append({"pos":c.arena_origin+Vector2(p[0],p[1])*scale,"radius":float(p[3])*minf(scale.x,scale.y),"kind":"rock","art_index":int(plan.props[0][2]),"landmark_index":int(p[2]),"display_width":float(p[4]),"art_scale":1.0,"chapter_identity":chapter})
 c.layout_name=plan.place
 return true
static func brief(chapter: int,biome: String) -> Dictionary:
 if chapters.is_empty():chapters=JSON.parse_string(FileAccess.get_file_as_string("res://data/chapter_art.json"))
 if chapter>=0 and chapter<chapters.size():return chapters[chapter]
 var palettes={"river":[4,5,2,3],"desert":[6,7,3,2],"ember":[8,7,6,3],"moon":[9,2,6,3],"city":[10,3,2,6],"temple":[2,3,6,10],"cave":[11,7,6,2],"grave":[6,2,11,1]}
 return {"props":palettes.get(biome,[0,1,2,3]),"landmark":palettes.get(biome,[0,1])[0]}
static func decorate(obstacles: Array,chapter: int,biome: String) -> void:
 var definition: Dictionary=brief(chapter,biome)
 for i in obstacles.size():
  obstacles[i].art_index=int(definition.landmark) if i==0 else int(definition.props[(i+maxi(chapter,0))%definition.props.size()])
  obstacles[i].art_scale=1.22 if i==0 else 1.0
  obstacles[i].chapter_identity=chapter
static func reward_props(c,chapter: int,biome: String) -> void:
 var definition: Dictionary=brief(chapter,biome)
 for i in 8:
  var row: int=i/4;var col: int=i%4
  c.obstacles.append({"pos":c.arena_origin+Vector2(260+col*360,200 if row==0 else 775),"radius":42.0,"kind":"rock","art_index":int(definition.props[i%definition.props.size()]),"art_scale":1.0,"chapter_identity":chapter})
  var plan: Dictionary=composition(chapter)
  if not plan.is_empty() and i==1:c.obstacles[-1].landmark_index=int(plan.landmark);c.obstacles[-1].display_width=170.0
static func draw(canvas: CanvasItem,obstacle: Dictionary,player: Vector2) -> void:
 var index: int=obstacle.art_index
 var texture: Texture2D=landmark_texture(int(obstacle.landmark_index)) if obstacle.has("landmark_index") else Art.tile("chapter-props-v2",index%4,index/4,4,3)
 var width: float=float(obstacle.get("display_width",float(obstacle.radius)*2.8*float(obstacle.get("art_scale",1))))
 var size: Vector2=Vector2(width,width*texture.get_height()/float(texture.get_width()))
 var position: Vector2=obstacle.pos+Vector2(0,obstacle.radius*.32-size.y*.5)
 var rect: Rect2=Rect2(position-size*.5,size)
 var fade: bool=player.y<obstacle.pos.y and rect.grow(15).has_point(player-Vector2(0,45))
 # Contact shadow and sprite share the collision foot position, actor Y sort and fade.
 Art.stamp(canvas,shadow_texture(),obstacle.pos+Vector2(0,7),Vector2(width*.85,clampf(width*.18,16,38)))
 Art.stamp(canvas,texture,position,size,0,.28 if fade else 1.0)
static func landmark_texture(index: int) -> Texture2D:
 if index<8:return Art.tile("chapter-landmarks-v3",index%4,index/4,4,2)
 var local: int=index-8
 return Art.tile("chapter-landmarks-v4-%d"%(local/8),local%4,(local%8)/4,4,2)
