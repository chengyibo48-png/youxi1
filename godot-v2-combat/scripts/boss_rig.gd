extends RefCounted
const Art=preload("res://scripts/painterly_assets.gd")
const Definition=preload("res://scripts/boss_rig_definition.gd")
static var definitions: Dictionary={}
static func body_texture(d: Resource,column: int) -> Texture2D:
 var group: int=d.atlas_index/6
 return Art.tile("boss-body-v3-"+str(group),column,d.atlas_index%6,7,6 if group<4 else 2)
static func body_piece(canvas: CanvasItem,d: Resource,column: int,pivot: Vector2,size: Vector2,angle: float,tint: Color) -> void:
 Art.stamp(canvas,body_texture(d,column),pivot+Vector2(0,size.y*.5).rotated(angle),size,angle,1,tint)
static func body_segment(canvas: CanvasItem,d: Resource,column: int,a: Vector2,b: Vector2,width: float,tint: Color) -> void:
 body_piece(canvas,d,column,a,Vector2(width,a.distance_to(b)+5),(b-a).angle()-PI/2,tint)
static func head_texture(d: Resource) -> Texture2D:
 var texture: Texture2D=Art.tile("boss-heads-v3",d.atlas_index%6,d.atlas_index/6,6,5)
 if d.head_count==1:return texture
 return Art.tile("boss-lion-head",0,0,1,1)
static func definition(id: String) -> Resource:
 if not definitions.has(id):definitions[id]=load("res://data/boss_rigs/"+id+".tres")
 return definitions[id]
static func piece(canvas: CanvasItem,index: int,pivot: Vector2,size: Vector2,angle: float,tint: Color) -> void:
 Art.stamp(canvas,Art.tile("boss-parts-v2",index%4,index/4,4,3),pivot+Vector2(0,size.y*.5).rotated(angle),size,angle,1,tint)
