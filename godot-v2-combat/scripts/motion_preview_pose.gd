@tool
extends Node2D
@export var pose: Vector3=Vector3.ZERO:
 set(value):pose=value;queue_redraw()
func _draw() -> void:
 draw_line(Vector2(0,0),Vector2(0,-60+pose.y).rotated(pose.x),Color("c6b17d"),12,true)
 draw_line(Vector2(0,-50+pose.y),Vector2(30,-30+pose.y+pose.z*15),Color("7c9e92"),8,true)
 draw_line(Vector2(0,0),Vector2(-18,42),Color("7c9e92"),8,true)
 draw_line(Vector2(0,0),Vector2(18,42),Color("7c9e92"),8,true)
