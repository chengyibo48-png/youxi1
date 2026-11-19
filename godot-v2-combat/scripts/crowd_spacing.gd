extends RefCounted
var cells: Dictionary={}
func rebuild(actors: Array) -> void:
 cells.clear()
 for actor in actors:
  if actor.dead or actor.kind=="dummy":continue
  var cell: Vector2i=Vector2i((actor.pos/96).floor())
  if not cells.has(cell):cells[cell]=[]
  cells[cell].append(actor)
func push(actor: Dictionary) -> Vector2:
 var cell: Vector2i=Vector2i((actor.pos/96).floor());var result=Vector2.ZERO
 for y in [-1,0,1]:
  for x in [-1,0,1]:
   for other in cells.get(cell+Vector2i(x,y),[]):
    if other.uid==actor.uid or other.dead:continue
    var delta: Vector2=actor.pos-other.pos
    var gap: float=actor.radius+other.radius+6
    var squared: float=delta.length_squared()
    if squared>=gap*gap:continue
    var length: float=sqrt(squared)
    var direction: Vector2=delta/length if length>.1 else Vector2.RIGHT.rotated(actor.uid*2.399)
    result+=direction*(1-length/gap)
 return result.limit_length(1)
