extends RefCounted
# Conservative, bounded local routes; no claim to solve arbitrary future AI moves.
static func contains(h: Dictionary,p: Vector2,padding: float=20) -> bool:
 if h.kind=="ring":return absf(p.distance_to(h.pos)-float(h.radius))<28+padding
 if h.kind=="laser":return Geometry2D.get_closest_point_to_segment(p,h.pos,h.end).distance_to(p)<float(h.radius)+padding
 return p.distance_to(h.pos)<float(h.radius)+padding
static func route(c,target: Vector2) -> PackedVector2Array:
 if not c.geometry.walkable(target,22):return PackedVector2Array()
 if c.geometry.visible(c.player.pos,target,22):return PackedVector2Array([c.player.pos,target])
 var grid=c.geometry.grid
 if grid==null:return PackedVector2Array()
 var nodes: PackedVector2Array=grid.get_point_path(c.geometry.cell_for(c.player.pos),c.geometry.cell_for(target))
 if nodes.is_empty():return PackedVector2Array()
 var points=PackedVector2Array([c.player.pos]);points.append_array(nodes);points.append(target)
 for i in range(1,points.size()):
  if not c.geometry.visible(points[i-1],points[i],22):return PackedVector2Array()
 return points
static func valid(c,points: PackedVector2Array,hazards: Array,extra_bullets: Array=[]) -> bool:
 if points.size()<2:return false
 var speed: float=maxf(1,c.hero.speed*(1+c.value("speed"))*(.8 if c.has("immovable") else 1)*(.6 if c.player.get("slow",0)>0 else 1))
 if c.player.get("attack_left",0)>0:speed*=preload("res://scripts/action_motion.gd").attack_movement_factor(c.hero.id)
 var acceleration_time: float=preload("res://scripts/character_combat_kit.gd").acceleration_for(c.hero.id)
 var elapsed: float=.12+float(c.player.get("skill_left",0))
 var shots: Array=c.bullets+extra_bullets
 # Sample the time before a player can react, not just the eventual destination.
 for sample in ceili(elapsed/.01)+1:
  if threatened(points[0],minf(elapsed,sample*.01),hazards,shots):return false
 var travelled: float=0
 for i in range(1,points.size()):
  if not c.geometry.visible(points[i-1],points[i],22):return false
  var distance: float=points[i-1].distance_to(points[i]);var samples: int=maxi(1,ceili(distance/15))
  for j in samples+1:
   var fraction: float=float(j)/samples
   var p: Vector2=points[i-1].lerp(points[i],fraction)
   var progress: float=travelled+distance*fraction
   var travel_time: float=sqrt(2*progress*acceleration_time/speed) if progress<speed*acceleration_time*.5 else progress/speed+acceleration_time*.5
   var t: float=elapsed+travel_time
   if threatened(p,t,hazards,shots):return false
  travelled+=distance
 var destination: Vector2=points[-1]
 for h in hazards:
  if h.get("life",0)>0 and (h.get("damage",0)>0 or h.kind in ["web","ice"]) and contains(h,destination):return false
 return true
static func threatened(p: Vector2,t: float,hazards: Array,shots: Array) -> bool:
 for h in hazards:
  if h.get("life",0)<=0 or (h.get("damage",0)<=0 and h.kind not in ["web","ice"]):continue
  var warning: float=h.get("warn",0)
  if t>=warning and t<=warning+h.life and contains(h,p):return true
 for b in shots:
  if b.get("friendly",true) or b.get("life",0)<=t:continue
  var age: float=t-float(b.get("delay",0))
  if age<0:continue
  var predicted: Vector2=b.pos+b.dir*float(b.get("speed",240))*age
  # A swept slice prevents fast bullets from jumping across samples.
  var previous: Vector2=b.pos+b.dir*float(b.get("speed",240))*maxf(0,age-.02)
  if Geometry2D.get_closest_point_to_segment(p,previous,predicted).distance_to(p)<float(b.get("radius",7))+22:return true
 return false
static func find(c,hazards: Array,extra_bullets: Array=[]) -> PackedVector2Array:
 for distance in [90,180,250]:
  for i in 24:
   var target: Vector2=c.player.pos+Vector2.RIGHT.rotated(i*TAU/24)*distance
   var points: PackedVector2Array=route(c,target)
   if points.size()>1 and valid(c,points,hazards,extra_bullets):return points
 return PackedVector2Array()
