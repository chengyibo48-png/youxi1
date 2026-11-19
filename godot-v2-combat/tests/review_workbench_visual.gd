extends "res://tools/animation_review.gd"
var capture_frame: int=0
func _process(dt: float) -> bool:
 if not ready:return false
 if capture_frame==0:
  hero_picker.select(2);populate();direction_picker.select(1);action_picker.select(5);restart();advance(scene.fight.player.action.windup+.04)
 if capture_frame==4:call_deferred("capture_review")
 capture_frame+=1
 return false
func capture_review() -> void:
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/animation-review-workbench.png")
 quit()
