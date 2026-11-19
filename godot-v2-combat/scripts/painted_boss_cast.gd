extends RefCounted
# Original AI-assisted full-body casting poses, not certified hand-drawn animation.
# Side views only; unmade directions and actions keep their existing articulated rig.
const REGIONS=[Rect2(0,0,768,500),Rect2(768,0,768,496),Rect2(0,512,840,512),Rect2(840,496,696,528)]
const PIVOTS=[Vector2(405,493),Vector2(387,493),Vector2(410,469),Vector2(315,510)]
static var textures: Array[Texture2D]=[]
static func frame_index(e: Dictionary) -> int:
 if e.get("profile",{}).get("id","")!="boss_7" or e.get("action","")!="fire":return -1
 if e.get("dead",false) or e.get("transition",0)>0 or e.get("stagger",0)>0:return -1
 var facing: Vector2=e.get("motion_facing",Vector2.RIGHT)
 if absf(facing.x)<absf(facing.y):return -1
 if e.get("warning",0)>0:
  return 0 if float(e.warning)/maxf(.001,e.get("pose_windup",1))>.45 else 1
 if not e.get("cast_released",false) or e.get("pose_release",0)<=0:return -1
 return 2 if e.pose_release>.12 else 3
static func weight(e: Dictionary) -> float:
 if frame_index(e)<0:return 0.0
 if e.get("warning",0)>0:return smoothstep(0,.08,float(e.get("pose_windup",1))-float(e.warning))
 return smoothstep(0,.07,float(e.pose_release))
static func frame_texture(index: int) -> Texture2D:
 if textures.is_empty():
  var sheet: Texture2D=load("res://assets/painterly/redboy-fire-fullbody-v9.png")
  for region in REGIONS:
   var frame=AtlasTexture.new();frame.atlas=sheet;frame.region=region;frame.filter_clip=true;textures.append(frame)
 return textures[index]
static func draw(canvas: CanvasItem,e: Dictionary,opacity: float) -> void:
 var index: int=frame_index(e)
 if index<0 or opacity<=0:return
 var base: Transform2D=canvas.art_draw_base() if canvas.has_method("art_draw_base") else Transform2D.IDENTITY
 var size_scale: float=.42*clampf(float(e.radius)/24.0,.9,1.6)/1.6
 var mirror: float=-1.0 if e.get("motion_facing",Vector2.RIGHT).x<0 else 1.0
 var local=Transform2D(Vector2(size_scale*mirror,0),Vector2(0,size_scale),e.pos)
 var tint: Color=Color(1.2,1.1,1.05) if e.get("flash",0)>0 else Color.WHITE
 tint.a=opacity
 canvas.draw_set_transform_matrix(base*local)
 canvas.draw_texture_rect(frame_texture(index),Rect2(-PIVOTS[index],REGIONS[index].size),false,tint)
 canvas.draw_set_transform_matrix(base)