static func pose(e: Dictionary) -> Dictionary:
 var d: Resource=definition(e.profile.id)
 var s: float=clampf(e.radius/24.0,.9,1.6)
 var moving: float=e.get("move_blend",0);var gait: float=e.get("gait",0)
 var mirror: float=-1 if e.get("motion_facing",Vector2.RIGHT).x<0 else 1
 var prepare: float=clampf(e.get("warning",0)/maxf(.001,e.get("pose_windup",1)),0,1)
 var release: float=clampf(e.get("pose_release",0)/.24,0,1)
 var action: String=e.get("action","")
 var choreography: Dictionary=preload("res://scripts/boss_choreography.gd").sample(e)
 var channels: Array=choreography.channels
 var fall: float=smoothstep(0,1,float(e.get("fall_progress",0)))
 var change: float=sin(clampf(1-float(e.get("transition",0))/1.2,0,1)*PI) if e.get("transition",0)>0 else 0
 var recoil: float=sin(clampf(float(e.get("flash",0))/.1,0,1)*PI)
 var windup: float=sin((1-prepare)*PI*.5) if prepare>0 else 0
 var rotation: float=(-windup*.24+release*.3+e.get("dash_blend",0)*.3)*mirror
 if action in ["fire","laser","gourd","ward","summon","web"]:rotation*=.35
 rotation+=float(channels[0])*mirror*.65
 rotation+=mirror*(fall*.75-recoil*.09)
 var pelvis: Vector2=e.pos+Vector2(0,-44*s+d.crouch*s-absf(sin(gait))*moving*3*s)
 pelvis.y+=(fall*26-change*5)*s
 pelvis.y+=float(channels[1])*s
 if fall<=0:pelvis.y=maxf(pelvis.y,e.pos.y-(d.thigh_length+d.shin_length-2)*s)
 var spine: Vector2=pelvis+Vector2(0,-d.torso_height*s).rotated(rotation)
 var bones: Dictionary={"root":e.pos,"pelvis":pelvis,"spine":spine,"neck":spine+Vector2(0,-12*s),"head":spine+Vector2(sin(float(channels[6]))*7*s,-20*s)}
 for side in [-1,1]:
  var prefix: String="left" if side<0 else "right"
  var hip: Vector2=pelvis+Vector2(side*12*s,0)
  var target: Vector2=e.get("foot_contacts",{}).get(side,{"point":e.pos+Vector2(side*12*s,0)}).point
  var delta: Vector2=target-hip;var l1: float=d.thigh_length*s;var l2: float=d.shin_length*s
  var distance: float=clampf(delta.length(),absf(l1-l2)+.1,l1+l2-.1)
  var bend: float=acos(clampf((l1*l1+distance*distance-l2*l2)/(2*l1*distance),-1,1))
  var knee: Vector2=hip+Vector2.DOWN.rotated(delta.angle()-PI/2+mirror*bend)*l1
  bones[prefix+"_thigh"]=hip;bones[prefix+"_shin"]=knee;bones[prefix+"_foot"]=target
  for pair in d.arm_pairs:
   var shoulder: Vector2=spine+Vector2(side*d.shoulder_width*s,(12+pair*10)*s).rotated(rotation)
   var swing: float=-sin(gait+side*PI*.5)*moving*.22
   var aim: float=mirror*(-windup*.85+release*1.25)
   if action in ["slam","roar"]:aim=mirror*(-windup*2.0+release*1.0)
   elif action in ["laser","fire","web","gourd","summon"]:aim=side*(-windup*1.1+release*.35)
   if d.arm_pairs>1:aim=side*(.45+pair*.23)+sin(gait+pair*1.5)*moving*.2+side*windup*.5
   var angle: float=swing+aim
   angle+=float(channels[2 if side<0 else 3])*mirror*.4/(1+pair*.25)
   angle+=side*change*.95+mirror*fall*.65-side*recoil*.10
   var elbow: Vector2=shoulder+Vector2.DOWN.rotated(angle)*d.arm_length*s
   var hand: Vector2=elbow+Vector2.DOWN.rotated(angle-mirror*.3+float(channels[4 if side<0 else 5])*mirror*.5)*d.arm_length*s
   if d.arm_pairs>1 and pair>0:
    # Extra spider legs articulate to the ground instead of dangling like extra arms.
    var cycle: float=gait+pair*PI*.65+(PI if side>0 else 0)
    var foot: Vector2=e.pos+Vector2(side*(65+pair*12)*s+sin(cycle)*moving*8*s,(pair-2)*15*s-maxf(0,cos(cycle))*moving*8*s)
    var leg_delta: Vector2=foot-shoulder;var leg_length: float=70*s
    var leg_distance: float=clampf(leg_delta.length(),1,leg_length*2-.1)
    var leg_bend: float=acos(leg_distance/(leg_length*2))
    elbow=shoulder+Vector2.DOWN.rotated(leg_delta.angle()-PI/2-side*leg_bend)*leg_length;hand=foot
   bones[prefix+"_arm_"+str(pair)]=shoulder;bones[prefix+"_forearm_"+str(pair)]=elbow;bones[prefix+"_hand_"+str(pair)]=hand
  if d.wing_pairs>0:
   var shoulder: Vector2=spine+Vector2(side*18*s,12*s)
   var angle: float=side*(1.0+sin(gait*.7)*moving*.2+windup*.6-release*.4+float(choreography.wing)*.35)
   bones[prefix+"_wing_0"]=shoulder;bones[prefix+"_wing_tip_0"]=shoulder+Vector2.DOWN.rotated(-angle)*44*s
   bones[prefix+"_wing_end"]=bones[prefix+"_wing_tip_0"]+Vector2.DOWN.rotated(-angle-side*.08)*62*s
 var tip: Vector2=pelvis+Vector2(-mirror*16*s,8*s)
 for segment in d.tail_segments:
  bones["tail_"+str(segment)]=tip
  var angle: float=mirror*(1.0+segment*.26+sin(gait*.45-segment*.5)*moving*.16+windup*.2-release*.18+float(choreography.tail)*.12)
  tip+=Vector2.DOWN.rotated(angle)*18*s
 bones.tail_end=tip
 for index in range(1,d.head_count):
  var angle: float=(index-1)*TAU/(d.head_count-1)
  bones["neck_"+str(index)]=spine
  bones["head_"+str(index)]=spine+Vector2(cos(angle)*44,-35+sin(angle)*22)*s+Vector2(0,sin(gait*.35+index)*moving*2)
 bones.weapon_socket=bones.right_hand_0
 return {"bones":bones,"scale":s,"rotation":rotation,"mirror":mirror,"definition":d,"choreography":channels}
