from pathlib import Path
R=Path(__file__).resolve().parents[1]
def edit(n,o,v):
 p=R/n;s=p.read_text(encoding='utf-8');assert o in s,(n,o[:45]);p.write_text(s.replace(o,v,1),encoding='utf-8')
edit('scripts/main.gd','fight.motion.update(fight.player,walking,dt,fight.hero.id)\n  fight.player.pos=fight.geometry.move(fight.player.pos,fight.player.velocity*dt)','fight.motion.step(fight,dt,walking,float(fight.hero.speed),0.0)')
edit('scripts/main.gd',' if settings_return=="paused":pause_panel()',' if settings_return in ["room_paused","service_walk","service"]:enter_reward_stage(false)\n elif settings_return=="paused":pause_panel()')
edit('scripts/main.gd','["left","right","up","down","attack","heavy","lock","dash","skill1","skill2","ultimate","relic","switch","recall","map","pause"]','["left","right","up","down","attack","heavy","lock","dash","skill1","skill2","ultimate","relic","switch","recall","interact","map","pause"]')
edit('scripts/main.gd','"recall":"御器召回","map":"构筑"','"recall":"御器召回","interact":"场景交互","map":"构筑"')
edit('scripts/main.gd',' fight.restore(b)\n charging=false',' fight.restore(b)\n if kind in ["shop","shrine","event","rest","reward","forge","curse"]:enter_reward_stage(false)\n charging=false')
tests=''' var NewTalents=preload("res://scripts/combo_talents.gd")
 for talent in db.tables.talents.filter(func(t):return t.id in ["combo_open","combo_lateral","combo_final","combo_return","combo_anchor","combo_aegis","combo_stride","combo_ink","combo_frugal","combo_draw","w_combo_vault","w_echo_staff","t_combo_lotus","t_recall_print","b_combo_guard","b_shield_spend","s_combo_transfer","s_combo_refund","d_combo_recall","d_tide_precision"]):
  var role_id: String=talent.hero if talent.hero!="" else "wukong"
  var variant: int=5 if talent.id in ["combo_lateral","combo_return"] else 2 if talent.id=="t_recall_print" else 1 if talent.id=="d_combo_recall" else 0
  c=fresh(role_id,variant)
  if talent.id=="t_recall_print":c.take("return")
  check(c.take(talent.id),talent.id+" can be selected on appropriate weapon")
  check(not c.take(talent.id),talent.id+" single mechanism cannot stack repeatedly")
  for offset in [Vector2(70,0),Vector2(140,0),Vector2(100,60)]:target(c,offset)
  c.player.shield=50;c.player.resource=100;c.skill_cd=[5.0,5.0]
  var reference=fresh(role_id,variant);reference.player.shield=50;reference.player.resource=100;reference.skill_cd=[5.0,5.0]
  if talent.id=="t_recall_print":reference.take("return")
  for offset in [Vector2(70,0),Vector2(140,0),Vector2(100,60)]:target(reference,offset)
  for move in 3:
   c.attack(Vector2.RIGHT);reference.attack(Vector2.RIGHT)
   var span: float=maxf(c.player.action.duration,reference.player.action.duration)+.28
   advance(c,span);advance(reference,span)
  check(fingerprint(c)!=fingerprint(reference) or c.player.get("combo_draw_ready",false),talent.id+" demonstrably changes three-hit loop")
  check(c.bullets.size()<=160 and c.fields.size()<=32,talent.id+" stays inside concurrent effect limits")
  check(scene.icons.icon(talent.id)!=null,talent.id+" has its selection icon")
 c=fresh();c.player.talent_budget=12
 for t in db.tables.talents:
  if NewTalents.full(c):break
  if c.can_take(t.id):c.take(t.id)
 check(NewTalents.points(c)==12 and not c.can_take("damage"),"campaign chapter has twelve total picks including upgrades")
 c=fresh();c.player.progress_tier=1
 check(not c.can_take("combo_anchor") and c.can_take("combo_frugal"),"early chapter keeps later mechanisms in reserve")
 c.player.progress_tier=2;check(c.can_take("combo_anchor") and not c.can_take("combo_draw"),"middle chapter opens new mechanics but reserves late loop")
 c.player.progress_tier=3;check(c.can_take("combo_draw"),"late chapter opens new risk/reward mechanism")
 c.effect_values={"damage":100.0,"low_power":100.0};c.player.hp=1
 check(c.scale_damage(10)<=30,"ordinary multiplicative damage gain has a bounded ceiling")
 var previous_payload: Dictionary=payload.duplicate(true)
 previous_payload.run.combat.combat_version=3
 var migration_path: String="user://weapon-migration-check.json"
 check(scene.storage.write(previous_payload,migration_path),"write an isolated legacy combat fixture")
 var migrated: Dictionary=scene.storage.read(migration_path)
 check(migrated.get("run",{}).is_empty() and migrated.get("meta",{})==previous_payload.meta and FileAccess.file_exists(migration_path+".pre-weapon-backup.json"),"legacy battle is backed up while permanent progress survives")
 scene.mode="campaign";scene.cinematics_enabled=true;scene.route=[0,1];scene.route_index=0;scene.chapter=0;scene.step=2;scene.visited=[]
 for room_type in ["shop","shrine","event","rest","reward","forge","curse"]:
  scene.room_id="room-check-"+room_type;scene.enter_room(room_type)
  check(scene.state=="service_walk" and is_instance_valid(scene.reward_stage),room_type+" enters its own physical scene")
  check(scene.cinematic.active and is_equal_approx(scene.cinematic.duration,.85),room_type+" has a brief room transition")
  scene.cinematic.skip();scene.services()
  check(scene.state=="service_walk",room_type+" cannot interact from outside scene range")
  scene.demo_control=true;scene.demo_movement_override=Vector2.RIGHT
  var position_before: Vector2=scene.fight.player.pos;scene._physics_process(.05)
  check(scene.fight.player.pos!=position_before,room_type+" real walking animation and movement update")
  scene.fight.player.pos=scene.reward_stage.interaction
  var interact=InputEventAction.new();interact.action="interact";interact.pressed=true;scene._unhandled_input(interact)
  check(scene.state=="service",room_type+" physical interaction opens choices")
  scene.save_run();var room_payload: Dictionary=scene.storage.read()
  check(scene.checkpoint_valid(room_payload.get("run",{})),room_type+" persists choices and physical room state")
 scene.clear_reward_stage()
'''
edit('tests/role_combat.gd',' scene.queue_free();await process_frame',tests+' scene.queue_free();await process_frame')
edit('tests/role_visual.gd',' scene.queue_free();await process_frame;quit()',''' for type in ["shop","shrine","event","rest","reward","forge","curse"]:
  scene.room_id="visual-"+type;scene.visited=[];scene.enter_room(type);scene.cinematic.skip();scene.fight.player.pos=scene.reward_stage.interaction-Vector2(75,0);scene.camera_initialized=false;scene.update_camera(.2);scene.reward_stage.position=scene.camera_offset();scene.update_hud();scene.queue_redraw()
  await process_frame;await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://tests/room-"+type+".png")
 scene.queue_free();await process_frame;quit()''')
print('Added twenty talent effect comparisons, progression limits, migration and seven physical room integration checks.')
