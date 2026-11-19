extends "res://scripts/main.gd"
# Benchmark-only environment selector; production mode rules remain unchanged.
var benchmark_environment: String="forest"
var last_draw_ms: float=0
var last_physics_ms: float=0
func sync_static_floor() -> void:
 super.sync_static_floor()
 if "--uncached-floor" in OS.get_cmdline_user_args():static_floor.queue_redraw()
func current_biome() -> String:return benchmark_environment
func _draw() -> void:
 var start: int=Time.get_ticks_usec();super._draw();last_draw_ms=(Time.get_ticks_usec()-start)/1000.0
func _physics_process(dt: float) -> void:
 var start: int=Time.get_ticks_usec();super._physics_process(dt);last_physics_ms=(Time.get_ticks_usec()-start)/1000.0
