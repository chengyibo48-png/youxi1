extends RefCounted
# Editable AnimationLibrary tracks sampled against the authoritative combat clock.
# No AnimationPlayer wall clock: hit-stop, saves and cancellations keep their pose.
static var library: AnimationLibrary
static func family(action: Dictionary) -> String:
 if action.get("heavy",false):return "heavy"
 if action.get("kind","")=="skill" or action.get("kind","")=="ultimate":return "cast"
 var style: String=action.get("weapon_style","")
 if style=="tide_bow":return "bow"
 if style in ["lance","extend","pin","thunder"]:return "thrust"
 if style in ["disc","crescent","meteor","rosary","twin_moon"]:return "throw"
 if action.get("shape","")=="seal":return "cast"
 return "sweep"+str(clampi(int(action.get("combo",1)),1,3))
static func phase(action: Dictionary) -> float:
 var time: float=action.get("elapsed",0)
 var windup: float=maxf(.001,action.get("windup",.1))
 var active: float=maxf(.001,action.get("active",.1))
 var duration: float=maxf(windup+active+.001,action.get("duration",.5))
 if time<windup:return clampf(time/windup,0,1)*.32
 if time<windup+active:return .32+clampf((time-windup)/active,0,1)*.25
 return .57+clampf((time-windup-active)/(duration-windup-active),0,1)*.43
static func sample(role: String,action: Dictionary) -> Vector3:
 if action.is_empty():return Vector3.ZERO
 if library==null:library=load("res://animations/combat_motion.tres")
 var animation: Animation=library.get_animation(role+"_"+family(action))
 return animation.value_track_interpolate(0,phase(action))
static func locomotion(role: String,player: Dictionary) -> Vector3:
 if library==null:library=load("res://animations/combat_motion.tres")
 var dash: bool=player.get("motion_state","")=="dash"
 var clip: Animation=library.get_animation(role+("_dash" if dash else "_walk"))
 var time: float=player.get("dash_pose_phase",0) if dash else fposmod(float(player.get("gait",0))/TAU,1)
 var weight: float=1.0 if dash else clampf(player.get("travel_speed",0)/250.0,0,1)
 return clip.value_track_interpolate(0,time)*weight
