extends RefCounted
# Provisional AI-assisted full bodies. Gameplay and weapon attack timelines remain authoritative.
const Walk=preload("res://scripts/painted_walk.gd")
static var definitions: Dictionary={}
static var textures: Dictionary={}
static var meshes: Dictionary={}
static func definition(role: String) -> Dictionary:
 if definitions.is_empty():definitions=JSON.parse_string(FileAccess.get_file_as_string("res://data/fullbody_regions_v11.json"))
 return definitions.get(role,{})
static func supported(role: String,player: Dictionary) -> bool:
 return player.get("fullbody_walk_enabled",true) and not definition(role).is_empty() and player.get("hp",1)>0 and player.get("hurt_left",0)<=0 and player.get("motion_state","")!="dash" and player.get("action",{}).is_empty()
static func weight(role: String,player: Dictionary) -> float:
 if not supported(role,player):return 0.0
 return smoothstep(4,42,float(player.get("travel_speed",0)))
static func frame_texture(role: String,row: int,column: int) -> Texture2D:
 var key=role+"/"+str(row)+"/"+str(column)
 if not textures.has(key):
  var d: Dictionary=definition(role);var values: Array=d.frames[row][column].region
  var texture=AtlasTexture.new();texture.atlas=load(d.asset);texture.region=Rect2(values[0],values[1],values[2],values[3]);texture.filter_clip=true;textures[key]=texture
 return textures[key]
static func frame_mesh(role: String,row: int,column: int) -> ArrayMesh:
 var key=role+"/"+str(row)+"/"+str(column)
 if not meshes.has(key):
  var d: Dictionary=definition(role);var data: Dictionary=d.frames[row][column]
  var origin=Vector2(data.region[0]+data.pivot[0],data.region[1]+data.pivot[1])
  var atlas_size: Vector2=frame_texture(role,row,column).atlas.get_size()
  var vertices=PackedVector3Array();var uvs=PackedVector2Array();var indices=PackedInt32Array()
  # One cached GPU mesh clips to the connected silhouette. Original bitmaps remain untouched.
  for span in data.spans:
   var corners=PackedVector2Array([Vector2(span[1],span[0]),Vector2(span[2],span[0]),Vector2(span[2],span[0]+1),Vector2(span[1],span[0]+1)])
   var start: int=vertices.size()
   for point in corners:
    var local: Vector2=point-origin;vertices.append(Vector3(local.x,local.y,0));uvs.append(point/atlas_size)
   indices.append_array(PackedInt32Array([start,start+1,start+2,start,start+2,start+3]))
  var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uvs;arrays[Mesh.ARRAY_INDEX]=indices
  var mesh=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);meshes[key]=mesh
 return meshes[key]
static func draw(canvas: CanvasItem,role: String,player: Dictionary,base: Transform2D,tint: Color,amount: float) -> void:
 if amount<=0:return
 var d: Dictionary=definition(role);var row: int=Walk.direction(Walk.visual_facing(player));var column: int=Walk.frame_index(player)
 var scale: float=d.scale
 tint.a*=amount
 # Unarmed walking artwork carries large implements on the back instead of faking a two-handed grip.
 # Drawing actual attacks always returns to the existing constrained hand/weapon rig.
 var id: String=player.get("weapon_id",role+"_w0")
 var grip: Array=preload("res://scripts/weapon_grips.gd").get_grip(id)
 var mirrored: float=-1 if row==3 else 1
 var carry=Vector2(-mirrored*12,-62)
 var angle: float=-PI/3*mirrored
 if grip[3] in ["beads","scroll","lantern","focus","throw"]:carry=Vector2(mirrored*20,-37);angle=0
 preload("res://scripts/weapon_visual.gd").held(canvas,id,carry,angle,78,base,tint)
 canvas.draw_set_transform_matrix(base)
 canvas.draw_mesh(frame_mesh(role,row,column),frame_texture(role,row,column).atlas,Transform2D(0,Vector2(scale,scale),0,Vector2.ZERO),tint)
 canvas.draw_set_transform_matrix(base)
