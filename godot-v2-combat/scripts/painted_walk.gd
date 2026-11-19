extends RefCounted
# Fixed-cell frame playback: never fit individual alpha bounds (that causes scale jitter).
# Lower-body frame drawings combine with weapon-driven arm IK and four-view upper parts.
static var resources: Dictionary={}
static var pivots: Dictionary={}
const DIRECTIONS=["front","right","back","left"]
static func direction(facing: Vector2) -> int:
 if absf(facing.x)>absf(facing.y):return 1 if facing.x>=0 else 3
 return 0 if facing.y>=0 else 2
static func frames(role: String) -> SpriteFrames:
 if not resources.has(role):resources[role]=load("res://animations/painted/"+role+".tres")
 return resources[role]
static func frame_index(player: Dictionary) -> int:
 var phase: float=fposmod(float(player.get("gait",0))/TAU,1)
 var facing: Vector2=visual_facing(player)
 if player.get("velocity",Vector2.ZERO).dot(facing)<-12:phase=fposmod(-phase,1)
 return int(phase*8)%8
static func sample(role: String,player: Dictionary) -> Texture2D:
 var resource: SpriteFrames=frames(role)
 if resource==null:return null
 return resource.get_frame_texture(DIRECTIONS[direction(visual_facing(player))],frame_index(player))
static func visual_facing(player: Dictionary) -> Vector2:
 return player.get("action",{}).get("direction",player.get("facing",Vector2.RIGHT))
static func pivot(role: String,player: Dictionary) -> Vector2:
 if pivots.is_empty():pivots=JSON.parse_string(FileAccess.get_file_as_string("res://data/painted_frame_pivots.json"))
 var values: Array=pivots[role][direction(visual_facing(player))][frame_index(player)]
 return Vector2(values[0],values[1])
static func weight(player: Dictionary) -> float:
 if player.get("hp",1)<=0 or player.get("motion_state","")=="dash":return 0
 return smoothstep(8,65,float(player.get("travel_speed",0)))
static func draw(canvas: CanvasItem,role: String,player: Dictionary,base: Transform2D,tint: Color) -> void:
 var texture: Texture2D=sample(role,player)
 if texture==null:return
 var amount: float=weight(player)
 if amount<=0:return
 tint.a*=amount
 # Every cell is 192x256; sole offsets compensate drawing placement, never scale.
 var scale: Vector2=Vector2(.29 if role=="bajie" else .27,.22)
 canvas.draw_set_transform_matrix(base)
 canvas.draw_texture_rect(texture,Rect2(-pivot(role,player)*scale,Vector2(192,256)*scale),false,tint)
