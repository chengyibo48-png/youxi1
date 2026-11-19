extends RefCounted
# Original generated bitmap sheets. Keep alpha, sample equal cells without stretching.
const ROLES=["wukong","tangseng","bajie","shaseng","bailongma"]
static var sheets: Dictionary={}
static var tiles: Dictionary={}
static var regions: Dictionary={}
static func tile(sheet: String,column: int,row: int,columns: int,rows: int) -> Texture2D:
 var key: String="%s:%d:%d"%[sheet,column,row]
 if not tiles.has(key):
  if not sheets.has(sheet):sheets[sheet]=load("res://assets/painterly/"+sheet+".png")
  if sheets[sheet]==null:return null
  var result=AtlasTexture.new();result.atlas=sheets[sheet]
  var size: Vector2=result.atlas.get_size()/Vector2(columns,rows)
  result.region=Rect2(Vector2(column,row)*size+Vector2(2,2),size-Vector2(4,4));result.filter_clip=true;tiles[key]=result
  if sheet=="enemy-rig":
   var cuts: Array=[0.0,.107,.219,.302,.386,.470,.553,.638,.734,1.0]
   var width: float=result.atlas.get_width()
   result.region=Rect2(Vector2(cuts[column]*width+3,row*size.y+3),Vector2((cuts[column+1]-cuts[column])*width-6,size.y-6))
  if regions.is_empty() and FileAccess.file_exists("res://assets/painterly/regions.json"):regions=JSON.parse_string(FileAccess.get_file_as_string("res://assets/painterly/regions.json"))
  if regions.has(key):
   var rect: Array=regions[key];result.region=Rect2(rect[0],rect[1],rect[2],rect[3])
 return tiles[key]
static func weapon(id: String) -> Texture2D:
 for row in ROLES.size():
  if id.begins_with(ROLES[row]+"_w"):return tile("weapons",int(id.right(1)),row,6,5)
 return null
static func relic(id: String) -> Texture2D:
 if not id.begins_with("relic_"):return null
 var index: int=int(id.trim_prefix("relic_"))
 if index<0 or index>=23:return null
 return tile("relics",index%6,index/6,6,4)
static func stamp(canvas: CanvasItem,texture: Texture2D,p: Vector2,size: Vector2,angle: float=0,alpha: float=1,tint: Color=Color.WHITE) -> void:
 if texture==null:return
 tint.a*=alpha
 var base: Transform2D=canvas.art_draw_base() if canvas.has_method("art_draw_base") else Transform2D.IDENTITY
 canvas.draw_set_transform_matrix(base*Transform2D(angle,p))
 canvas.draw_texture_rect(texture,Rect2(-size*.5,size),false,tint)
 canvas.draw_set_transform_matrix(base)
static func burst(canvas: CanvasItem,role: String,p: Vector2,d: Vector2,r: float,t: float,alpha: float=1,variant: int=0) -> void:
 var row: int=ROLES.find(role)
 if row<0:row=0
 var image: Texture2D=tile("effects",mini(5,int(t*6)),row,6,5)
 var angle: float=d.angle() if row in [0,3,4] else t*.12
 var size: Vector2=Vector2(r*1.8,r*1.2)
 if variant==1:size=Vector2(r*2.4,r*.7)
 elif variant==2:size=Vector2(r*1.35,r*1.6)
 stamp(canvas,image,p+d*r*.25,size,angle,alpha)
