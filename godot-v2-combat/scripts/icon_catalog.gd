extends RefCounted
var texture: Texture2D
var entries: Dictionary={}
var cache: Dictionary={}
var role_texture: Texture2D
func _init() -> void:
 texture=load("res://assets/ui/item-icons.png")
 role_texture=load("res://assets/ui/role-abilities.png")
 entries=JSON.parse_string(FileAccess.get_file_as_string("res://assets/ui/item-icons.json"))
func icon(id: String) -> Texture2D:
 if cache.has(id):return cache[id]
 var painted=preload("res://scripts/painterly_assets.gd").weapon(id)
 if painted==null:painted=preload("res://scripts/painterly_assets.gd").relic(id)
 if painted!=null:cache[id]=painted;return painted
 var extra: String="res://assets/ui/extra-"+id+".svg"
 if ResourceLoader.exists(extra):
  if not cache.has(id):cache[id]=load(extra)
  return cache[id]
 var roles: Array=["wukong","tangseng","bajie","shaseng","bailongma"]
 for row in roles.size():
  var role: String=roles[row]
  if id.begins_with(role+"_s") or id.begins_with(role+"_u"):
   if not cache.has(id):
    var column: int=int(id.right(1))+(6 if id.begins_with(role+"_u") else 0)
    var tile=AtlasTexture.new();tile.atlas=role_texture
    var cell: Vector2=role_texture.get_size()/Vector2(8,5)
    tile.region=Rect2(Vector2(column,row)*cell+Vector2(4,4),cell-Vector2(8,8));cache[id]=tile
   return cache[id]
 if not entries.has(id):return null
 if not cache.has(id):
  var region: Array=entries[id].rect
  var tile=AtlasTexture.new();tile.atlas=texture;tile.region=Rect2(region[0],region[1],region[2],region[3]);cache[id]=tile
 return cache[id]
