extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(512,384);root.content_scale_size=Vector2i(512,384)
 var canvas=preload("res://tests/ribbon_render.gd").new();root.add_child(canvas)
 await process_frame;await RenderingServer.frame_post_draw
 var before: Image=root.get_texture().get_image();before.save_png("res://tests/ribbon-batch-before.png")
 canvas.legacy=false;canvas.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
 var after: Image=root.get_texture().get_image();after.save_png("res://tests/ribbon-batch-after.png")
 var first: PackedByteArray=before.get_data();var second: PackedByteArray=after.get_data();var difference: int=0;var maximum: int=0
 for i in first.size():
  var error: int=absi(int(first[i])-int(second[i]));maximum=maxi(maximum,error)
  if error>1:difference+=1
 var fraction: float=float(difference)/first.size()
 var file=FileAccess.open("res://tests/ribbon-batch-equivalence.json",FileAccess.WRITE);file.store_string(JSON.stringify({"changed_channel_fraction":fraction,"maximum_channel_difference":maximum,"passed":fraction<.005,"scope":"Eight legacy/batched ribbon cases including duplicates, folds and closed path, plus shards; tolerance allows at most 0.5% image channels differing by more than one byte."},"  "));file.close()
 print("RIBBON_BATCH changed=%.6f max=%d"%[fraction,maximum]);canvas.queue_free();await process_frame;quit(0 if fraction<.005 else 1)
