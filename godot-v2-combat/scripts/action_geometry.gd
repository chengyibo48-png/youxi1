extends RefCounted
# Shared by contact sweeps and weapon pose: the same trajectory drives both.
static func sample(a: Dictionary, origin: Vector2, progress: float) -> Dictionary:
 var p: float=clampf(progress,0,1)
 var d: Vector2=a.direction
 var angle: float=lerpf(-1.15,1.15,p)*(-1 if a.combo==2 else 1)
 match a.get("weapon_style",""):
  "extend":angle=lerpf(-1.1,.95,p)*(-1 if a.combo==2 else 1)
  "dual":angle=lerpf(-.7,1.5,smoothstep(0,1,p))*(-1 if a.combo==2 else 1)
  "rake":angle=lerpf(-1.3,.7,p*p)*(-1 if a.combo==2 else 1)
  "crescent_staff":angle=lerpf(-.9,1.2,sin(p*PI*.5))*(-1 if a.combo==2 else 1)
  "frost_sword":angle=lerpf(-.55,.7,sqrt(p))*(-1 if a.combo==2 else 1)
  "gate_shield":angle=lerpf(-.35,.45,smoothstep(0,1,p))
 if a.get("weapon_style","")=="extend" and a.combo==2:angle=lerpf(.9,-.9,p)
 angle*=float(a.get("sweep_scale",1))
 if a.shape=="spin":angle=p*TAU
 if a.shape=="thrust":angle=0
 var length: float=a.reach*(.25+.75*sin(p*PI*.5)) if a.shape=="thrust" else a.reach
 return {"tip":origin+d.rotated(angle)*length,"angle":d.angle()+angle,"length":length}
