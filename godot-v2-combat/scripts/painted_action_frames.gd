extends RefCounted
const Walk=preload("res://scripts/painted_walk.gd")
const Motion=preload("res://scripts/authored_motion.gd")
static var resources: Dictionary={}
static var pivots: Dictionary={}
static func frames(role: String) -> SpriteFrames:
 if not resources.has(role):resources[role]=load("res://animations/painted/"+role+"_action.tres")
 return resources[role]
static func phase_index(action: Dictionary) -> int:
 return mini(5,int(Motion.phase(action)*6))
static func weight(player: Dictionary) -> float:
 var action: Dictionary=player.get("action",{})
 if action.is_empty() or player.get("hp",1)<=0 or player.get("motion_state","")=="dash":return 0
 var time: float=action.get("elapsed",0);var duration: float=action.get("duration",.5)
 var edge: float=minf(.06,duration*.12)
 # Keep real gait at speed; discrete bracing drawings take over when planted.
 return smoothstep(0,edge,time)*(1-smoothstep(duration-edge,duration,time))*(1-smoothstep(55,150,float(player.get("travel_speed",0))))
static func draw(canvas: CanvasItem,role: String,player: Dictionary,base: Transform2D,tint: Color) -> void:
 var amount: float=weight(player)
 if amount<=0:return
 var action: Dictionary=player.action
 var row: int=Walk.direction(action.get("direction",player.get("facing",Vector2.RIGHT)))
 var index: int=phase_index(action)
 var texture: Texture2D=frames(role).get_frame_texture(Walk.DIRECTIONS[row],index)
 if pivots.is_empty():pivots=JSON.parse_string(FileAccess.get_file_as_string("res://data/painted_action_pivots.json"))
 var values: Array=pivots[role][row][index]
 var scale: Vector2=Vector2(.25 if role=="bajie" else .23,.22)
 tint.a*=amount
 canvas.draw_set_transform_matrix(base)
 canvas.draw_texture_rect(texture,Rect2(-Vector2(values[0],values[1])*scale,Vector2(256,256)*scale),false,tint)
