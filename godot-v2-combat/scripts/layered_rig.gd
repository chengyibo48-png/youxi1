extends RefCounted
# Atlas has hand-painted parts. Coordinates follow the inspected gutters, not an assumed equal grid.
const CUTS=[0.0,199.0,393.0,584.0,762.0,892.0,1047.0,1215.0,1347.0,1570.0,1774.0]
var atlas: Texture2D
const DASH_POSES={
 "wukong":[.34,-1.2,-.75,.9,-.55,-5.0],
 "tangseng":[.12,-.65,-1.05,.45,-.25,3.0],
 "bajie":[.48,-.65,-1.1,.55,-.45,7.0],
 "shaseng":[.22,-1.6,-.6,.7,-.35,2.0],
 "bailongma":[.4,-1.55,-.4,.95,-.65,-4.0]
}
static func dash_pose(role: String,phase: float) -> Array:
 var pose: Array=DASH_POSES.get(role,DASH_POSES.wukong).duplicate()
 # Push-off, travel and landing return continuously to the ordinary stance.
 var weight: float=smoothstep(0,.22,phase)*(1-smoothstep(.65,1,phase))
 for index in pose.size():pose[index]*=weight
 return pose

func region(column: int, row: int) -> Rect2:
 var y: float=row*177.4
 return Rect2(CUTS[column]+5,y+5,CUTS[column+1]-CUTS[column]-10,167.4)

func part(canvas: CanvasItem, row: int, column: int, pivot: Vector2, rotation: float, extent: Vector2, base: Transform2D, tint: Color) -> void:
 canvas.draw_set_transform_matrix(base*Transform2D(rotation,pivot))
 var sprite: Texture2D=preload("res://scripts/painterly_assets.gd").tile("hero-rig",column,row,10,5)
 canvas.draw_texture_rect(sprite,Rect2(Vector2(-extent.x*.5,0),extent),false,tint)

