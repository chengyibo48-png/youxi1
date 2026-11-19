extends SceneTree
var failed: int=0
var passed: int=0
func check(value: bool,message: String) -> void:
 if value:passed+=1
 else:failed+=1;push_error(message)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var db=preload("res://scripts/content.gd").new()
 var combat=preload("res://scripts/combat.gd").new(db)
 var hero: Dictionary=db.find("heroes","wukong")
 combat.reset(hero,db.find("weapons","wukong_w0"))
 combat.configure_arena(Vector2(2400,1400));combat.player.pos=combat.arena_bounds().get_center()
 var start: Vector2=combat.player.pos
 check(combat.dash(Vector2.RIGHT),"Dash begins from idle")
 for i in 20:combat.update(.01,Vector2.ZERO)
 var kit=preload("res://scripts/character_combat_kit.gd").for_hero("wukong")
 check(absf(combat.player.pos.distance_to(start)-kit.dash_speed*kit.dash_duration)<1,"Dash easing preserves its designed travel distance")
 combat.player.pos=combat.arena_bounds().get_center();combat.enemies=[]
 var first: Dictionary=combat.spawn("chaser",combat.player.pos+Vector2(400,-3),0)
 var second: Dictionary=combat.spawn("chaser",combat.player.pos+Vector2(400,3),0)
 first.cooldown=999;second.cooldown=999
 for i in 70:
  combat.crowd.rebuild(combat.enemies)
  combat.move_enemy(first,combat.player.pos,.016,75);combat.move_enemy(second,combat.player.pos,.016,75)
 check(first.pos.distance_to(second.pos)>18,"Crowd steering separates overlapping walking monsters")
 var grips=preload("res://scripts/weapon_grips.gd")
 var effects=preload("res://scripts/weapon_effects.gd")
 var signatures: Dictionary={}
 for weapon in db.tables.weapons:
  check(grips.GRIPS.has(weapon.id),"Dedicated grip: "+weapon.id)
  check(effects.MATERIALS.has(weapon.attack_style),"Dedicated material renderer: "+weapon.id)
  var grip: Array=grips.get_grip(weapon.id)
  check(grip[0]>0 and grip[0]<1 and grip[1]<=35,"Grip stays within the handle and arm reach: "+weapon.id)
  signatures[effects.MATERIALS[weapon.attack_style][1]]=true
 check(signatures.size()==30,"Thirty stable material emission identities are defined")
 var scene=load("res://Main.tscn").instantiate();scene.pause_on_focus_loss=false;scene.cinematics_enabled=false
 scene.storage.base_path="user://polish-regression-only.json";root.add_child(scene);await process_frame;scene.start_demo()
 scene.mode="campaign";scene.state="route";scene.visited=[];scene.options=["shrine"];scene.room_id="polish-gate-shrine";scene.enter_room("shrine")
 scene.fight.player.pos=scene.fight.exit_position();scene.demo_control=true;scene.demo_movement_override=Vector2.ZERO
 check(scene.gate_ready(),"Reward-room exit becomes available near its physical gate")
 scene._physics_process(.016)
 check(scene.state=="service_walk","Standing near the exit does not leave the room automatically")
 var event=InputEventAction.new();event.action="interact";event.pressed=true;scene._unhandled_input(event)
 check(scene.state=="route" and "polish-gate-shrine" in scene.visited,"Confirming the physical exit advances the route once")
 scene.state="playing";scene.fight.player.pos=scene.fight.exit_position();scene.fight.player.room_cleared=false
 check(not scene.gate_ready(),"Uncleared combat gates remain locked")
 scene.fight.player.room_cleared=true;check(scene.gate_ready(),"Cleared combat gates become usable")
 for biome in ["forest","temple","river","desert","ember","moon","city","cave"]:
  check(preload("res://scripts/journey_scene_art.gd").texture(biome)!=null,"Terrain exists: "+biome)
 var file=FileAccess.open("res://tests/polish-results.json",FileAccess.WRITE)
 file.store_string(JSON.stringify({"passed":passed,"failed":failed,"scope":"Grip bounds, dash distance, crowd spacing, eight terrain assets and confirmed gate transitions. Visual quality requires native review."},"  "));file.close()
 print("POLISH_CHECKS passed=",passed," failed=",failed)
 scene.queue_free();await process_frame;quit(1 if failed else 0)