static func segment(canvas: CanvasItem,row: int,column: int,a: Vector2,b: Vector2,width: float,tint: Color) -> void:
 var angle: float=(b-a).angle()-PI/2
 var size: Vector2=Vector2(width,a.distance_to(b)+5)
 Art.stamp(canvas,Art.tile("enemy-rig",column,row,9,8),a+Vector2(0,size.y*.5).rotated(angle),size,angle,1,tint)
static func draw(canvas: CanvasItem,e: Dictionary,opacity: float=1.0) -> void:
 var painted: float=preload("res://scripts/painted_boss_cast.gd").weight(e)
 if painted>0:preload("res://scripts/painted_boss_cast.gd").draw(canvas,e,opacity*painted)
 opacity*=1-painted
 if opacity<=0:return
 var state: Dictionary=pose(e);var b: Dictionary=state.bones;var d: Resource=state.definition
 var s: float=state.scale;var tint: Color=Color(1.2,1.1,1.05) if e.get("flash",0)>0 else Color.WHITE
 tint.a=opacity
 # Every boss owns its torso, costume panels, limb materials and implement.
 body_piece(canvas,d,6,b.spine+Vector2(0,13*s),Vector2(d.shoulder_width*2.6,d.torso_height+43)*s,state.rotation*.7,tint)
 for side in ["left","right"]:
  if d.wing_pairs>0:
   var angle: float=(b[side+"_wing_tip_0"]-b[side+"_wing_0"]).angle()-PI/2
   piece(canvas,0,b[side+"_wing_0"],Vector2(58,70)*s,angle,tint)
   piece(canvas,1,b[side+"_wing_tip_0"],Vector2(60,78)*s,(b[side+"_wing_end"]-b[side+"_wing_tip_0"]).angle()-PI/2,tint)
 for index in d.tail_segments:
  var a: Vector2=b["tail_"+str(index)];var end: Vector2=b["tail_"+str(index+1)] if index+1<d.tail_segments else b.tail_end
  if d.stance=="stinger":piece(canvas,3 if index==d.tail_segments-1 else 2,a,Vector2(23,23)*s,(end-a).angle()-PI/2,tint)
  else:body_segment(canvas,d,1,a,end,14*s,tint)
 for side in ["left","right"]:
  body_segment(canvas,d,3,b[side+"_thigh"],b[side+"_shin"],25*s,tint)
  body_segment(canvas,d,4,b[side+"_shin"],b[side+"_foot"],24*s,tint)
  for pair in range(1,d.arm_pairs):
   var a: Vector2=b[side+"_arm_"+str(pair)];var elbow: Vector2=b[side+"_forearm_"+str(pair)];var hand: Vector2=b[side+"_hand_"+str(pair)]
   body_segment(canvas,d,1,a,elbow,19*s,tint)
   body_segment(canvas,d,2,elbow,hand,14*s,tint)
 body_piece(canvas,d,0,b.spine,Vector2(d.shoulder_width*2.1,d.torso_height+27)*s,state.rotation,tint)
 for side in ["left","right"]:
  body_segment(canvas,d,1,b[side+"_arm_0"],b[side+"_forearm_0"],24*s,tint)
  body_segment(canvas,d,2,b[side+"_forearm_0"],b[side+"_hand_0"],21*s,tint)
 # Independently animated satellites, not one large nine-headed billboard.
 for index in range(1,d.head_count):
  var head: Vector2=b["head_"+str(index)]
  body_segment(canvas,d,1,b["neck_"+str(index)],head,14*s,tint)
  Art.stamp(canvas,head_texture(d),head,Vector2(25,25)*s,sin(index+e.get("gait",0)*.2)*.06,1,tint)
 Art.stamp(canvas,head_texture(d),b.head,d.head_size*s,state.rotation*.25+float(state.choreography[6])*state.mirror,1,tint)
 if d.stance!="winged":
  var aim: float=(b.right_hand_0-b.right_forearm_0).angle()-PI/2+float(state.choreography[7])*state.mirror
  var base: Transform2D=canvas.art_draw_base() if canvas.has_method("art_draw_base") else Transform2D.IDENTITY
  var implement: Texture2D=body_texture(d,5)
  var length: float=100*s
  var size: Vector2=Vector2(length*implement.get_width()/implement.get_height(),length)
  canvas.draw_set_transform_matrix(base*Transform2D(aim,b.weapon_socket))
  canvas.draw_texture_rect(implement,Rect2(Vector2(-size.x*.5,-size.y*.8),size),false,tint)
  canvas.draw_set_transform_matrix(base)
