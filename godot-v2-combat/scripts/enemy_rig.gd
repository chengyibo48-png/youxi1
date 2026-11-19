extends RefCounted
const Art=preload("res://scripts/painterly_assets.gd")
static var part_textures: Dictionary={}
static func update(e: Dictionary,dt: float) -> void:
 var previous: Vector2=e.get("motion_previous",e.pos)
 var displacement: Vector2=e.pos-previous;e.motion_previous=e.pos
 e.motion_velocity=displacement/maxf(.001,dt)
 e.gait=float(e.get("gait",0))+displacement.length()*.085
 preload("res://scripts/foot_contacts.gd").update(e,dt,e.motion_velocity,clampf(e.radius/17.0,.8,2.1))
 if displacement.length()>.05:e.motion_facing=displacement.normalized()
 elif e.get("telegraph",0)>0 or e.get("warning",0)>0:e.motion_facing=(e.target-e.pos).normalized()
 e.pose_release=maxf(0,float(e.get("pose_release",0))-dt)
 var warn: float=maxf(e.get("telegraph",0),e.get("warning",0))
 if float(e.get("pose_previous_warn",0))>0 and warn<=0:e.pose_release=.24
 e.pose_previous_warn=warn
 e.move_blend=lerpf(float(e.get("move_blend",0)),clampf(e.motion_velocity.length()/140,0,1),1-exp(-dt*16))
 e.dash_blend=lerpf(float(e.get("dash_blend",0)),1.0 if maxf(e.get("rush_time",0),e.get("charging",0))>0 else 0.0,1-exp(-dt*22))
static func part(canvas: CanvasItem,row: int,column: int,point: Vector2,size: Vector2,angle: float,tint: Color) -> void:
 var key: int=row*9+column
 if not part_textures.has(key):part_textures[key]=Art.tile("enemy-rig",column,row,9,8)
 var texture: Texture2D=part_textures[key]
 Art.stamp(canvas,texture,point+Vector2(0,size.y*.5).rotated(angle),size,angle,1,tint)
static func draw(canvas: CanvasItem,e: Dictionary) -> void:
 if e.has("profile"):
  preload("res://scripts/boss_rig.gd").draw(canvas,e)
  return
 var row: int={"chaser":0,"ranged":1,"charge":2,"guard":3,"summoner":4,"elite":5,"boss":6}.get(e.kind,0)
 if e.has("profile"):
  row=6 if e.profile.type in ["bull","horn","rhino","bear"] else 5 if e.profile.type in ["tiger","leopard","lion","beast"] else 7 if e.profile.type=="fire" else 4 if e.profile.type in ["bone","robe","spider","wind"] else 1 if e.profile.type in ["fish","bird"] else row
 var scale: float=clampf(e.radius/17.0,.8,2.1);var p: Vector2=e.pos
 var velocity: Vector2=e.get("motion_velocity",Vector2.ZERO);var moving: float=e.get("move_blend",0);var gait: float=e.get("gait",0)
 var facing: Vector2=e.get("motion_facing",Vector2.RIGHT)
 var mirror: float=-1 if facing.x<0 else 1
 var dash: float=e.get("dash_blend",0)
 var attack: float=clampf(e.get("pose_release",0)/.24,0,1)
 var preparation: float=clampf(maxf(e.get("telegraph",0),e.get("warning",0))/.8,0,1)
 var action: String=e.get("action",e.get("attack",""))
 if not e.has("profile"):action=e.get("attack","")
 var skin_tint: Color=Color(1.2,1.15,1.05) if e.get("flash",0)>0 else Color.WHITE
 var lean: float=mirror*(moving*.12+dash*.26+attack*.22-preparation*.1)
 var bob: float=absf(sin(gait))*2*moving
 var hip: Vector2=p+Vector2(0,-39*scale-bob)
 # Contact leg stays at ground height; only the swing foot lifts.
 for side in [-1,1]:
  var phase: float=gait+(PI if side==1 else 0)
  var stride: float=sin(phase)*13*scale*moving
  var lift: float=maxf(0,cos(phase))*7*scale*moving
  var root: Vector2=hip+Vector2(side*8*scale,0)
  var target: Vector2=e.get("foot_contacts",{}).get(side,{"point":p+Vector2(side*9*scale+stride,1-lift)}).point
  var delta: Vector2=target-root;var distance: float=clampf(delta.length(),2,43*scale)
  var length: float=22*scale
  var angle: float=delta.angle()-PI/2
  var bend: float=acos(clampf(distance/(length*2),0,1))
  var thigh: float=angle+mirror*bend
  var knee: Vector2=root+Vector2(0,length).rotated(thigh)
  part(canvas,row,5,root,Vector2(24,23)*scale,thigh,skin_tint)
  part(canvas,row,6,knee,Vector2(23,24)*scale,angle-mirror*bend,skin_tint)
 var torso: Vector2=hip-Vector2(0,40*scale)
 part(canvas,row,7,hip-Vector2(0,10*scale),Vector2(54,38)*scale,lean*.5+sin(gait-.6)*moving*.06,skin_tint)
 part(canvas,row,2 if facing.y<-.4 else 1,torso,Vector2(54,44)*scale,lean,skin_tint)
 var hand: Vector2
 for side in [-1,1]:
  var shoulder: Vector2=torso+Vector2(side*22*scale,10*scale)
  var arm: float=-sin(gait+(PI if side==1 else 0))*moving*.25+mirror*(-preparation*.8+attack*1.2+dash*.6)*(1 if side==1 else -.4)
  if action in ["slam","leap"]:arm+=mirror*(-preparation*1.5+attack*1.0)
  elif action in ["shot","spread","volley","fan","wave"]:arm+=mirror*(-preparation*.9 if side==1 else -preparation*.25)
  elif action in ["laser","fire","ice","poison","web","summon","ward"]:arm+=mirror*(-preparation*1.15 if side==1 else -preparation*.55)
  var elbow: Vector2=shoulder+Vector2(0,21*scale).rotated(arm)
  part(canvas,row,3,shoulder,Vector2(23,24)*scale,arm,skin_tint)
  part(canvas,row,4,elbow,Vector2(23,25)*scale,arm-.25*mirror,skin_tint)
  if side==1:hand=elbow+Vector2(0,18*scale).rotated(arm-.25*mirror)
 Art.stamp(canvas,Art.tile("enemy-rig",0,row,9,8),torso-Vector2(0,11*scale),Vector2(44,44)*scale,lean*.3)
 Art.stamp(canvas,Art.tile("enemy-rig",8,row,9,8),hand+Vector2(23*mirror,-12)*scale,Vector2(73,55)*scale,mirror*(attack*.6-preparation*.7))
