extends SceneTree
# A manual inspection workbench. No normal save file or automatic approval marks.
var scene
var hero_picker: OptionButton
var weapon_picker: OptionButton
var action_picker: OptionButton
var direction_picker: OptionButton
var status: Label
var note: LineEdit
var clip_paused: bool=true
var elapsed: float=0
var speed: float=.25
var ready: bool=false
var directions: Array[Vector2]=[Vector2.DOWN,Vector2.RIGHT,Vector2.UP,Vector2.LEFT]
var actions: Array[String]=[]
var baseline: Dictionary={}
var records: Array=[]
var review_store=preload("res://scripts/save.gd").new()
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
 var saved: Dictionary=review_store.read("user://animation-review-records.json")
 records=saved.get("meta",{}).get("manual_reviews",[])
 scene=load("res://Main.tscn").instantiate();scene.storage.base_path="user://animation-review-only.json";scene.pause_on_focus_loss=false;scene.cinematics_enabled=false;root.add_child(scene);await process_frame
 scene.set_physics_process(false);scene.set_process(false);scene.settings.sfx=false;scene.start_demo();scene.panel.hide()
 var overlay=CanvasLayer.new();overlay.layer=30;root.add_child(overlay)
 var panel=PanelContainer.new();panel.position=Vector2(16,132);panel.size=Vector2(300,488);overlay.add_child(panel)
 var box=VBoxContainer.new();box.add_theme_constant_override("separation",8);panel.add_child(box)
 var title=Label.new();title.text="逐帧检查台 · 人工审核待完成";box.add_child(title)
 hero_picker=OptionButton.new();box.add_child(hero_picker)
 for hero in scene.db.tables.heroes:hero_picker.add_item(hero.name)
 weapon_picker=OptionButton.new();box.add_child(weapon_picker)
 direction_picker=OptionButton.new();box.add_child(direction_picker)
 for label in ["正面","右侧","背面","左侧"]:direction_picker.add_item(label)
 action_picker=OptionButton.new();box.add_child(action_picker)
 var rate=OptionButton.new();box.add_child(rate)
 for label in ["1/4速度","1/2速度","正常速度"]:rate.add_item(label)
 rate.item_selected.connect(func(index):speed=[.25,.5,1.0][index])
 for pair in [["播放 / 暂停",func():clip_paused=not clip_paused],["后退一帧",func():seek(maxf(0,elapsed-1.0/60))],["前进一帧",func():advance(1.0/60)],["从起手重放",restart]]:
  var button=Button.new();button.text=pair[0];button.pressed.connect(pair[1]);box.add_child(button)
 note=LineEdit.new();note.placeholder_text="记录握持、滑步、穿模或命中问题";box.add_child(note)
 for verdict in ["需返修","人工已检查"]:
  var button=Button.new();button.text="记录："+verdict;button.pressed.connect(func():record(verdict));box.add_child(button)
 status=Label.new();status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;box.add_child(status)
 hero_picker.item_selected.connect(func(_index):populate())
 weapon_picker.item_selected.connect(func(_index):restart())
 direction_picker.item_selected.connect(func(_index):restart())
 action_picker.item_selected.connect(func(_index):restart())
 ready=true;populate()
 if "--prayer-v9" in OS.get_cmdline_user_args():
  hero_picker.select(scene.db.tables.heroes.map(func(hero):return hero.id).find("tangseng"));populate()
  weapon_picker.select(3);direction_picker.select(0);action_picker.select(actions.find("tangseng_s0"));restart();clip_paused=false
func populate() -> void:
 var hero: String=scene.db.tables.heroes[hero_picker.selected].id
 weapon_picker.clear();action_picker.clear();actions=["walk","dash","attack_1","attack_2","attack_3","heavy"]
 for weapon in scene.db.for_hero("weapons",hero):weapon_picker.add_item(weapon.name)
 for skill in scene.db.for_hero("skills",hero):actions.append(skill.id)
 for ultimate in scene.db.for_hero("ultimates",hero):actions.append(ultimate.id)
 for action in actions:
  var label: String={"walk":"行走 / 停步","dash":"闪避","attack_1":"第一击","attack_2":"第二击","attack_3":"第三击","heavy":"蓄力重击"}.get(action,"")
  if label=="":label=scene.db.find("skills" if action.contains("_s") else "ultimates",action).name
  action_picker.add_item(label)
 restart()
