extends RefCounted
static var definitions: Dictionary={}
static func definition(id: String) -> Dictionary:
 if definitions.is_empty():definitions=JSON.parse_string(FileAccess.get_file_as_string("res://data/boss_choreography_v11.json"))
 return definitions.get(id,{})
static func phase(e: Dictionary) -> float:
 if e.get("dead",false) or e.get("transition",0)>0 or e.get("stagger",0)>0:return -1
 if e.get("warning",0)>0:return clampf(1-float(e.warning)/maxf(.001,float(e.get("pose_windup",1))),0,1)*.5
 if e.get("cast_released",false) and e.get("pose_release",0)>0:return .5+.5*(1-clampf(float(e.pose_release)/.24,0,1))
 return -1
static func sample(e: Dictionary) -> Dictionary:
 var p: float=phase(e);var result={"channels":[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],"tail":0.0,"wing":0.0}
 if p<0:return result
 var moves: Dictionary=definition(e.profile.id).get("actions",{})
 if not moves.has(e.get("action","")):return result
 var action: Dictionary=moves[e.action];var keys: Array=action.keys
 for index in range(1,keys.size()):
  if p>float(keys[index][0]):continue
  var weight: float=smoothstep(float(keys[index-1][0]),float(keys[index][0]),p)
  for channel in 8:result.channels[channel]=lerpf(float(keys[index-1][1][channel]),float(keys[index][1][channel]),weight)
  break
 var envelope: float=sin(p*PI)
 result.tail=float(action.tail)*envelope;result.wing=float(action.wing)*envelope
 return result