func key_pose(role: String, clip: String, stage: float, combo: int) -> Array:
 var p: Array=[0.0,-.12,.18,0.0,0.0,0.0]
 var cast: Dictionary={
  "summon":[-.12,-1.25,-.8,1.15,0.0,-4.0],"dash":[-.35,-1.8,-.5,-1.0,-.5,-13.0],"freeze":[0.0,-1.4,-1.0,0.0,0.0,-2.0],"lunge":[.35,-1.2,.45,1.0,-.2,-2.0],"mark":[-.06,-1.45,-1.5,0.0,0.0,0.0],"orbit":[-.1,-2.0,.6,.25,0.0,-2.0],
  "heal":[0.0,-.65,-1.2,0.0,0.0,-4.0],"convert":[.08,-1.2,-.8,0.0,0.0,-2.0],"beam":[.18,-1.4,-1.0,0.0,0.0,-1.0],"sanctuary":[-.1,-2.2,-.3,0.0,0.0,-3.0],"counter":[-.18,-.8,-1.6,.2,0.0,0.0],"pull":[-.2,-.5,-1.0,.15,0.0,2.0],
  "shield":[-.18,-1.0,-1.3,.15,-.2,3.0],"slam":[-.3,.9,-.45,.4,-.1,5.0],"quake":[.35,-.6,.7,.5,-.2,7.0],"charge":[.38,-1.1,.1,.9,-.6,4.0],"resource":[-.08,-.9,-.8,0.0,0.0,0.0],
  "sand":[.10,-1.9,.4,.1,0.0,1.0],"wave":[.17,-1.35,.1,.6,-.25,-1.0],"fan":[-.18,-1.7,-.45,.15,0.0,-1.0],"root":[-.1,-1.1,-1.25,.1,0.0,1.0],"blink":[-.35,-2.0,-.4,.8,-.45,-5.0],"detonate":[.2,-.7,-1.5,.2,0.0,3.0],
  "dragon":[.3,-2.1,.1,1.2,-.5,-9.0],"breath":[.2,-1.1,-.4,.1,-.15,-2.0],"evade":[-.25,-1.75,.25,.8,-.6,-5.0],"waterwall":[-.1,-1.3,-1.0,.15,0.0,-2.0],"pursue":[.33,-1.25,-.15,1.1,-.3,-3.0],
  "giant":[.35,-2.5,.65,.55,-.2,7.0],"avatars":[-.15,-2.1,-.5,.6,-.2,-7.0],"purification":[-.1,-2.1,-1.3,0.0,0.0,-5.0],"chant":[.08,-1.65,-1.2,0.0,0.0,-3.0],"marshal":[.4,-.3,.7,.6,-.3,10.0],"quakes":[.25,-2.2,-.2,.6,-.4,5.0],"sandstorm":[-.15,-2.2,.1,.25,-.1,-3.0],"sandburst":[.25,-1.4,-.4,.6,-.2,-3.0],"dragonflight":[.4,-1.8,-.1,1.2,-.7,-12.0],"tide":[-.2,-2.1,-.8,.4,-.3,-6.0],"windwheel":[-.3,-1.8,-.4,.4,-.2,-3.0],"wake_bell":[.1,-.3,-1.5,0.0,0.0,-2.0],"rake_wall":[.25,-1.3,-1.7,.5,-.2,3.0],"sand_guardian":[.05,-2.1,-.8,.15,0,2.0],"arrow_rain":[-.15,-1.2,-2.0,.5,-.2,-3.0],"ring_storm":[-.35,-2.2,-.5,.4,-.2,-6.0],"golden_city":[.0,-1.8,-1.8,0,0,-4.0],"mountain_rake":[.5,-2.3,.8,.8,-.4,9.0],"mark_collapse":[-.15,-.5,-1.6,.3,-.1,3.0],"sky_bow":[-.2,-1.5,-2.2,.5,-.3,-5.0]
 }
 var effect: String=clip.trim_prefix(role+"_")
 if cast.has(effect):p=cast[effect].duplicate()
 if effect=="pull":p=[-.08,-1.1,-.8,0.0,0.0,-2.0] if role=="tangseng" else [-.32,-1.8,.3,.65,-.2,4.0]
 if effect=="wave":p=[.12,-1.8,.35,.3,-.1,1.0] if role=="shaseng" else [.3,-1.2,-.1,.9,-.5,-3.0]
 if effect=="heavy":p={"wukong":[.28,-2.4,.45,.5,-.1,5.0],"tangseng":[-.08,-1.2,-1.5,0.0,0.0,-3.0],"bajie":[.35,-2.0,.8,.6,-.25,9.0],"shaseng":[.2,-1.5,-.2,.45,-.1,2.0],"bailongma":[.3,-1.6,-.1,.9,-.25,-4.0]}[role].duplicate()
 elif not cast.has(effect):
  p={"wukong":[.18,-1.5,.45,.4,-.2,-2.0],"tangseng":[.02,-.8,-1.1,0.0,0.0,-1.0],"bajie":[.25,-1.0,.65,.3,-.1,4.0],"shaseng":[.14,-1.35,-.1,.25,-.15,0.0],"bailongma":[.25,-1.45,-.1,.8,-.3,-2.0]}[role].duplicate()
  if combo==2:p[1]*=-.6;p[0]*=-.7
  if combo==3:p[1]-=.6;p[5]+=3
 for i in p.size():p[i]*=stage
 return p