func restart() -> void:
 if not ready:return
 var hero: String=scene.db.tables.heroes[hero_picker.selected].id
 scene.mode="training";scene.hero_id=hero;scene.weapon_ids=[hero+"_w"+str(weapon_picker.selected),hero+"_w"+str(weapon_picker.selected)]
 scene.fight.reset(scene.db.find("heroes",hero),scene.db.find("weapons",scene.weapon_ids[0]));scene.fight.configure_arena(Vector2(2400,1400));scene.fight.player.pos=scene.fight.arena_bounds().get_center();scene.fight.rng.seed=617
 scene.fight.player.resource=100;scene.fight.player.facing=directions[direction_picker.selected]
 scene.skill_ids=scene.db.for_hero("skills",hero).slice(0,2).map(func(s):return s.id);scene.branches=[0,0];scene.ultimate_id=scene.db.for_hero("ultimates",hero)[0].id;scene.sync_sources()
 for offset in [100,170,240]:
  var target: Dictionary=scene.fight.spawn("dummy",scene.fight.player.pos+directions[direction_picker.selected]*offset,0);target.hp=10000;target.max_hp=10000
  if hero=="shaseng":target.marks=3
 scene.state="playing";scene.panel.hide();baseline=scene.fight.snapshot().duplicate(true);elapsed=0;begin_clip();scene.update_hud();scene.queue_redraw()
func begin_clip() -> void:
 var c=scene.fight;var action: String=actions[action_picker.selected];var d: Vector2=directions[direction_picker.selected]
 if action.begins_with("attack_"):
  c.combo=int(action.right(1))-1;c.combo_until=c.time+2;c.attack(d)
 elif action=="heavy":c.attack(d,true,1)
 elif action=="dash":c.dash(d)
 elif action.contains("_s"):c.skill(scene.db.find("skills",action),0,d)
 elif action.contains("_u"):c.ultimate(scene.db.find("ultimates",action),d)
func advance(dt: float) -> void:
 var action: String=actions[action_picker.selected]
 scene.fight.update(dt,directions[direction_picker.selected] if action=="walk" and elapsed<1 else Vector2.ZERO)
 elapsed+=dt;scene.clock+=dt;scene.update_camera(dt);scene.update_hud();scene.queue_redraw()
func seek(time: float) -> void:
 clip_paused=true;scene.fight.restore(baseline.duplicate(true));elapsed=0;begin_clip()
 while elapsed+1.0/60<time:advance(1.0/60)
 if time>elapsed:advance(time-elapsed)
func _process(dt: float) -> bool:
 if not ready:return false
 if not clip_paused:
  advance(minf(dt,.05)*speed)
  if elapsed>=3:clip_paused=true
 var action: Dictionary=scene.fight.player.action
 status.text="时间 %.3fs · %s\n伤害 %.1f · %s\n记录位于独立 user://animation-review-records.json"%[elapsed,"暂停" if clip_paused else "播放",scene.fight.dealt,"起手" if not action.is_empty() and action.elapsed<action.windup else "命中" if not action.is_empty() and action.elapsed<action.windup+action.active else "收势/待机"]
 return false
func record(verdict: String) -> void:
 records.append({"hero":scene.hero_id,"weapon":scene.weapon_ids[0],"direction":direction_picker.selected,"action":actions[action_picker.selected],"seconds":elapsed,"verdict":verdict,"note":note.text,"review_source":"Manual workbench interaction; not automatic approval"})
 if review_store.write({"meta":{"manual_reviews":records}},"user://animation-review-records.json"):note.clear()
 else:status.text=review_store.last_error

