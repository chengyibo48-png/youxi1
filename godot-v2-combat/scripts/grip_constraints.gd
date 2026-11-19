extends RefCounted
# Two hands must reach the same rigid shaft; do not clamp each hand independently.
static func solve(right: Vector2,axis: Vector2,spacing: float,right_shoulder: Vector2,left_shoulder: Vector2,reach: float=35.8) -> Dictionary:
 var other: Vector2=left_shoulder+axis*spacing
 var hand: Vector2=right
 if hand.distance_to(right_shoulder)<=reach and hand.distance_to(other)<=reach:return {"right":hand,"left":hand-axis*spacing}
 var a: Vector2=right_shoulder+(hand-right_shoulder).limit_length(reach)
 var b: Vector2=other+(hand-other).limit_length(reach)
 if a.distance_to(other)<=reach:hand=a
 elif b.distance_to(right_shoulder)<=reach:hand=b
 else:
  var delta: Vector2=other-right_shoulder
  var middle: Vector2=(right_shoulder+other)*.5
  var normal: Vector2=delta.normalized().orthogonal()
  var height: float=sqrt(maxf(0,reach*reach-delta.length_squared()*.25))
  var first: Vector2=middle+normal*height;var second: Vector2=middle-normal*height
  hand=first if first.distance_squared_to(right)<second.distance_squared_to(right) else second
 return {"right":hand,"left":hand-axis*spacing}
