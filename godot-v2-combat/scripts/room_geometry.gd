extends RefCounted
# Shared world geometry: rendering, movement, aiming and navigation use the same circles.
var bounds: Rect2=Rect2(90,150,1100,470)
var obstacles: Array=[]
var grid: AStarGrid2D
const CELL: float=80.0
func configure(rect: Rect2, items: Array) -> void:
 bounds=rect;obstacles=items
 grid=AStarGrid2D.new()
 grid.region=Rect2i(0,0,ceili(rect.size.x/CELL),ceili(rect.size.y/CELL))
 grid.cell_size=Vector2.ONE*CELL
 grid.offset=rect.position+Vector2.ONE*CELL*.5
 grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
 grid.update()
 for y in grid.region.size.y:
  for x in grid.region.size.x:
   var cell=Vector2i(x,y)
   var point: Vector2=grid.get_point_position(cell)
   grid.set_point_solid(cell,not walkable(point,42))
func walkable(point: Vector2, radius: float=20) -> bool:
 if not bounds.grow(-radius).has_point(point):return false
 for obstacle in obstacles:
  if point.distance_squared_to(obstacle.pos)<pow(float(obstacle.radius)+radius,2):return false
 return true
func constrain(point: Vector2, radius: float=20) -> Vector2:
 var result: Vector2=point.clamp(bounds.position+Vector2.ONE*radius,bounds.end-Vector2.ONE*radius)
 for iteration in 3:
  for obstacle in obstacles:
   var delta: Vector2=result-obstacle.pos
   var limit: float=float(obstacle.radius)+radius+.1
   if delta.length()<limit:result=obstacle.pos+(delta.normalized() if delta.length()>.01 else Vector2.UP)*limit
 return result.clamp(bounds.position+Vector2.ONE*radius,bounds.end-Vector2.ONE*radius)
func move(start: Vector2, delta: Vector2, radius: float=20) -> Vector2:
 var result: Vector2=constrain(start,radius)
 var steps: int=maxi(1,ceili(delta.length()/12))
 var increment: Vector2=delta/steps
 for step in steps:result=constrain(result+increment,radius)
 return result
func trace(start: Vector2, end: Vector2, radius: float=0) -> Dictionary:
 var delta: Vector2=end-start
 var length_squared: float=delta.length_squared()
 var swept_min: Vector2=Vector2(minf(start.x,end.x),minf(start.y,end.y))
 var swept_max: Vector2=Vector2(maxf(start.x,end.x),maxf(start.y,end.y))
 var best: float=2.0
 var selected: Dictionary={}
 for obstacle in obstacles:
  var extent: float=float(obstacle.radius)+radius
  if obstacle.pos.x+extent<swept_min.x or obstacle.pos.x-extent>swept_max.x or obstacle.pos.y+extent<swept_min.y or obstacle.pos.y-extent>swept_max.y:continue
  var offset: Vector2=start-obstacle.pos
  var fraction: float=-1.0
  if offset.length_squared()<extent*extent:fraction=0.0
  elif length_squared>.0001:
   var b: float=2*offset.dot(delta)
   var c: float=offset.length_squared()-extent*extent
   var discriminant: float=b*b-4*length_squared*c
   if discriminant>=0:fraction=(-b-sqrt(discriminant))/(2*length_squared)
  if fraction>=0 and fraction<=1 and fraction<best:best=fraction;selected=obstacle
 if selected.is_empty():return {}
 var position: Vector2=start+delta*best
 var normal: Vector2=(position-selected.pos).normalized()
 if normal==Vector2.ZERO:normal=-delta.normalized()
 return {"pos":position,"normal":normal,"fraction":best}
func visible(start: Vector2, end: Vector2, radius: float=0) -> bool:
 return obstacles.is_empty() or trace(start,end,radius).is_empty()
func cell_for(point: Vector2) -> Vector2i:
 var cell=Vector2i(floori((point.x-bounds.position.x)/CELL),floori((point.y-bounds.position.y)/CELL))
 cell=cell.clamp(Vector2i.ZERO,grid.region.size-Vector2i.ONE)
 if not grid.is_point_solid(cell):return cell
 var nearest=cell
 var distance: float=INF
 for y in range(maxi(0,cell.y-3),mini(grid.region.size.y,cell.y+4)):
  for x in range(maxi(0,cell.x-3),mini(grid.region.size.x,cell.x+4)):
   var candidate=Vector2i(x,y)
   if grid.is_point_solid(candidate):continue
   var d: float=grid.get_point_position(candidate).distance_squared_to(point)
   if d<distance:distance=d;nearest=candidate
 return nearest
func direction(start: Vector2, target: Vector2, radius: float=20) -> Vector2:
 if visible(start,target,radius):return (target-start).normalized()
 var points: PackedVector2Array=grid.get_point_path(cell_for(start),cell_for(target))
 for index in range(1,points.size()):
  if start.distance_to(points[index])>20:return (points[index]-start).normalized()
 return Vector2.ZERO
