extends SceneTree
func _initialize() -> void:call_deferred("run")
func difference(first: Image,second: Image) -> Dictionary:
 var a: PackedByteArray=first.get_data();var b: PackedByteArray=second.get_data();var changed: int=0;var maximum: int=0
 for index in a.size():
  var error: int=absi(int(a[index])-int(b[index]));maximum=maxi(maximum,error)
  if error>0:changed+=1
 return {"changed_channels":changed,"maximum_error":maximum}
func capture() -> Image:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 return root.get_texture().get_image()
func run() -> void:
 root.size=Vector2i(512,384);root.content_scale_size=Vector2i(512,384)
 var canvas=preload("res://tests/ribbon_cache_render.gd").new();root.add_child(canvas)
 var before: Image=await capture();before.save_png("res://tests/ribbon-cache-before.png")
 canvas.legacy=false;canvas.queue_redraw();var after: Image=await capture();after.save_png("res://tests/ribbon-cache-after.png")
 var ribbon: Dictionary=difference(before,after);canvas.queue_free();await process_frame
 root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
 var font: Font=load("res://assets/chinese.ttf");var icons=preload("res://scripts/icon_catalog.gd").new()
 var model={"title":"孙悟空","hp":81,"max_hp":110,"shield":35,"resource":74,"role_id":"wukong","resource_name":"棍势","coins":88,"weapon":"如意金箍棒","location":"历劫试炼 · 第11章","action":"重击收势 · 命中","help":"C召回 · Tab构筑 · Escape暂停","slots":[]}
 var statuses: Array=["冷却 12.5s","资源不足·需要20","目标无效·无可牵引目标","起手中·收招后可取消","就绪","收势后切换"]
 for index in 6:model.slots.append({"id":"ui_dash","name":["身外身","印间束缚","三段震地","化龙穿行","闪避","切换兵器"][index],"key":["Q","E","R","F","Space","T"][index],"ready":index==4,"cooldown":2.5 if index==0 else 0,"maximum":8,"status":statuses[index]})
 var uncached=preload("res://tests/hud_uncached.gd").new();root.add_child(uncached);uncached.configure(font,icons);uncached.present(model)
 before=await capture();before.save_png("res://tests/hud-cache-before.png");uncached.hide()
 var cached=preload("res://scripts/game_hud.gd").new();root.add_child(cached);cached.configure(font,icons);cached.present(model)
 after=await capture();after.save_png("res://tests/hud-cache-after.png");var hud: Dictionary=difference(before,after)
 var layout_equal: bool=true
 for text in statuses+statuses:
  if cached.wrapped(text,9)!=cached.wrap_status(text,font,85,9):layout_equal=false
 var report={"ribbon":ribbon,"hud":hud,"status_layout_equal":layout_equal,"wrap_hits":cached.text_wrap_hits,"wrap_misses":cached.text_wrap_misses,"passed":ribbon.changed_channels==0 and hud.changed_channels==0 and layout_equal,"scope":"Original primitive draw order and wrapping versus caches: eight ribbon shapes and six HUD statuses; not a gameplay or human animation approval"}
 var file=FileAccess.open("res://tests/render-cache-equivalence.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close();print(JSON.stringify(report))
 uncached.queue_free();cached.queue_free();await process_frame;quit(0 if report.passed else 1)
