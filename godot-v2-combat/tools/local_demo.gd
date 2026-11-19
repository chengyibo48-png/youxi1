extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://Main.tscn").instantiate()
 scene.storage.base_path="user://local-role-demo-only.json"
 root.add_child(scene)
 await process_frame
 scene.home()
