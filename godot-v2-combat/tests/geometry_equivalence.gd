extends SceneTree
var failed: int=0
func original(obstacles: Array,start: Vector2,end: Vector2,radius: float) -> Dictionary:
 var delta: Vector2=end-start;var length_squared: float=delta.length_squared();var best: float=2;var selected: Dictionary={}
 for obstacle in obstacles:
  var offset: Vector2=start-obstacle.pos;var extent: float=obstacle.radius+radius;var fraction: float=-1
  if offset.length_squared()<extent*extent:fraction=0
  elif length_squared>.0001:
   var b: float=2*offset.dot(delta);var cc: float=offset.length_squared()-extent*extent;var discriminant: float=b*b-4*length_squared*cc
   if discriminant>=0:fraction=(-b-sqrt(discriminant))/(2*length_squared)
  if fraction>=0 and fraction<=1 and fraction<best:best=fraction;selected=obstacle
 return {"fraction":best} if not selected.is_empty() else {}
func _initialize() -> void:
 var g=preload("res://scripts/room_geometry.gd").new();var random=RandomNumberGenerator.new();random.seed=856
 for i in 48:g.obstacles.append({"pos":Vector2(random.randf_range(-500,500),random.randf_range(-500,500)),"radius":random.randf_range(2,100)})
 for i in 6000:
  var start: Vector2=Vector2(random.randf_range(-600,600),random.randf_range(-600,600))
  var end: Vector2=start if i%20==0 else Vector2(random.randf_range(-600,600),random.randf_range(-600,600))
  var radius: float=random.randf_range(0,40);var before: Dictionary=original(g.obstacles,start,end,radius);var after: Dictionary=g.trace(start,end,radius)
  if before.is_empty()!=after.is_empty() or not before.is_empty() and not is_equal_approx(before.fraction,after.fraction):failed+=1
 print("GEOMETRY_EQUIVALENCE samples=6000 failed=%d"%failed);quit(1 if failed else 0)
