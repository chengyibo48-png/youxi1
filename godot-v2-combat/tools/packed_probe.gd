extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var database=load("res://scripts/content.gd").new()
 assert(database.tables.talents.size()==123)
 assert(database.tables.bosses.size()==26)
 var scene=load("res://Main.tscn").instantiate()
 scene.storage.base_path="user://packed-smoke-only.json"
 root.add_child(scene)
 await process_frame
 assert(scene.boss_texture!=null and scene.theme_textures.size()==4)
 for item in database.tables.talents:assert(scene.icons.icon(item.id)!=null)
 scene.mode="training";scene.start_run()
 assert(scene.props_texture!=null)
 assert(scene.fight.obstacles.size()>=10)
 assert(scene.fight.geometry.walkable(scene.fight.player.pos))
 scene.fight.spawn("boss",Vector2(750,370),0,"寅将军")
 scene.fight.attack(Vector2.RIGHT,true)
 scene.fight.update(.1,Vector2.RIGHT)
 assert(scene.fight.player.hp>0)
 print("PACKED GAME OK: 123 talents / 26 boss profiles / scene, assets and combat loaded")
 scene.queue_free();await create_timer(.25).timeout;await process_frame;quit()
