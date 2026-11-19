extends RefCounted
static func update(actor: Dictionary,dt: float,velocity: Vector2,scale: float=1) -> void:
 var gait: float=actor.get("gait",0)
 var feet: Dictionary=actor.get("foot_contacts",{})
 var direction: Vector2=velocity.normalized() if velocity.length()>5 else Vector2.ZERO
 for side in [-1,1]:
  var phase: float=fposmod(gait+(PI if side==1 else 0),TAU)
  var ground: Vector2=actor.pos+Vector2(side*9*scale,2)
  var swing: bool=phase<PI and velocity.length()>5
  var entry: Dictionary=feet.get(side,{"point":ground,"start":ground,"swing":false})
  if swing:
   if not entry.swing:entry.start=entry.point
   var progress: float=phase/PI
   var goal: Vector2=ground+direction*12*scale
   entry.point=entry.start.lerp(goal,smoothstep(0,1,progress))-Vector2(0,sin(progress*PI)*7*scale)
  elif velocity.length()<5:entry.point=entry.point.move_toward(ground,dt*80*scale)
  elif entry.swing:entry.point=ground+direction*12*scale
  # Wall collision and abrupt turns cannot stretch a leg outside its reachable span.
  entry.point=ground+(entry.point-ground).limit_length(18*scale)
  entry.swing=swing;feet[side]=entry
 actor.foot_contacts=feet
