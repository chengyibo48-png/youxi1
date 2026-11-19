extends SceneTree
var passed: int=0
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 if ok:passed+=1
 else:failures.append(label);push_error(label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://economy-audio-contracts-only.json";root.add_child(scene);await process_frame
 scene.set_process(false);scene.set_physics_process(false);scene.kind="shop";scene.state="service";scene.bought=[]
 scene.fight.reset(scene.db.find("heroes","wukong"),scene.db.find("weapons","wukong_w0"));scene.hero_id="wukong";scene.fight.player.coins=50;scene.fight.player.shield=150
 var snapshot: String=JSON.stringify(scene.fight.snapshot());var random_state: int=scene.rng.state
 check(scene.transaction_preview("shield",16).contains("150→150"),"Shield preview respects immediate cap")
 check(scene.reason("shield",16)=="护盾已满","Full shield purchase blocked")
 scene.buy("shield",16);check(scene.fight.player.coins==50 and scene.bought.is_empty(),"Blocked shield spends nothing")
 check(snapshot==JSON.stringify(scene.fight.snapshot()) and scene.rng.state==random_state,"Preview and blocked purchase leave combat and RNG intact")
 scene.fight.player.shield=140;scene.buy("shield",16)
 check(scene.fight.player.shield==150 and scene.fight.player.coins==34,"Shield purchase applies stated cap and payment immediately")
 scene.update_hud();check(not scene.room_interact_button.visible and not scene.battle_hud.visible,"Service panel hides world interaction button and combat HUD")
 scene.bought=[];scene.fight.player.resource=85
 check(scene.transaction_preview("resource",6).contains("85→100"),"Resource preview accounts for overflow")
 scene.fight.player.hp=scene.fight.player.max_hp-5
 check(scene.transaction_preview("heal",14).contains("%.0f→%.0f"%[scene.fight.player.hp,scene.fight.player.max_hp]),"Healing preview respects current maximum")
 scene.fight.trial="noheal";check(scene.reason("heal",14)!="","Noheal uses shared reason")
 check(scene.transaction_preview("heal",14).contains("%.0f→%.0f"%[scene.fight.player.hp,scene.fight.player.hp]),"Noheal preview does not promise healing")
 scene.fight.trial="";scene.kind="event"
 for event in scene.db.tables.events:
  if event.effect=="risk":
   scene.event_id=event.id
   var expected: float=maxf(1,scene.fight.player.hp-float(event.get("hp_cost",0))-15)
   check(scene.transaction_preview("risk",int(event.cost)).contains("%.0f→%.0f"%[scene.fight.player.hp,expected]),"Risk preview includes both life costs")
   break
 preload("res://scripts/audio_mix.gd").configure();var count: int=AudioServer.bus_count
 preload("res://scripts/audio_mix.gd").configure()
 check(AudioServer.bus_count==count,"Audio routing configuration is idempotent")
 for label in preload("res://scripts/audio_mix.gd").BUSES:check(AudioServer.get_bus_index(label)>=0,"Audio group "+label)
 check(preload("res://scripts/audio_mix.gd").duck_db(true)==-6 and preload("res://scripts/audio_mix.gd").duck_db(false)==0,"Warning duck is explicit and reversible")
 var file=FileAccess.open("res://tests/economy-audio-contracts.json",FileAccess.WRITE);file.store_string(JSON.stringify({"passed":passed,"failures":failures,"scope":"Transaction numerical predictions and execution, audio routing configuration. No professional listening or human approval."},"  "));file.close()
 scene.queue_free();await process_frame;print("ECONOMY_AUDIO passed=%d failed=%d"%[passed,failures.size()]);quit(1 if not failures.is_empty() else 0)
