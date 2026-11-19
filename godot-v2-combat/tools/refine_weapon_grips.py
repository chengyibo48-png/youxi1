from pathlib import Path
p=Path(__file__).resolve().parents[1]/'scripts/layered_rig.gd'
s=p.read_text(encoding='utf-8');start=s.index(' var right_hand: Vector2=Vector2.ZERO');end=s.index(' canvas.draw_set_transform_matrix(base)',start)
s=s[:start]+''' var weapon_id: String=player.get("weapon_id",role+"_w0")
 var grip: Array=preload("res://scripts/weapon_grips.gd").get_grip(weapon_id)
 var angle: float=Vector2(facing.x*mirror,facing.y).angle()+float(grip[2])
 var weapon_length: float=85.0 if role!="tangseng" else 73.0
 if not a.is_empty() and a.kind=="attack" and a.shape!="seal":
  var progress: float=clampf((a.elapsed-a.windup)/a.active,0,1)
  var sample: Dictionary=preload("res://scripts/action_geometry.gd").sample(a,Vector2.ZERO,progress)
  angle=Vector2(cos(sample.angle)*mirror,sin(sample.angle)).angle();weapon_length=sample.length
 var axis: Vector2=Vector2.RIGHT.rotated(angle)
 var spacing: float=grip[1]
 var right_hand: Vector2=body+Vector2(0,19)+axis*spacing*.5 if spacing>0 else body+Vector2(18,23)+axis*stage*8
 var left_hand: Vector2=right_hand-axis*spacing if spacing>0 else body+Vector2(-18,24)+Vector2(sin(gait)*moving*5,0)
 if grip[3]=="bow":left_hand=body+Vector2(0,13)+axis*23;right_hand=left_hand-axis*(18+stage*15)
 if grip[3]=="dual":left_hand=body+Vector2(-18,22)-axis*stage*10
 for side in [-1,1]:
  var shoulder: Vector2=body+Vector2(side*18*wide,7)
  var hand: Vector2=right_hand if side>0 else left_hand
  var delta: Vector2=hand-shoulder;var reach: float=clampf(delta.length(),1,34.8)
  var direction: float=delta.angle()-PI/2;var bend: float=acos(reach/35.0)
  var upper: float=direction-side*bend
  var elbow: Vector2=shoulder+Vector2(0,17.5).rotated(upper)
  var fore: float=direction+side*bend
  part(canvas,index,4,shoulder,upper,Vector2(20*wide,22),base,tint)
  part(canvas,index,5,elbow,fore,Vector2(16*wide,22),base,tint)
  if side>0:right_hand=elbow+Vector2(0,17.5).rotated(fore)
  else:left_hand=elbow+Vector2(0,17.5).rotated(fore)
 part(canvas,index,1 if rear else 0,body+Vector2(0,-27),pose[0]*.3,Vector2(38*wide,33),base,tint)
 preload("res://scripts/weapon_visual.gd").held(canvas,weapon_id,right_hand,angle,weapon_length,base,tint,left_hand)
'''+s[end:];p.write_text(s,encoding='utf-8')
