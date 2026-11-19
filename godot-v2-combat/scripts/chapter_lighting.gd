extends RefCounted
static var definitions: Array=[]
static var gradients: Dictionary={}
static func definition(chapter: int,biome: String) -> Dictionary:
 if definitions.is_empty():definitions=JSON.parse_string(FileAccess.get_file_as_string("res://data/chapter_lighting_v11.json"))
 if chapter<0 or chapter>=definitions.size():return {}
 var d: Dictionary=definitions[chapter]
 if biome not in d.biomes:return {}
 return d
static func grade(chapter: int,biome: String) -> Color:
 var d: Dictionary=definition(chapter,biome)
 return Color(d.grade) if not d.is_empty() else Color.WHITE
static func edge_texture(d: Dictionary) -> Texture2D:
 var key: int=int(d.chapter)
 if not gradients.has(key):
  var color=Color(d.edge);color.a=float(d.edge_alpha)
  var gradient=Gradient.new();gradient.colors=PackedColorArray([color,Color(color,0)])
  var texture=GradientTexture2D.new();texture.gradient=gradient;texture.width=32;texture.height=128
  texture.fill_from=Vector2(0,0);texture.fill_to=Vector2(0,1);gradients[key]=texture
 return gradients[key]
static func draw_edges(canvas: CanvasItem,bounds: Rect2,chapter: int,biome: String) -> void:
 var d: Dictionary=definition(chapter,biome)
 if d.is_empty():return
 var texture: Texture2D=edge_texture(d)
 var height: float=minf(220,bounds.size.y*.18)
 canvas.draw_texture_rect(texture,Rect2(bounds.position,Vector2(bounds.size.x,height)),false)
 canvas.draw_texture_rect(texture,Rect2(Vector2(bounds.position.x,bounds.end.y),Vector2(bounds.size.x,-height)),false)
