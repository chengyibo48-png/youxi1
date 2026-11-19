extends "res://tools/animation_review.gd"
var reviewing: bool=false
func _process(_dt: float) -> bool:
 if ready and not reviewing:reviewing=true;call_deferred("verify_preview")
 return false
func verify_preview() -> void:
 var correct: bool=scene.hero_id=="tangseng" and scene.weapon_ids[0]=="tangseng_w3" and actions[action_picker.selected]=="tangseng_s0"
 if not correct or scene.fight.player.action.is_empty():push_error("Prayer preset failed to start");quit(1);return
 var action: Dictionary=scene.fight.player.action.duplicate(true)
 var recovery: float=action.duration-action.windup-action.active
 var stages: Array=[action.windup*.5,action.windup+action.active*.5,action.windup+action.active+recovery*.5]
 for index in stages.size():
  seek(stages[index]);status.text="素材慢放预览 · "+["起手","合掌","收势"][index]+" · 未标人工通过"
  await process_frame;await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://tests/prayer-v9-live-%d.png"%index)
 print("PRAYER_PRESET frames=3 manual_approved=0");quit()