func draw(canvas: CanvasItem, index: int, player: Dictionary, tint: Color, clock: float, base: Transform2D, role: String) -> void:
 if atlas==null:atlas=load("res://assets/painterly/hero-rig.png")
 if atlas==null:return
 var fullbody: float=preload("res://scripts/fullbody_locomotion.gd").weight(role,player)
 if fullbody>0:preload("res://scripts/fullbody_locomotion.gd").draw(canvas,role,player,base,tint,fullbody)
 tint.a*=1-fullbody
 if tint.a<=0:return
 var prayer: float=preload("res://scripts/painted_prayer.gd").weight(role,player)
 if prayer>0:preload("res://scripts/painted_prayer.gd").draw(canvas,player,base,tint,prayer)
 tint.a*=1-prayer
 if tint.a<=0:return
 var facing: Vector2=player.get("facing",Vector2.RIGHT)
 var a: Dictionary=player.get("action",{})
 var stage: float=0.0
 if not a.is_empty():
  facing=a.direction
  stage=smoothstep(0,a.windup,a.elapsed)*.55 if a.elapsed<a.windup else lerpf(.55,1.0,clampf((a.elapsed-a.windup)/a.active,0,1)) if a.elapsed<a.windup+a.active else 1-smoothstep(a.windup+a.active,a.duration,a.elapsed)
 var gait: float=player.get("gait",0)
 var moving: float=clampf(player.get("travel_speed",0)/250.0,0,1)
 var mirror: float=-1.0 if facing.x<-.05 else 1.0
 var rear: bool=facing.y<-.45
 var world_base: Transform2D=base
 var view: int=preload("res://scripts/painted_walk.gd").direction(facing)
 base=base*Transform2D(0,Vector2(mirror,1),0,Vector2.ZERO)
 var pose: Array=key_pose(role,player.get("pose_clip",""),stage,int(player.get("attack_combo",1)))
 if player.get("motion_state","")=="dash":pose=dash_pose(role,float(player.get("dash_pose_phase",0)))
 if player.get("hurt_left",0)>0:pose=[-.25,-.3,.3,-.2,.2,2.0]
 if player.get("hp",1)<=0:pose=[.8,.6,.4,-.5,.5,35.0]
 if not a.is_empty() and a.kind=="attack":
  var style: String=a.get("weapon_style","")
  pose={"extend": [0.28, -1.8, 0.4, 0.7, -0.3, -3.0], "pin": [-0.1, -1.2, -0.9, 0.25, -0.1, 2.0], "flame": [0.22, -1.3, -1.4, 0.4, -0.1, -1.0], "dual": [-0.25, -1.95, -0.7, 0.5, -0.2, -2.0], "phantom": [-0.3, -0.7, -1.4, 0.1, 0.15, -4.0], "stamp": [0.04, -0.7, -1.25, 0.05, 0, -1.0], "mandala": [-0.1, -1.7, -1.8, 0.1, 0, -3.0], "rosary": [0.13, -1.1, -0.3, 0.2, 0, -1.5], "scripture": [-0.08, -0.6, -1.8, 0.04, 0.1, -2.0], "bell": [0.1, -0.3, -0.9, 0, 0.2, 2.0], "rake": [0.35, -1.1, 0.6, 0.5, -0.2, 5.0], "hook": [-0.2, -1.8, 0.5, 0.3, -0.1, -1.0], "furrow": [0.45, -0.3, 0.7, 0.6, -0.4, 8.0], "ice_hammer": [0.3, -2.3, -0.5, 0.25, -0.2, 6.0], "meteor": [-0.25, -1.4, -0.6, 0.5, -0.4, -2.0], "crescent_staff": [0.22, -1.7, 0.2, 0.6, -0.2, -1.5], "crescent": [-0.12, -1.6, -0.9, 0.25, -0.1, -2.0], "shards": [0.15, -1.15, -1.6, 0.3, 0.1, -1.0], "sand_seal": [0.07, -0.6, -1.5, 0.0, 0.1, 1.0], "twin_moon": [-0.2, -2.0, -1.8, 0.4, -0.3, -3.0], "lance": [0.4, -1.7, 0.1, 1.0, -0.45, -4.0], "wave_sword": [0.2, -1.5, -0.6, 0.5, -0.1, -2.5], "frost_sword": [-0.13, -1.75, 0.3, 0.4, -0.2, -1.2], "thunder": [0.35, -2.1, -0.4, 0.8, -0.5, -5.0], "stars": [-0.1, -1.2, -1.5, 0.2, -0.1, -4.0],"disc":[-.2,-1.6,-.7,.2,-.1,-2.0],"lotus_lantern":[.1,-.6,-1.7,.1,0,-1.0],"gate_shield":[.5,-.4,-.8,.8,-.3,4.0],"tether":[-.3,-2.2,.1,.5,-.3,-3.0],"tide_bow":[-.15,-1.4,-2.0,.3,-.1,-2.0]}.get(style,[0.0,0.0,0.0,0.0,0.0,0.0]).duplicate()
  if not a.heavy and a.combo==2:
   pose[0]*=-.85;pose[1]=-.45-pose[1]*.45;pose[2]-=.45;pose[3]*=-.6;pose[5]-=1.5
  elif not a.heavy and a.combo==3:
   pose[0]+=.18;pose[1]-=.5;pose[2]+=.25;pose[3]+=.28;pose[4]-=.18;pose[5]+=2.0
  for j in pose.size():pose[j]*=stage
 var authored: Vector3=preload("res://scripts/authored_motion.gd").sample(role,a)
 if a.is_empty():authored=preload("res://scripts/authored_motion.gd").locomotion(role,player)
 pose[0]+=authored.x;pose[5]+=authored.y
 if player.get("visual_pose_frame",-1)!=Engine.get_process_frames():
  var previous_pose: Array=player.get("visual_pose",pose).duplicate()
  var weight: float=1-exp(-float(player.get("visual_dt",player.get("pose_dt",.016)))*26)
  for j in pose.size():previous_pose[j]=lerpf(float(previous_pose[j]),float(pose[j]),weight)
  player.visual_pose=previous_pose;player.visual_pose_frame=Engine.get_process_frames()
 pose=player.get("visual_pose",pose)
 var bob: float=-absf(sin(gait))*2.0*moving+sin(clock*2)*.35+pose[5]
 var body: Vector2=Vector2(0,-67+bob)
 var wide: float=1.18 if role=="bajie" else 1.0
 # Both legs articulate at hip and knee, with separate planted feet.
 var leg_tint: Color=tint
 var planted: float=preload("res://scripts/painted_action_frames.gd").weight(player)
 leg_tint.a*=(1-preload("res://scripts/painted_walk.gd").weight(player))*(1-planted)
 for side in [-1,1]:
  var hip: Vector2=Vector2(side*9*wide,-32+bob)
  var foot: Vector2=Vector2(side*10,1)
  if player.get("foot_contacts",{}).has(side):
   foot=player.foot_contacts[side].point-player.pos;foot.x*=mirror
  if player.get("motion_state","")=="dash":
   # Dash is push-off and recovery, not accelerated walk-cycle foot stamping.
   var leg_angle: float=float(pose[3 if side>0 else 4])
   foot=Vector2(side*10+sin(leg_angle)*16,1-maxf(0,sin(leg_angle))*8)
  var delta: Vector2=foot-hip;var reach: float=clampf(delta.length(),1,37.8)
  var angle: float=delta.angle()-PI/2;var bend: float=acos(reach/38.0)
  var upper: float=angle+bend
  part(canvas,index,6,hip,upper,Vector2(23*wide,21),base,leg_tint)
  var knee: Vector2=hip+Vector2(0,19).rotated(upper)
  part(canvas,index,7,knee,angle-bend,Vector2(18*wide,24),base,leg_tint)
 part(canvas,index,8,Vector2(0,-38+bob),sin(gait-.8)*moving*.07-pose[0]*.2,Vector2(48*wide,39),base,leg_tint)
 var walking_tint: Color=tint;walking_tint.a*=1-planted
 preload("res://scripts/painted_walk.gd").draw(canvas,role,player,world_base,walking_tint)
 preload("res://scripts/painted_action_frames.gd").draw(canvas,role,player,world_base,tint)
 oriented_part(canvas,index,view+4,body,pose[0],Vector2(45*wide,42),world_base,tint)
 var weapon_id: String=player.get("weapon_id",role+"_w0")
 var grip: Array=preload("res://scripts/weapon_grips.gd").get_grip(weapon_id)
 var angle: float=Vector2(facing.x*mirror,facing.y).angle()+float(grip[2])
 var weapon_length: float=85.0 if role!="tangseng" else 73.0
 if not a.is_empty() and a.kind=="attack" and a.shape!="seal":
  var progress: float=clampf((a.elapsed-a.windup)/a.active,0,1)
  var sample: Dictionary=preload("res://scripts/action_geometry.gd").sample(a,Vector2.ZERO,progress)
  # Thrust travel is arm/foot motion; a rigid spear must not shrink with progress.
  if a.shape=="thrust" and a.get("weapon_style","")!="extend":sample.length=a.reach
  var action_angle: float=Vector2(cos(sample.angle)*mirror,sin(sample.angle)).angle()
  if a.elapsed<a.windup:
   var prepare: float=smoothstep(0,a.windup,a.elapsed)
   angle=lerp_angle(angle,action_angle,prepare);weapon_length=lerpf(weapon_length,sample.length,prepare)
  elif a.elapsed>a.windup+a.active:
   var return_phase: float=smoothstep(a.windup+a.active,a.duration,a.elapsed)
   angle=lerp_angle(action_angle,angle,return_phase);weapon_length=lerpf(sample.length,weapon_length,return_phase)
  else:angle=action_angle;weapon_length=sample.length
 var axis: Vector2=Vector2.RIGHT.rotated(angle)
 var spacing: float=grip[1]
 var right_hand: Vector2=body+Vector2(0,19)+axis*spacing*.5 if spacing>0 else body+Vector2(18,23)+axis*stage*8
 var left_hand: Vector2=right_hand-axis*spacing if spacing>0 else body+Vector2(-18,24)+Vector2(sin(gait)*moving*5,0)
 if not a.is_empty() and a.kind in ["skill","ultimate"] and grip[3]!="bow":
  # Skill key poses must reach the hands, rather than stopping at the waist.
  # Two-handed implements keep their original shaft spacing throughout the gesture.
  right_hand=body+Vector2(18*wide,7)+Vector2.DOWN.rotated(float(pose[1]))*31
  left_hand=right_hand-axis*spacing if spacing>0 else body+Vector2(-18*wide,7)+Vector2.DOWN.rotated(float(pose[2]))*31
 if grip[3]=="bow":
  var draw_strength: float=0.0
  if not a.is_empty() and a.kind=="attack":draw_strength=smoothstep(0,a.windup,a.elapsed) if a.elapsed<a.windup else 1-smoothstep(a.windup,a.windup+.04,a.elapsed)
  left_hand=body+Vector2(0,13)+axis*23;right_hand=left_hand-axis*(18+draw_strength*15)
 if grip[3]=="dual":left_hand=body+Vector2(-18,22)-axis*stage*10
 if spacing>0 and grip[3]!="bow":
  var shoulders: Vector2=Vector2(0,7+authored.z*4)
  var constrained: Dictionary=preload("res://scripts/grip_constraints.gd").solve(right_hand,axis,spacing,body+shoulders+Vector2(18*wide,0),body+shoulders-Vector2(18*wide,0),35.8*wide)
  right_hand=constrained.right;left_hand=constrained.left
 for side in [-1,1]:
  var shoulder: Vector2=body+Vector2(side*18*wide,7+authored.z*4)
  var hand: Vector2=right_hand if side>0 else left_hand
  var delta: Vector2=hand-shoulder;var reach: float=clampf(delta.length(),1,35.8*wide)
  var direction: float=delta.angle()-PI/2;var bend: float=acos(reach/(36.0*wide))
  var upper: float=direction-side*bend
  var elbow: Vector2=shoulder+Vector2(0,18*wide).rotated(upper)
  var fore: float=direction+side*bend
  part(canvas,index,4,shoulder,upper,Vector2(20*wide,22),base,tint)
  part(canvas,index,5,elbow,fore,Vector2(16*wide,22),base,tint)
  if side>0:right_hand=elbow+Vector2(0,18*wide).rotated(fore)
  else:left_hand=elbow+Vector2(0,18*wide).rotated(fore)
 oriented_part(canvas,index,view,body+Vector2(0,-27),pose[0]*.3,Vector2(38*wide,33),world_base,tint)
 var secondary: float=angle+.4
 if grip[3]=="dual" and not a.is_empty() and a.kind=="attack":secondary=angle-.65 if a.combo==3 else angle+stage*1.1 if a.combo==2 else angle-stage*.9
 preload("res://scripts/weapon_visual.gd").held(canvas,weapon_id,left_hand if grip[3] in ["bow","shield"] else right_hand,angle,weapon_length,base,tint,right_hand if grip[3] in ["bow","shield"] else left_hand,secondary)
 canvas.draw_set_transform_matrix(base)

func oriented_part(canvas: CanvasItem,row: int,column: int,pivot: Vector2,angle: float,size: Vector2,base: Transform2D,tint: Color) -> void:
 var texture: Texture2D=preload("res://scripts/painterly_assets.gd").tile("hero-facing-v2",column,row,8,5)
 canvas.draw_set_transform_matrix(base*Transform2D(angle,pivot))
 canvas.draw_texture_rect(texture,Rect2(Vector2(-size.x*.5,0),size),false,tint)
