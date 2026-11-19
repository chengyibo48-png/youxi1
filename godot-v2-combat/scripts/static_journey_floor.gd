extends Node2D
# Retain static canvas commands; moving the camera does not rebuild ground polygons.
var bounds: Rect2
var ground: Texture2D
var biome: String
var chapter: int
var signature: Array=[]
var redraw_count: int=0
func configure(area: Rect2,texture: Texture2D,theme: String,chapter_index: int) -> void:
 var next: Array=[area,texture,theme,chapter_index]
 if next==signature:return
 signature=next;bounds=area;ground=texture;biome=theme;chapter=chapter_index
 queue_redraw()
func _draw() -> void:
 redraw_count+=1
 if ground!=null:preload("res://scripts/journey_scene_art.gd").floor_art(self,bounds,ground,biome,chapter)
 else:draw_rect(bounds,Color("c8c0a5"))
 if bounds.size.x>1280:draw_rect(bounds,Color("a18450"),false,5)
