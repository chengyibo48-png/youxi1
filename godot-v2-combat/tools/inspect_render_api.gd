extends SceneTree
func _initialize() -> void:
 for method in RenderingServer.get_method_list():
  if method.name=="canvas_item_add_triangle_array":print(JSON.stringify(method))
 quit()
