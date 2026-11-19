extends SceneTree
var scene
var reports: Array=[]
var records: Array=[]
var last_room: String=""
var serviced: Dictionary={}
func _initialize() -> void:call_deferred("run")
func run() -> void:
 scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://journey-bot-test.json";scene.pause_on_focus_loss=false;scene.cinematics_enabled=false;root.add_child(scene);await process_frame
 scene.set_physics_process(false);scene.set_process(false);scene.settings.sfx=false
 for mode in ["campaign","short"]:
  scene.mode=mode;scene.hero_id="wukong";scene.weapon_ids=["wukong_w0","wukong_w1"];scene.skill_ids=["wukong_s0","wukong_s2"];scene.ultimate_id="wukong_u0";scene.start_run()
  scene.rng.seed=811;scene.fight.rng.seed=912;scene.demo_control=true;scene.input_release_guard=false;records=[];last_room="";serviced={}
  var steps: int=0
  while scene.state!="ended" and steps<900000:
   tick(steps);steps+=1
   if steps%600==0:await process_frame
  reports.append({"mode":mode,"state":scene.state,"chapter":scene.chapter,"route_index":scene.route_index,"completed":scene.route_index>=scene.route.size(),"hp":scene.fight.player.hp,"last_hit":scene.fight.player.last_hit,"simulation_seconds":scene.run_time,"steps":steps,"rooms":records.duplicate(true),"scope":"Automated fixed-step play with normal HP, damage and resource costs; no invulnerability injection. Not human playtesting."})
 var file=FileAccess.open("res://tests/journey-bot-results.json",FileAccess.WRITE);file.store_string(JSON.stringify(reports,"  "));file.close()
 print("JOURNEY_BOT "+JSON.stringify(reports.map(func(r):return {"mode":r.mode,"completed":r.completed,"chapter":r.chapter,"hp":r.hp,"seconds":r.simulation_seconds})))
 scene.queue_free();await process_frame;quit()
func tick(frame: int) -> void:
 if scene.room_id!=last_room and scene.state in ["playing","service_walk"]:
  last_room=scene.room_id;records.append({"chapter":scene.chapter,"kind":scene.kind,"hp":scene.fight.player.hp,"coins":scene.fight.player.coins,"talent_points":preload("res://scripts/combo_talents.gd").points(scene.fight),"time":scene.run_time})
 if scene.state=="route":
  var choice: String=scene.options[0]
  for preferred in ["rest","reward","shrine","combat","shop","forge","event","elite","secret","trial","curse","boss"]:
   if preferred in scene.options:choice=preferred;break
  scene.enter_room(choice);return
 if scene.state=="talent":
  if scene.offers.is_empty():scene.finish_choice()
  else:scene.choose_talent(scene.offers[0])
  return
 if scene.state=="service_walk":
  var goal: Vector2=scene.reward_stage.interaction if not serviced.has(scene.room_id) else scene.fight.exit_position()
  scene.demo_movement_override=scene.fight.geometry.direction(scene.fight.player.pos,goal)
  scene.clock+=1.0/60;scene._physics_process(1.0/60)
  if scene.reward_stage.near() and not serviced.has(scene.room_id):scene.services()
  elif scene.gate_ready():scene.cross_gate()
  return
 if scene.state=="service":
  if serviced.has(scene.room_id):scene.enter_reward_stage(false);return
  serviced[scene.room_id]=true
  var item: String=""
  if scene.kind=="rest" and scene.fight.player.hp<scene.fight.player.max_hp:item="heal"
  elif scene.kind=="reward":item="talent"
  elif scene.kind=="event":item="event_alternative"
  elif scene.kind=="shrine" and "coins" in scene.stock:item="coins"
  elif scene.kind=="shop" and scene.fight.player.hp<scene.fight.player.max_hp*.8 and "heal" in scene.stock:
   var price: int=int(14*(1-minf(.35,scene.fight.value("discount"))))
   if scene.reason("heal",price)=="":scene.buy("heal",price);return
  if item!="" and scene.reason(item,0)=="":scene.buy(item,0)
  else:scene.enter_reward_stage(false)
  if scene.state=="service":scene.enter_reward_stage(false)
  return
 if scene.state=="select":scene.commit_selection(scene.selection_items[0]);return
 if scene.state!="playing":return
 var c=scene.fight
 if c.player.get("room_cleared",false):
  scene.demo_movement_override=c.geometry.direction(c.player.pos,c.exit_position());scene.clock+=1.0/60;scene._physics_process(1.0/60)
  if scene.gate_ready():scene.cross_gate()
  return
 var alive: Array=c.enemies.filter(func(e):return not e.dead)
 alive.sort_custom(func(a,b):return a.pos.distance_squared_to(c.player.pos)<b.pos.distance_squared_to(c.player.pos))
 var direction: Vector2=Vector2.RIGHT
 scene.demo_movement_override=Vector2.ZERO
 if not alive.is_empty():
  direction=(alive[0].pos-c.player.pos).normalized()
  var distance: float=alive[0].pos.distance_to(c.player.pos)
  scene.demo_movement_override=c.geometry.direction(c.player.pos,alive[0].pos) if distance>120 else direction.orthogonal()*.5
 var warnings: Array=c.hazards.filter(func(h):return h.warn<.35 and h.life>0 and h.get("damage",0)>0)
 if not warnings.is_empty():
  var path: PackedVector2Array=preload("res://scripts/escape_planner.gd").find(c,c.hazards)
  if path.size()>1:scene.demo_movement_override=(path[1]-c.player.pos).normalized()
  if warnings.any(func(h):return preload("res://scripts/escape_planner.gd").contains(h,c.player.pos)):scene.input_dash=.12
 if alive.any(func(e):return e.get("warning",1)<.25 and e.get("action","")=="charge"):scene.demo_movement_override=direction.orthogonal();scene.input_dash=.12
 scene.demo_aim_override=direction
 if frame%20==0:scene.input_attack=.12
 if frame%150==0:scene.heavy_buffer=.12;scene.heavy_power=.5;scene.heavy_aim=direction
 if frame%180==0:scene.pending_command={"slot":frame/180%2,"left":.12,"aim":direction}
 if frame%240==0:c.relic(scene.db.find("relics",scene.relic_ids[scene.relic_slot]),direction)
 if frame%240==120 and alive.any(func(e):return e.kind=="boss"):c.ultimate(scene.db.find("ultimates",scene.ultimate_id),direction)
 scene.clock+=1.0/60;scene._physics_process(1.0/60)
