extends RefCounted
# AI-assisted full-body prayer poses. Walking and other weapons retain authored grip IK.
const Walk=preload("res://scripts/painted_walk.gd")
const LEFTS=[165.0,425.0,760.0,1070.0]
const WIDTHS=[260.0,335.0,310.0,340.0]
const CENTERS=[294.0,615.0,914.0,1232.0]
const TOPS=[0.0,338.0,682.0]
const HEIGHTS=[338.0,344.0,342.0]
const SOLES=[[335.0,336.0,337.0,337.0],[678.0,679.0,680.0,680.0],[1018.0,1019.0,1019.0,1019.0]]
static var textures: Dictionary={}
static func supported(role: String,player: Dictionary) -> bool:
 var action: Dictionary=player.get("action",{})
 return role=="tangseng" and player.get("weapon_id","")=="tangseng_w3" and player.get("hp",1)>0 and player.get("motion_state","")!="dash" and action.get("kind","")=="skill" and action.get("definition",{}).get("effect","")=="heal"
static func phase(player: Dictionary) -> int:
 var action: Dictionary=player.action
 return 0 if action.elapsed<action.windup else 1 if action.elapsed<action.windup+action.active else 2
static func weight(role: String,player: Dictionary) -> float:
 if not supported(role,player):return 0.0
 var action: Dictionary=player.action
 return smoothstep(0,.05,float(action.elapsed))*(1-smoothstep(float(action.duration)-.06,float(action.duration),float(action.elapsed)))*(1-smoothstep(6,18,float(player.get("travel_speed",0))))
static func frame_texture(row: int,column: int) -> Texture2D:
 var key: int=row*4+column
 if not textures.has(key):
  var texture=AtlasTexture.new();texture.atlas=load("res://assets/painterly/tangseng-prayer-fullbody-v9.png")
  texture.region=Rect2(LEFTS[column],TOPS[row],WIDTHS[column],HEIGHTS[row]);texture.filter_clip=true;textures[key]=texture
 return textures[key]
static func draw(canvas: CanvasItem,player: Dictionary,base: Transform2D,tint: Color,amount: float) -> void:
 if amount<=0:return
 var row: int=phase(player);var column: int=Walk.direction(player.action.direction)
 var pivot=Vector2(CENTERS[column]-LEFTS[column],SOLES[row][column]-TOPS[row])
 canvas.draw_set_transform_matrix(Transform2D(base.x*.33,base.y*.33,base.origin))
 tint.a*=amount
 canvas.draw_texture_rect(frame_texture(row,column),Rect2(-pivot,Vector2(WIDTHS[column],HEIGHTS[row])),false,tint)
 canvas.draw_set_transform_matrix(base)
