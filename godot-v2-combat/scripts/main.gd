extends Node2D
const Content=preload("res://scripts/content.gd")
const Combat=preload("res://scripts/combat.gd")
const Storage=preload("res://scripts/save.gd")
var db=Content.new()
var fight=Combat.new(db)
var storage=Storage.new()
var font: Font
var bg: Texture2D
var forest: Texture2D
var river: Texture2D
var pose_time: float=0
var pose_duration: float=.2
var pose_heavy: bool=false
var heroes_texture: Texture2D
var props_texture: Texture2D
var enemies_texture: Texture2D
var boss_texture: Texture2D
var enemy_rig_available: bool=ResourceLoader.exists("res://assets/painterly/enemy-rig.png")
var boss_heads_available: bool=ResourceLoader.exists("res://assets/painterly/boss-heads-v2.png")
var music: AudioStreamPlayer
var soundscape
var audio_players: Array[AudioStreamPlayer]=[]
var audio_streams: Dictionary={}
var audio_cursor=0
var theme_textures: Array[Texture2D]=[]
var material_draw_base: Transform2D=Transform2D.IDENTITY
func art_draw_base() -> Transform2D:return material_draw_base
var audio_palette=preload("res://scripts/audio_palette.gd").new()
var settings_return="home"
var homepage=preload("res://scripts/home_screen.gd").new()
var panel: PanelContainer
var box: VBoxContainer
var hud: Label
var character_pose=preload("res://scripts/layered_rig.gd").new()
var role_art=preload("res://scripts/role_presentation.gd").new()
var pending_command: Dictionary={}
var input_release_guard: bool=false
var demo_control: bool=false
var demo_aim_override: Vector2=Vector2.ZERO
var demo_movement_override: Vector2=Vector2.ZERO
var role_lab_hero: String="wukong"
var camera_focus: Vector2=Vector2.ZERO
var camera_initialized: bool=false
var training_build_name: String="基础招式"
var spell_art=preload("res://scripts/skill_presentation.gd").new()
var cinematic=preload("res://scripts/journey_cinematic.gd").new()
var cinematics_enabled=true
var cinematic_input_guard=false
var reward_stage
var static_floor=preload("res://scripts/static_journey_floor.gd").new()
var cull_friendly_projectiles: bool=true
var room_interact_button: Button
var icons=preload("res://scripts/icon_catalog.gd").new()
var battle_hud=preload("res://scripts/game_hud.gd").new()
var heavy_buffer: float=0
var heavy_power: float=0
var heavy_aim: Vector2=Vector2.RIGHT
var afterimages: Array=[]
var ghost_cd: float=0
var training_category: String="shape"
var settings_tab: String="display"
var loadout_tab: String="hero"
var build_tab: String="overview"
var talent_search: String=""
var demo_boss_name: String="红孩儿"
var menu_title: Label
var menu_subtitle: Label
var menu_nav: HBoxContainer
var build_return: String="playing"
var toast_state: String=""
var footer: HBoxContainer
var menu_scroll: ScrollContainer
var toast: Label
var state: String="home"
var hero_id: String="wukong"
var weapon_ids: Array=["wukong_w0","wukong_w1"]
var skill_ids: Array=["wukong_s0","wukong_s2"]
var ultimate_id: String="wukong_u0"
var branches: Array=[0,0]
var relic_ids: Array=["relic_0","relic_6"]
var slot: int=0
var relic_slot: int=0
var mode: String="short"
var rng=RandomNumberGenerator.new()
var audiovisual_rng=RandomNumberGenerator.new()
var run_statistics=preload("res://scripts/run_statistics.gd").new()
var meta: Dictionary={"merit":0,"unlocked":["wukong","tangseng"],"completed":[],"settled":[],"imports":[]}
var settings: Dictionary={"effects":true,"shake":true,"sfx":true,"music":true,"volume":.65,"keys":{},"pad_keys":{},"mouse_keys":{},"hold_attack":false,"reduced_flash":false,"numbers":true,"shake_strength":.5}
var checkpoint: Dictionary={}
var route: Array=[]
var route_index: int=0
var chapter: int=0
var step: int=0
var options: Array=[]
var offers: Array=[]
var banned: Array=[]
var visited: Array=[]
var bought: Array=[]
var stock: Array=[]
var selection_items: Array=[]
var selection_kind: String=""
var rerolls: int=2
var bans: int=1
var pending: String=""
var kind: String="combat"
var room_id: String=""
var run_id: String=""
var event_id: String=""
var event_seen: Array=[]
var remaining: int=0
var spawn_cd: float=0
var room_time: float=0
var run_time: float=0
var boss_cursor: int=0
var trial_index: int=-1
var protection: float=100
var aim: Vector2=Vector2.RIGHT
var charging: bool=false
var charge: float=0
var input_attack: float=0
var input_dash: float=0
var switch_cd: float=0
var clock: float=0
var toast_time: float=0
var hitstop: float=0
var visual_motion_active: bool=false
var next_hitstop: float=0
var shake: float=0
var mapping: String=""
var preview: String=""
var lock_uid: int=-1
var pause_on_focus_loss: bool=true
var audio: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var sound_time: float=0
var sound_freq: float=0
var sound_phase: float=0
var numbers: Array=[]
const NAMES={"combat":"妖氛隘口","elite":"妖将营寨","boss":"妖王正殿","shop":"珍奇货肆","event":"奇遇岔口","shrine":"土地神龛","rest":"歇脚丹房","reward":"藏宝密室","trial":"历劫试炼","curse":"诅咒祭坛","forge":"淬锋锻炉","secret":"隐墨秘境","training":"训练场"}
func _ready() -> void:
 static_floor.z_index=-2;add_child(static_floor)
 Input.joy_connection_changed.connect(on_joy_connection_changed)
 rng.randomize()
 audiovisual_rng.randomize()
 var variation=FontVariation.new()
 variation.base_font=load("res://assets/chinese.ttf")
 variation.variation_opentype={"wght":500}
 variation.variation_embolden=.8
 font=variation
 props_texture=load("res://assets/props-ink.png")
 bg=load("res://assets/courtyard.png")
 forest=load("res://assets/forest.png")
 river=load("res://assets/river.png")
 heroes_texture=load("res://assets/heroes.png")
 enemies_texture=load("res://assets/enemies.png")
 boss_texture=load("res://assets/bosses-premium.png")
 var themes: Texture2D=load("res://assets/environment-atlas.png")
 for i in 4:
  var tile:=AtlasTexture.new();tile.atlas=themes;tile.region=Rect2(Vector2(i%2,int(i/2))*themes.get_size()*.5,themes.get_size()*.5);theme_textures.append(tile)
 setup_input()
 setup_ui()
 setup_audio()
 var cinema_layer:=CanvasLayer.new();cinema_layer.layer=30;add_child(cinema_layer);cinema_layer.add_child(cinematic)
 fight.feedback.connect(feedback)
 var saved: Dictionary=storage.read()
 if not saved.is_empty():
  meta.merge(saved.get("meta",{}),true)
  settings.merge(saved.get("settings",{}),true)
  checkpoint=saved.get("run",{})
 repair_meta()
 apply_keys()
 home()
 if saved.has("migration_note"):notify(saved.migration_note)
 elif not storage.recovery_note.is_empty():notify(storage.recovery_note)
func setup_input() -> void:
 for entry in [["interact",KEY_G],["left",KEY_A],["right",KEY_D],["up",KEY_W],["down",KEY_S],["dash",KEY_SPACE],["skill1",KEY_Q],["skill2",KEY_E],["ultimate",KEY_R],["relic",KEY_F],["map",KEY_TAB],["pause",KEY_ESCAPE],["switch",KEY_T],["recall",KEY_C]]:
  InputMap.add_action(entry[0])
  var key=InputEventKey.new()
  key.physical_keycode=entry[1]
  InputMap.action_add_event(entry[0],key)
 for entry in [["attack",MOUSE_BUTTON_LEFT],["heavy",MOUSE_BUTTON_RIGHT],["lock",MOUSE_BUTTON_MIDDLE]]:
  InputMap.add_action(entry[0])
  var mouse=InputEventMouseButton.new()
  mouse.button_index=entry[1]
  InputMap.action_add_event(entry[0],mouse)
 for entry in [["left",JOY_AXIS_LEFT_X,-1],["right",JOY_AXIS_LEFT_X,1],["up",JOY_AXIS_LEFT_Y,-1],["down",JOY_AXIS_LEFT_Y,1],["ultimate",JOY_AXIS_TRIGGER_LEFT,1],["relic",JOY_AXIS_TRIGGER_RIGHT,1]]:
  var axis=InputEventJoypadMotion.new()
  axis.axis=entry[1]
  axis.axis_value=entry[2]
  InputMap.action_add_event(entry[0],axis)
 for entry in [["attack",JOY_BUTTON_X],["heavy",JOY_BUTTON_Y],["dash",JOY_BUTTON_A],["skill1",JOY_BUTTON_LEFT_SHOULDER],["skill2",JOY_BUTTON_RIGHT_SHOULDER],["map",JOY_BUTTON_BACK],["pause",JOY_BUTTON_START],["switch",JOY_BUTTON_DPAD_UP],["lock",JOY_BUTTON_RIGHT_STICK],["recall",JOY_BUTTON_DPAD_DOWN]]:
  var pad=InputEventJoypadButton.new()
  pad.button_index=entry[1]
  InputMap.action_add_event(entry[0],pad)
func apply_keys() -> void:
 for action in settings.keys:
  if not InputMap.has_action(action):continue
  for event in InputMap.action_get_events(action):
   if event is InputEventKey:InputMap.action_erase_event(action,event)
  var key=InputEventKey.new()
  key.physical_keycode=int(settings.keys[action])
  InputMap.action_add_event(action,key)
 for device in ["pad_keys","mouse_keys"]:
  for action in settings.get(device,{}):
   for event in InputMap.action_get_events(action):
    if (device=="pad_keys" and event is InputEventJoypadButton) or (device=="mouse_keys" and event is InputEventMouseButton):InputMap.action_erase_event(action,event)
   var event=InputEventJoypadButton.new() if device=="pad_keys" else InputEventMouseButton.new()
   event.button_index=int(settings[device][action])
   InputMap.action_add_event(action,event)
func setup_ui() -> void:
 var layer=CanvasLayer.new()
 add_child(layer)
 var theme=Theme.new()
 theme.default_font=font
 theme.default_font_size=18
 var normal=StyleBoxFlat.new()
 normal.bg_color=Color("ede4cd")
 normal.border_color=Color("967445")
 normal.set_border_width_all(1)
 normal.set_corner_radius_all(5)
 normal.content_margin_left=14
 normal.content_margin_right=14
 normal.content_margin_top=10
 normal.content_margin_bottom=10
 theme.set_stylebox("normal","Button",normal)
 var hover=normal.duplicate()
 hover.bg_color=Color("dcc79f")
 theme.set_stylebox("hover","Button",hover)
 var focus=normal.duplicate()
 focus.set_border_width_all(3)
 focus.border_color=Color("b3543d")
 theme.set_stylebox("focus","Button",focus)
 var pressed=normal.duplicate();pressed.bg_color=Color("c4ad83");pressed.content_margin_top=12;pressed.content_margin_bottom=8
 theme.set_stylebox("pressed","Button",pressed)
 var disabled_style=normal.duplicate();disabled_style.bg_color=Color("d3cfbf");disabled_style.border_color=Color("aea99a")
 theme.set_stylebox("disabled","Button",disabled_style)
 theme.set_color("font_disabled_color","Button",Color("7b8279"))
 theme.set_stylebox("normal","LineEdit",normal.duplicate());theme.set_stylebox("focus","LineEdit",focus.duplicate())
 theme.set_color("font_color","LineEdit",Color("253b35"));theme.set_color("font_placeholder_color","LineEdit",Color("7c8271"));theme.set_color("caret_color","LineEdit",Color("b3543d"))
 theme.set_stylebox("panel","PopupMenu",normal.duplicate());theme.set_stylebox("hover","PopupMenu",hover.duplicate());theme.set_color("font_color","PopupMenu",Color("253b35"));theme.set_color("font_hover_color","PopupMenu",Color("253b35"))
 theme.set_color("font_color","Button",Color("253b35"))
 theme.set_color("font_hover_color","Button",Color("253b35"))
 theme.set_color("font_focus_color","Button",Color("253b35"))
 panel=PanelContainer.new()
 panel.position=Vector2(205,84)
 panel.size=Vector2(870,560)
 panel.theme=theme
 var paper=normal.duplicate()
 paper.bg_color=Color(.94,.91,.82,.98)
 paper.content_margin_left=26
 paper.content_margin_right=26
 paper.content_margin_top=20
 paper.content_margin_bottom=20
 panel.add_theme_stylebox_override("panel",paper)
 layer.add_child(homepage);homepage.configure(font)
 homepage.chosen.connect(func(choice):
  if choice=="resume":resume_run()
  else:mode=choice;loadout())
 homepage.utility.connect(func(action):
  if action=="settings":show_settings()
  elif action=="merit":merit_shop()
  else:show_import())
 layer.add_child(panel)
 room_interact_button=Button.new();room_interact_button.position=Vector2(490,570);room_interact_button.size=Vector2(300,48);room_interact_button.text="交互 · G / Enter / 手柄确认";room_interact_button.hide();layer.add_child(room_interact_button)
 room_interact_button.pressed.connect(func():
  if gate_ready():cross_gate()
  elif state=="service_walk" and is_instance_valid(reward_stage) and reward_stage.near():services())
 var shell=VBoxContainer.new();shell.add_theme_constant_override("separation",12);panel.add_child(shell)
 menu_title=Label.new();menu_title.add_theme_font_size_override("font_size",28);menu_title.add_theme_color_override("font_color",Color("253b35"));shell.add_child(menu_title)
 menu_subtitle=Label.new();menu_subtitle.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;menu_subtitle.add_theme_font_size_override("font_size",15);menu_subtitle.add_theme_color_override("font_color",Color("57675b"));shell.add_child(menu_subtitle)
 menu_nav=HBoxContainer.new();menu_nav.add_theme_constant_override("separation",8);shell.add_child(menu_nav)
 menu_scroll=ScrollContainer.new();menu_scroll.custom_minimum_size=Vector2(810,280);menu_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;shell.add_child(menu_scroll)
 box=VBoxContainer.new();box.size_flags_horizontal=Control.SIZE_EXPAND_FILL;box.add_theme_constant_override("separation",9);menu_scroll.add_child(box)
 footer=HBoxContainer.new();footer.add_theme_constant_override("separation",12);shell.add_child(footer)
 hud=Label.new()
 hud.position=Vector2(24,12)
 hud.add_theme_font_override("font",font)
 hud.add_theme_font_size_override("font_size",17)
 hud.add_theme_color_override("font_color",Color("ebd7ad"))
 layer.add_child(hud)
 hud.hide()
 layer.add_child(battle_hud)
 battle_hud.configure(font,icons)
 toast=Label.new()
 toast.position=Vector2(250,668)
 toast.size=Vector2(780,40)
 toast.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 toast.add_theme_font_override("font",font)
 toast.add_theme_color_override("font_color",Color("f3d791"))
 layer.add_child(toast)
func show_panel(title: String, subtitle: String="") -> void:
 homepage.hide()
 if is_instance_valid(battle_hud):battle_hud.hide()
 if is_instance_valid(room_interact_button):room_interact_button.hide()
 for container in [box,footer,menu_nav]:
  for child in container.get_children():container.remove_child(child);child.queue_free()
 menu_nav.hide()
 panel.show();menu_title.text=title;menu_subtitle.text=subtitle;menu_subtitle.visible=subtitle!=""
 menu_scroll.scroll_vertical=0
func menu_grid(columns: int=2) -> GridContainer:
 var grid=GridContainer.new();grid.columns=columns;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 grid.add_theme_constant_override("h_separation",12);grid.add_theme_constant_override("v_separation",10);box.add_child(grid);return grid
func selected_style(item: Button, selected: bool) -> void:
 if not selected:return
 var style=StyleBoxFlat.new();style.bg_color=Color("dccca8");style.border_color=Color("b3543d");style.set_border_width_all(2);style.set_corner_radius_all(5)
 style.content_margin_left=14;style.content_margin_right=14;style.content_margin_top=10;style.content_margin_bottom=10
 item.add_theme_stylebox_override("normal",style)
func navigation(ids: Array, labels: Array, active: String, callback: Callable) -> void:
 var row=menu_nav;row.show()
 for index in ids.size():
  var item=button(labels[index],func():callback.call(ids[index]),false,"",row);item.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  selected_style(item,active==ids[index])
func text(message: String,size: int=18) -> Label:
 var item=Label.new()
 item.text=message
 item.custom_minimum_size=Vector2(390,32)
 item.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 item.add_theme_color_override("font_color",Color("253b35"))
 item.add_theme_font_size_override("font_size",size)
 box.add_child(item)
 return item
func button(message: String, callback: Callable, disabled: bool=false, item_id: String="", parent: Container=null) -> Button:
 var item=Button.new()
 item.text=message
 item.custom_minimum_size=Vector2(250,48) if parent is GridContainer else Vector2(390,48)
 item.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 item.icon=icons.icon(item_id)
 item.add_theme_constant_override("icon_max_width",40);item.expand_icon=true
 item.add_theme_constant_override("h_separation",14)
 item.tooltip_text=message
 item.set_meta("item_id",item_id)
 item.alignment=HORIZONTAL_ALIGNMENT_LEFT
 item.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 item.disabled=disabled
 item.pressed.connect(callback)
 if parent is HBoxContainer:
  item.size_flags_horizontal=Control.SIZE_EXPAND_FILL;item.custom_minimum_size=Vector2(140,46)
 if parent==null:box.add_child(item)
 else:parent.add_child(item)
 if parent==null and box.get_child_count()==1 and not disabled:call_deferred("focus_button",item)
 return item
func show_talent_preview(t: Dictionary) -> void:
 state="preview"
 show_panel("演示 · "+t.name,t.description+"\n"+preload("res://scripts/build_modifier.gd").description(hero_id,t.id))
 text("演示继承当前兵器、进化、修行与神通；下方显示触发场景和选择前后实际数值。经济、拾取及未覆盖的条件需在训练场验证。",15)
 var demo=load("res://scripts/preview.gd").new()
 demo.custom_minimum_size=Vector2(748,220)
 demo.mouse_filter=Control.MOUSE_FILTER_IGNORE
 demo.configure(db,fight.hero,fight.weapon,t,fight,skill_ids,branches)
 box.add_child(demo)
 button("返回候选",talent_panel)
func focus_button(item: Button) -> void:
 if is_instance_valid(item) and item.is_inside_tree():item.grab_focus()
func notify(message: String) -> void:
 toast.text=message
 toast_state=state
 toast_time=3
func home() -> void:
 clear_reward_stage()
 cinematic.skip();cinematic_input_guard=false;reset_inputs()
 state="home";panel.hide();battle_hud.hide();homepage.show()
 homepage.present(not checkpoint.is_empty(),int(meta.merit),meta.unlocked.size())
 queue_redraw()
func repair_meta() -> void:
 var completed: Array=[]
 for value in meta.get("completed",[]):
  if (value is int or value is float) and int(value)>=0 and int(value)<37 and int(value) not in completed:completed.append(int(value))
 meta.completed=completed
 if not meta.has("weapon_unlocks"):
  meta.weapon_unlocks=[]
  for h in db.tables.heroes:
   for i in 2:meta.weapon_unlocks.append(h.id+"_w"+str(i))
 if not meta.has("talent_unlocks"):meta.talent_unlocks=[]
 for t in db.tables.talents:
  if t.category!="core" and t.id not in meta.talent_unlocks:meta.talent_unlocks.append(t.id)
 if not meta.has("import_merit_highwater"):meta.import_merit_highwater=meta.merit if not meta.imports.is_empty() else 0
 for id in checkpoint.get("weapons",[]):
  if not db.find("weapons",id).is_empty() and id not in meta.weapon_unlocks:meta.weapon_unlocks.append(id)
 for id in checkpoint.get("combat",{}).get("owned",{}):
  if not db.find("talents",id).is_empty() and id not in meta.talent_unlocks:meta.talent_unlocks.append(id)
func merit_shop() -> void:
 state="merit"
 show_panel("功德阁","功德 %d · 解锁永久保留，不增加基础攻防。训练场可免费试用全部内容。"%meta.merit)
 for w in db.tables.weapons:
  if w.hero not in meta.unlocked or w.id in meta.weapon_unlocks:continue
  button(w.name+" · 解锁10功德
"+w.description,func():unlock_content("weapon",w.id),meta.merit<10)
 for t in db.tables.talents:
  if t.category!="core" or t.id in meta.talent_unlocks:continue
  button(t.name+" · 加入天赋池20功德
"+t.description,func():unlock_content("talent",t.id),meta.merit<20)
 button("返回主页",home)
func unlock_content(category: String,id: String) -> void:
 var table: String="weapons" if category=="weapon" else "talents"
 var ledger: String="weapon_unlocks" if category=="weapon" else "talent_unlocks"
 var cost: int=10 if category=="weapon" else 20
 if db.find(table,id).is_empty() or id in meta[ledger] or meta.merit<cost:return
 meta.merit-=cost;meta[ledger].append(id)
 storage.write({"meta":meta,"settings":settings,"run":checkpoint})
 merit_shop()
func loadout() -> void:
 if mode!="training":
  if hero_id not in meta.unlocked:select_hero(meta.unlocked[0]);return
  for i in 2:
   if weapon_ids[i] not in meta.weapon_unlocks:
    for w in db.for_hero("weapons",hero_id):
     if w.id in meta.weapon_unlocks and w.id!=weapon_ids[1-i]:weapon_ids[i]=w.id;break
 state="loadout"
 show_panel("择一人，走西行路","选择角色与装备；页签切换保留当前选择。")
 text(db.find("heroes",hero_id).name+" · 主："+db.find("weapons",weapon_ids[0]).name+" / 副："+db.find("weapons",weapon_ids[1]).name,16)
 navigation(["hero","weapon","skill","ultimate"],["角色","兵器","神通","绝技"],loadout_tab,func(tab):loadout_tab=tab;loadout())
 var grid=menu_grid(2)
 match loadout_tab:
  "hero":
   for h in db.tables.heroes:
    var locked: bool=h.id not in meta.unlocked and mode!="training"
    var item=button(("未解锁 · " if locked else "已选 · " if h.id==hero_id else "")+h.name+"\n"+h.resource+" · "+h.get("resource_rule",""),func():select_hero(h.id),locked,"ui_resource",grid)
    item.custom_minimum_size=Vector2(390,94);selected_style(item,h.id==hero_id)
  "weapon":
   for w in db.for_hero("weapons",hero_id):
    var locked: bool=mode!="training" and w.id not in meta.weapon_unlocks
    var item=button(("10功德解锁 · " if locked else "主武器 · " if w.id==weapon_ids[0] else "副武器 · " if w.id==weapon_ids[1] else "")+w.name+"\n"+w.description,func():weapon_ids=[w.id,weapon_ids[0]] if w.id!=weapon_ids[0] else weapon_ids;loadout(),locked,w.id,grid)
    item.custom_minimum_size=Vector2(390,108);selected_style(item,w.id in weapon_ids)
  "skill":
   for definition in db.for_hero("skills",hero_id):
    var slot_label: String="前槽 · " if definition.id==skill_ids[0] else "后槽 · " if definition.id==skill_ids[1] else ""
    var item=button(slot_label+definition.name+"\n"+definition.description+"\n消耗%d · 冷却%.1f秒"%[definition.cost,definition.cooldown],func():skill_ids=[definition.id,skill_ids[0]] if definition.id not in skill_ids else skill_ids;loadout(),false,definition.id,grid)
    item.custom_minimum_size=Vector2(390,108);selected_style(item,definition.id in skill_ids)
  "ultimate":
   for definition in db.for_hero("ultimates",hero_id):
    var item=button(("已选 · " if definition.id==ultimate_id else "")+definition.name+"\n"+definition.description,func():ultimate_id=definition.id;loadout(),false,definition.id,grid)
    item.custom_minimum_size=Vector2(390,118);selected_style(item,definition.id==ultimate_id)
 button("返回主页",home,false,"",footer)
 var start=button("启程 · "+("训练场" if mode=="training" else "章节战役" if mode=="campaign" else "三域挑战"),start_run,false,"ui_weapon",footer);start.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 call_deferred("focus_button",start)
func select_hero(id: String) -> void:
 hero_id=id
 weapon_ids=[id+"_w0",id+"_w1"]
 skill_ids=[id+"_s0",id+"_s2"]
 ultimate_id=id+"_u0"
 loadout()
func start_run(seed_value: int=0) -> void:
 camera_initialized=false
 if mode!="training" and (hero_id not in meta.unlocked or not weapon_ids.all(func(id):return id in meta.weapon_unlocks)):
  notify("角色或起始兵器尚未解锁")
  loadout();return
 if seed_value==0:rng.randomize()
 else:rng.seed=seed_value
 run_statistics.reset()
 run_id=str(Time.get_unix_time_from_system())+"-"+str(rng.randi())
 fight.rng.seed=rng.randi()
 fight.reset(db.find("heroes",hero_id),db.find("weapons",weapon_ids[0]))
 preload("res://scripts/journey_balance.gd").activate(fight)
 sync_sources()
 route=[]
 if mode=="campaign":
  for i in 37:route.append(i)
 else:route=[rng.randi_range(0,9),rng.randi_range(10,23),rng.randi_range(24,36)]
 route_index=0
 chapter=int(route[0])
 step=0
 visited=[]
 offers=[]
 banned=[]
 rerolls=2
 bans=1
 slot=0
 run_time=0
 event_seen=[]
 branches=[0,0]
 relic_ids=["relic_0","relic_6"]
 if mode=="training":
  kind="training"
  fight.configure_arena(Vector2(2400,1400))
  fight.create_layout("training","forest")
  state="playing"
  panel.hide()
  for i in 6:fight.spawn("dummy",fight.player.pos+Vector2(80+i*75,-70),0)
 else:new_route()
func start_demo() -> void:
 mode="training";hero_id="wukong"
 weapon_ids=["wukong_w0","wukong_w1"];skill_ids=["wukong_s0","wukong_s2"];ultimate_id="wukong_u0"
 start_run();training_lab()
func role_demo(hero: String, build_index: int=-1) -> void:
 clear_reward_stage()
 camera_initialized=false
 training_build_name="基础招式" if build_index<0 else preload("res://scripts/build_modifier.gd").BUILDS[hero][build_index][0]
 if mode!="training":return
 hero_id=hero;weapon_ids=[hero+"_w0",hero+"_w1"];slot=0
 skill_ids=[hero+"_s0",hero+"_s2"];ultimate_id=hero+"_u0";branches=[0,0]
 if build_index==1:
  skill_ids=[hero+"_s1",hero+"_s4"]
  if hero=="wukong":skill_ids=[hero+"_s0",hero+"_s4"]
  if hero=="shaseng":skill_ids=[hero+"_s0",hero+"_s3"]
  if hero in ["shaseng","bailongma"]:slot=1
 elif build_index==2:skill_ids=[hero+"_s3",hero+"_s5"];ultimate_id=hero+"_u1"
 fight.reset(db.find("heroes",hero),db.find("weapons",weapon_ids[slot]));sync_sources()
 fight.configure_arena(Vector2(2400,1400));fight.create_layout("training","forest")
 if build_index==0 and hero=="shaseng":skill_ids=[hero+"_s1",hero+"_s5"];sync_sources()
 if build_index>=0:
  for id in preload("res://scripts/build_modifier.gd").BUILDS[hero][build_index][1]:
   if not fight.take(id):push_error("无效构筑候选："+hero+" / "+id)
 fight.player.resource=100;lock_uid=-1;reset_inputs();demo_dummies()
func role_lab() -> void:
 state="lab";reset_inputs()
 show_panel("五行试招 · 五角色重做","每人六兵器、七神通、三绝技、三种构筑。基础试招不携带修行。")
 navigation(db.tables.heroes.map(func(h):return h.id),db.tables.heroes.map(func(h):return h.name),role_lab_hero,func(id):role_lab_hero=id;role_lab())
 var hero: Dictionary=db.find("heroes",role_lab_hero)
 var kit=preload("res://scripts/character_combat_kit.gd").for_hero(hero.id)
 text(kit.resource_rule,16)
 var cards=menu_grid(2)
 button(hero.name+" · 基础招式\n不携带修行，对比原始动作与资源循环",func():role_demo(hero.id),false,"ui_weapon",cards).custom_minimum_size=Vector2(390,106)
 for index in 3:
  var build: Array=preload("res://scripts/build_modifier.gd").BUILDS[hero.id][index]
  button(build[0]+"\n"+build[2]+"\n取舍："+build[3],func():role_demo(hero.id,index),false,"ui_talent",cards).custom_minimum_size=Vector2(390,106)
 button("返回试招台",training_lab,false,"",footer)
func training_lab() -> void:
 if mode!="training":return
 state="lab"
 show_panel("战斗演示 · 试招台","先选构筑，再选对手；免费试用，不修改正式战局。Tab返回试招台。")
 button("五角色 · 基础招式与15种构筑",func():role_lab_hero=hero_id;role_lab()).custom_minimum_size=Vector2(390,48)
 text("当前 · "+fight.weapon.name+" · %d项修行"%fight.owned.size(),16)
 text("招式阶段：起手不可闪避取消；有效命中后可取消收招。重击按住蓄力，松开释放。",15)
 var skill_row=menu_grid(3)
 for index in 2:
  var chooser=OptionButton.new();chooser.custom_minimum_size=Vector2(250,42)
  var entries: Array=db.for_hero("skills",hero_id)
  for entry in entries:chooser.add_item(entry.name+" · 消耗"+str(entry.cost))
  for i in entries.size():
   if entries[i].id==skill_ids[index]:chooser.select(i)
  skill_row.add_child(chooser)
  chooser.item_selected.connect(func(i):skill_ids[index]=entries[i].id;sync_sources();training_lab())
 var ult=OptionButton.new();ult.custom_minimum_size=Vector2(250,42)
 var ults: Array=db.for_hero("ultimates",hero_id)
 for entry in ults:ult.add_item(entry.name)
 for i in ults.size():
  if ults[i].id==ultimate_id:ult.select(i)
 skill_row.add_child(ult)
 ult.item_selected.connect(func(i):ultimate_id=ults[i].id;sync_sources();training_lab())
 var quick=menu_grid(2)
 button("快速试打 · 红孩儿第三阶段",func():demo_boss("红孩儿",3),false,"ui_skill",quick)
 button("自由构筑 · 查看天赋与进化",func():build_panel(),false,"ui_talent",quick)
 text("一键构筑 · 切换会重置训练现场",17)
 var presets=menu_grid(2)
 for index in 3:
  var build: Array=preload("res://scripts/build_modifier.gd").BUILDS[hero_id][index]
  button(build[0]+"\n"+build[2],func():role_demo(hero_id,index);training_lab(),false,"ui_talent",presets).custom_minimum_size=Vector2(390,88)
 var opponents=menu_grid(2)
 button("随机妖群 · 六职责与精英词缀",demo_squad,false,"ui_skill",opponents)
 button("妖王试招 · 26首领与三阶段",demo_boss_panel,false,"ui_relic",opponents)
 button("木桩试招 · 对比攻击方式",demo_dummies,false,"ui_weapon",opponents)
 button("返回主页",home,false,"",footer)
 button("继续试招",func():state="playing";panel.hide(),false,"ui_dash",footer)
func demo_build(index: int) -> void:
 if mode!="training" or index not in [0,1,2,3,4]:return
 hero_id="wukong";skill_ids=["wukong_s0","wukong_s2"];ultimate_id="wukong_u0"
 var presets: Array=[["echo","frost","frost_break"],["return","fan","split","chain"],["burn","domain","shield","shield_burst"],["lotus_steps","third_crescent","seal_wheel"],["echo","frost","frost_break"]]
 if index==4:relic_ids=["relic_0","relic_14"];relic_slot=0
 slot=0;weapon_ids=["wukong_w"+str(0 if index==4 else index%3),"wukong_w"+str((index+1)%3)]
 if index==1:weapon_ids[1]="wukong_w0"
 fight.reset(db.find("heroes",hero_id),db.find("weapons",weapon_ids[0]));sync_sources()
 fight.configure_arena(Vector2(2400,1400));fight.create_layout("training","forest")
 for id in presets[index]:fight.take(id)
 fight.player.resource=100;lock_uid=-1;reset_inputs()
func reset_inputs() -> void:
 charging=false;charge=0;input_attack=0;input_dash=0;hitstop=0;heavy_buffer=0;afterimages=[];pending_command={};input_release_guard=true
func demo_dummies() -> void:
 if mode!="training":return
 fight.clear_room();fight.player.pos=fight.arena_bounds().get_center();lock_uid=-1;reset_inputs()
 for i in 6:fight.spawn("dummy",fight.player.pos+Vector2(150+i%3*90,-80+floori(i/3.0)*150),0)
 state="playing";panel.hide()
func demo_squad() -> void:
 if mode!="training":return
 fight.clear_room();fight.player.pos=fight.arena_bounds().get_center();lock_uid=-1;reset_inputs()
 var roles: Array=["chaser","ranged","charge","guard","summoner","elite"]
 roles.shuffle()
 for i in 8:fight.spawn(roles[i%roles.size()],fight.clamp_actor(fight.player.pos+Vector2.RIGHT.rotated(i*TAU/8)*330),0)
 fight.player.hp=fight.player.max_hp;fight.player.resource=100
 state="playing";panel.hide();notify("随机妖群：先看红色预警，再闪避反击；Tab返回试招台")
func restore_demo() -> void:
 fight.player.hp=fight.player.max_hp;fight.player.resource=100
 fight.player.poison=0;fight.player.burn=0;fight.player.slow=0;fight.invuln=1.2
 reset_inputs();state="playing";panel.hide()
func demo_failure() -> void:
 state="lab";reset_inputs()
 show_panel("试招暂歇","败于："+str(fight.player.last_hit)+"。观察预警与破势时机后再试一次。")
 button("恢复生命 · 继续当前试招",restore_demo)
 button("重选对手与构筑",func():restore_demo();training_lab())
 button("返回主页",home)
func demo_boss_panel() -> void:
 if mode!="training":return
 state="lab"
 show_panel("妖王试招","选择首领与起始阶段；破势打断蓄招，收招窗口增加15%伤害。")
 var selector=OptionButton.new();selector.custom_minimum_size.y=46;selector.get_popup().max_size=Vector2i(0,440)
 var profiles: Array=db.tables.bosses
 for profile in profiles:selector.add_item(profile.name)
 var selected: int=0
 for index in profiles.size():
  if profiles[index].name==demo_boss_name:selected=index
 selector.select(selected);box.add_child(selector)
 selector.item_selected.connect(func(index):demo_boss_name=profiles[index].name;demo_boss_panel())
 text(profiles[selected].get("opening","观察蓄招，避开红色预警，在收招时反击"),18)
 var grid=menu_grid(3)
 for phase in [1,2,3]:button("第%d阶段\n"%phase+["基础招式 · 熟悉预警","强化招式 · 招牌连招","狂势招式 · 更多弹道"][phase-1],func():demo_boss(demo_boss_name,phase),false,"ui_skill",grid).custom_minimum_size=Vector2(252,114)
 button("返回试招台",training_lab,false,"",footer)
func demo_boss(name: String, phase: int) -> void:
 if mode!="training" or phase not in [1,2,3] or not db.tables.bosses.any(func(profile):return profile.name==name):return
 fight.clear_room();fight.player.pos=fight.arena_bounds().get_center();lock_uid=-1;reset_inputs()
 fight.player.hp=fight.player.max_hp;fight.player.resource=100
 var enemy: Dictionary=fight.spawn("boss",fight.player.pos+Vector2(300,0),0,name)
 enemy.phase=phase;enemy.hp=enemy.max_hp*([1.0,.45,.2][phase-1]);enemy.transition=1.2;enemy.boss_cd=1.2
 state="playing";panel.hide();play_cinematic(name,"观察蓄势 · 躲避预警 · 收招反击",true);notify(name+" · 第%d阶段：观察蓄招、避开红圈、收招反击"%phase)
func sync_sources() -> void:
 fight.player.talent_budget=0 if mode=="training" else 12 if mode=="campaign" else 24
 fight.player.progress_tier=3 if mode=="training" else 1+mini(2,int(chapter/12)) if mode=="campaign" else 1+mini(2,route_index)
 db.unlocked_talents=[] if mode=="training" else meta.talent_unlocks
 fight.active_effects=[]
 for id in skill_ids:fight.active_effects.append(db.find("skills",id).get("effect",""))
 fight.active_effects.append(db.find("ultimates",ultimate_id).get("effect",""))
 fight.active_effects.append(db.find("relics",relic_ids[relic_slot]).get("effect",""))
 fight.passive_relic=db.find("relics",relic_ids[1-relic_slot]).get("effect","")
 if fight.passive_relic in ["pagoda","root","waterguard","shield"]:fight.active_effects.append(fight.passive_relic)
 fight.rebuild_effects()
func new_route() -> void:
 clear_reward_stage()
 fight.clear_room()
 step+=1
 room_id=str(route_index)+":"+str(step)
 bought=[]
 offers=[]
 options=preload("res://scripts/route_flow.gd").choices(step,NAMES.keys(),rng)
 route_panel()
 save_run()
func route_panel() -> void:
 state="route"
 var c: Dictionary=db.tables.chapters[chapter]
 show_panel("第 %d 章 · %s"%[chapter+1,c.place],"原著 %d—%d 难 · 路线 %d/6\n选择分支，其余路线关闭。高风险路线提供额外修为与铜钱。"%[c.firstTrial,c.lastTrial,step])
 if step==1:text(c.get("story",""),16)
 if step in [3,5]:text("险路必经：可选常规战斗，或承担额外风险获取更高奖励。",15)
 for type in options:
  button(NAMES[type]+" — "+("高风险 / 高奖励" if type in ["elite","trial","curse","secret"] else "首领战" if type=="boss" else "补给与选择" if type!="combat" else "常规战斗"),func():enter_room(type))
 button("查看构筑",func():build_panel("route"))
func clear_reward_stage() -> void:
 if is_instance_valid(reward_stage):reward_stage.queue_free()
 reward_stage=null
 if is_instance_valid(room_interact_button):room_interact_button.hide()
func enter_reward_stage(fresh: bool=true) -> void:
 clear_reward_stage()
 reward_stage=load("res://scenes/rewards/"+kind+".tscn").instantiate();add_child(reward_stage)
 reward_stage.z_index=-1
 reward_stage.environment=current_environment();reward_stage.biome=current_biome();reward_stage.place=db.tables.chapters[chapter].place;reward_stage.chapter_index=chapter
 reward_stage.configure(fight,font,fresh);camera_initialized=false
 state="service_walk";panel.hide();reset_inputs();update_camera(.2);reward_stage.position=camera_offset()
 notify(NAMES[kind]+" · 走近场景物件选择奖励，右侧出口继续赶路")
func enter_room(type: String,event_encounter: bool=false) -> void:
 if event_encounter:
  var effect: String=db.find("events",event_id).get("effect","")
  if state!="service" or kind!="event" or effect not in ["fight","trial","risk","secret"] or effect not in bought or type!=("trial" if effect=="trial" else "secret"):return
 elif room_id in visited or state!="route" or type not in options:return
 clear_reward_stage()
 kind=type
 fight.clear_room()
 fight.trial=""
 room_time=0
 spawn_cd=.1
 protection=100
 trial_index=-1
 boss_cursor=0
 fight.player.shield=minf(150,fight.player.shield+fight.value("shield")*(1+fight.value("hero_shield_gain")))
 if kind in ["combat","elite","boss","trial","secret"]:
  fight.configure_arena(Vector2(2400,1400))
  fight.create_layout(kind,db.tables.chapters[chapter].get("biome",""),chapter)
  for i in 5:
   fight.caches.append({"pos":fight.clamp_actor(fight.arena_origin+Vector2(500+i*350,rng.randf_range(300,1100)),45),"coins":rng.randi_range(6,12),"claimed":false})
  if fight.player.get("ally",false):fight.summons.append({"pos":fight.player.pos,"life":12.0,"cd":0.0,"damage":25});fight.player.ally=false
  remaining=10+mini(10,route_index*2+int(chapter/6))
  if preload("res://scripts/journey_balance.gd").enabled(fight):remaining=preload("res://scripts/journey_balance.gd").population(chapter,route_index,kind)
  if kind=="trial":
   trial_index=rng.randi_range(0,11)
   fight.trial=db.tables.trials[trial_index].rule
  if kind in ["elite","secret"]:fight.spawn("elite",fight.arena_bounds().get_center()+Vector2(-250,-100),chapter)
  if kind=="secret" and not preload("res://scripts/journey_balance.gd").enabled(fight):remaining+=6
  if fight.trial=="swarm":remaining+=8
  if fight.trial=="elite":
   fight.spawn("elite",fight.arena_bounds().get_center()+Vector2(100,-140),chapter)
   fight.spawn("elite",fight.arena_bounds().get_center()+Vector2(-300,180),chapter)
  if kind=="boss":
   remaining=0
   spawn_boss()
  state="playing"
  panel.hide()
  play_cinematic(db.tables.chapters[chapter].place,db.tables.chapters[chapter].get("story","步步修行，向西而行"),kind=="boss")
  notify(NAMES[kind]+(" · "+db.tables.trials[trial_index].name if trial_index>=0 else ""))
 else:
  if kind=="shop":
   var pool: Array=["heal","shield","talent","reroll","weapon","skill","relic","evolve"]
   while offers.size()<6 and not pool.is_empty():
    var index=rng.randi_range(0,pool.size()-1)
    var item: String=pool[index]
    pool.remove_at(index)
    if item=="heal" and fight.player.hp>=fight.player.max_hp:continue
    offers.append(item)
  if kind=="shrine":
   offers=["talent"]
   var blessings: Array=["shield","reroll","heal","purify","coins","relic","resource"]
   while offers.size()<3 and not blessings.is_empty():
    var index=rng.randi_range(0,blessings.size()-1)
    var item: String=blessings[index]
    blessings.remove_at(index)
    if item=="heal" and fight.player.hp>=fight.player.max_hp:continue
    if item=="purify" and fight.player.curse<=0 and fight.player.poison<=0 and fight.player.burn<=0:continue
    offers.append(item)
  if kind=="event":
   var unseen: Array=db.tables.events.filter(func(e):return e.id not in event_seen)
   if unseen.is_empty():event_seen=[];unseen=db.tables.events.duplicate()
   event_id=unseen[rng.randi_range(0,unseen.size()-1)].id
   event_seen.append(event_id)
  stock=offers.duplicate()
  enter_reward_stage()
  play_cinematic(NAMES[kind],"走近场景中的物件，选择所需的修行与补给")
 save_run()
func spawn_boss() -> void:
 var refs: Array=db.tables.chapters[chapter].bossRefs
 if refs.is_empty():
  fight.spawn("elite",fight.arena_bounds().get_center(),chapter)
  fight.spawn("summoner",fight.arena_bounds().get_center()+Vector2(180,-100),chapter)
 else:fight.spawn("boss",fight.arena_bounds().get_center()+Vector2(100,0),chapter,refs[boss_cursor].get("boss","护关妖王"))
func room_reward() -> void:
 if room_id in visited:return
 visited.append(room_id)
 fight.player.shield+=fight.value("reward_shield")
 if kind in ["elite","trial","secret"]:
  fight.player.coins+=12
  fight.player.xp+=30
 pending="chapter" if kind=="boss" else "clear"
 var reward_id=run_id+":"+room_id
 if reward_id not in meta.settled:
  meta.settled.append(reward_id)
  meta.merit+=20 if kind=="boss" else 5
 if kind=="boss":
  if chapter not in meta.completed:meta.completed.append(chapter)
  if meta.unlocked.size()<5:
   for h in db.tables.heroes:
    if h.id not in meta.unlocked:meta.unlocked.append(h.id);notify("解锁取经人："+h.name);break
 offers=[]
 if preload("res://scripts/combo_talents.gd").full(fight):
  fight.player.coins+=8;finish_choice();return
 talent_panel()
 save_run()
func talent_panel() -> void:
 sync_sources()
 state="talent"
 if preload("res://scripts/combo_talents.gd").full(fight):offers=[]
 elif offers.is_empty():offers=db.choices(hero_id,fight.tags(),fight.owned,banned,rng)
 var spent: int=preload("res://scripts/combo_talents.gd").points(fight)
 var limit: int=int(fight.player.get("talent_budget",0))
 show_panel("选择一项修行","修行点 %d / %s · 前中后段逐步开放新修行；本章结束后重新构筑。"%[spent,str(limit) if limit>0 else "不限（试炼）"])
 if offers.is_empty():text("当前构筑已达上限或无有效候选；可将本次奖励换为铜钱。",17)
 var grid=GridContainer.new();grid.columns=3;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 grid.add_theme_constant_override("h_separation",12);box.add_child(grid)
 for id in offers:
  var t: Dictionary=db.find("talents",id)
  var column=VBoxContainer.new();column.size_flags_horizontal=Control.SIZE_EXPAND_FILL;column.custom_minimum_size.x=244;grid.add_child(column)
  var category: String={"shape":"攻击形态","element":"元素状态","trigger":"触发联动","support":"生存经济","hero":"角色修行","core":"构筑核心"}.get(t.category,"修行")
  category+=" · "+preload("res://scripts/talent_selection.gd").intent(t,fight.owned)
  var choice=button("%s · %d/%d\n%s\n%s"%[t.name,int(fight.owned.get(id,0)),t.max_level,category,t.description],func():choose_talent(id),not fight.can_take(id),id,column)
  choice.custom_minimum_size.y=172
  button("观看攻击演示",func():show_talent_preview(t),false,t.id,column)
  if id==offers[0]:call_deferred("focus_button",choice)
 button("重抽 · %d次"%rerolls,reroll,rerolls<=0 or preload("res://scripts/combo_talents.gd").full(fight),"ui_talent",footer)
 button("禁止首项 · %d次"%bans,ban_first,bans<=0 or offers.is_empty(),"",footer)
 button("弃选 · %d铜钱"%int(8+fight.value("salvage")),func():fight.player.coins+=int(8+fight.value("salvage"));finish_choice(),false,"ui_coin",footer)
func choose_talent(id: String) -> void:
 if id not in offers or not fight.take(id):notify("该修行当前不可选");return
 notify("悟得："+db.find("talents",id).name)
 finish_choice()
func reroll() -> void:
 if rerolls<=0:return
 if preload("res://scripts/combo_talents.gd").full(fight):return
 rerolls-=1
 offers=db.choices(hero_id,fight.tags(),fight.owned,banned,rng)
 talent_panel()
 save_run()
func ban_first() -> void:
 if bans<=0 or offers.is_empty():return
 bans-=1
 banned.append(offers[0])
 offers=db.choices(hero_id,fight.tags(),fight.owned,banned,rng)
 talent_panel()
 save_run()
func finish_choice() -> void:
 offers=[]
 if pending=="level":
  pending=""
  state="playing"
  panel.hide()
  save_run()
  return
 if pending=="shop":
  pending=""
  services()
  save_run()
  return
 if pending=="chapter":
  if mode=="campaign":run_statistics.commit("chapter:%d"%route_index,fight)
  route_index+=1
  if route_index>=route.size():end_run(true);return
  chapter=int(route[route_index])
  step=0
  if mode=="campaign":
   var coins: int=fight.player.coins
   var balance_profile: String=fight.player.get("balance_profile","")
   fight.reset(db.find("heroes",hero_id),db.find("weapons",weapon_ids[0]))
   if balance_profile==preload("res://scripts/journey_balance.gd").PROFILE:preload("res://scripts/journey_balance.gd").activate(fight)
   fight.player.coins=coins
   slot=0
   rerolls=2
   bans=1
   banned=[]
 pending=""
 new_route()


func reason(item: String, cost: int) -> String:
 if kind=="event" and not bought.is_empty():return "本奇遇已作选择"
 if kind=="event":
  var ev: Dictionary=db.find("events",event_id)
  if item!="event_alternative" and fight.player.hp<=float(ev.get("hp_cost",0)):return "生命不足以支付代价"
  if item=="event_alternative":
   var alternative: String=ev.get("alternative","coins")
   if alternative=="heal" and fight.player.hp>=fight.player.max_hp:return "生命已满"
   if alternative=="heal" and fight.trial=="noheal":return "当前试炼禁止回复"
   if alternative=="resource" and fight.player.resource>=100:return "资源已满"
   if alternative=="shield" and fight.player.shield>=150:return "护盾已满"
   if alternative=="purify" and fight.player.curse<=0 and fight.player.poison<=0 and fight.player.burn<=0:return "没有异常"
 if item in bought:return "本房已选"
 if fight.player.coins<cost:return "铜钱不足"
 if item=="heal" and fight.player.hp>=fight.player.max_hp:return "生命已满"
 if item=="heal" and fight.trial=="noheal":return "当前试炼禁止回复"
 if item=="resource" and fight.player.resource>=100:return "资源已满"
 if item=="shield" and fight.player.shield>=150:return "护盾已满"
 if item in ["fight","trial","risk","secret"] and (state!="service" or kind!="event" or db.find("events",event_id).get("effect","")!=item):return "当前不能进入该战斗"
 if item=="purify" and fight.player.curse<=0 and fight.player.poison<=0 and fight.player.burn<=0:return "无异常需要净化"
 if item=="evolve" and fight.evolution()>0:return "已进化"
 if item in ["talent","curse"] and preload("res://scripts/combo_talents.gd").full(fight):return "本段修行点已满"
 if item in ["talent","curse"] and not db.tables.talents.any(func(t):return db.talent_allowed(t,hero_id,fight.tags(),fight.owned,banned)):return "没有有效修行"
 if item in ["damage","chain","echo","regen","discount","cooldown"] and not fight.can_take(item):return "满级或兵器不适用"
 return ""
func offer(item: String,title: String,cost: int) -> void:
 var why=reason(item,cost)
 button(title+" · "+str(cost)+"文"+("（"+why+"）" if why!="" else "")+"\n"+transaction_preview(item,cost),func():
  if item=="weapon":weapon_purchase_preview(cost)
  else:buy(item,cost),why!="","ui_"+{"heal":"health","shield":"relic","coins":"coin","evolve":"weapon","reroll":"talent"}.get(item,item))
func transaction_preview(item: String,cost: int) -> String:
 var action: String=item
 var alternative: bool=item=="event_alternative"
 if alternative:action=db.find("events",event_id).get("alternative","coins")
 var hp: float=fight.player.hp
 if kind=="event" and not alternative:hp-=float(db.find("events",event_id).get("hp_cost",0))
 var coin_reward: int=(8 if alternative else 25) if action=="coins" else 0
 var next_coins: int=int(fight.player.coins)-cost+coin_reward
 var summary: String="铜钱 %d→%d"%[fight.player.coins,next_coins]
 match action:
  "heal":
   var amount: float=10 if alternative else fight.player.max_hp*.3
   var restored: float=0 if fight.trial=="noheal" else amount*(1+fight.value("heal_power")+fight.value("hero_heal_gain"))
   summary+=" · 生命 %.0f→%.0f"%[fight.player.hp,minf(fight.player.max_hp,hp+restored)]
  "shield":summary+=" · 护盾 %.0f→%.0f（上限150）"%[fight.player.shield,minf(150,fight.player.shield+(12 if alternative else 25))]
  "resource":summary+=" · "+fight.hero.resource+" %.0f→%.0f"%[fight.player.resource,minf(100,fight.player.resource+(20 if alternative else 40))]
  "curse":
   summary+=" · 生命上限 %.0f→%.0f · 心魔+1"%[fight.player.max_hp,fight.player.max_hp*.85]
   hp=minf(hp,fight.player.max_hp*.85)
  "risk":hp=maxf(1,hp-15)
  "maxhp":summary+=" · 生命上限 %.0f→%.0f"%[fight.player.max_hp,fight.player.max_hp+12]
  "reroll":summary+=" · 重抽 %d→%d"%[rerolls,rerolls+1]
  "ban":summary+=" · 禁止次数 %d→%d"%[bans,bans+1]
  "skill":summary+=" · 可选择替换任一神通槽；该槽分支清零"
  "relic":summary+=" · 替换当前主动法宝；护持法宝保留"
  "evolve":summary+=" · 本兵器选择一个进化方向，当前局不可改选"
 if action!="heal" and hp!=fight.player.hp:summary+=" · 生命 %.0f→%.0f"%[fight.player.hp,hp]
 return summary
func weapon_purchase_preview(cost: int) -> void:
 state="service"
 show_panel("购兵前比较","尚未支付 · %d文。购得后替换副兵器；若当前使用主兵器，需要切换后才应用以下变化。"%cost)
 for candidate in db.for_hero("weapons",hero_id):
  if candidate.id not in weapon_ids:
   text(candidate.name+" · "+candidate.description+"\n"+weapon_change_preview(candidate.id),17)
 var why: String=reason("weapon",cost)
 button("支付%d文并选择兵器"%cost,func():buy("weapon",cost),why!="","ui_weapon",footer)
 button("返回货肆",services,false,"",footer)
func services() -> void:
 if state=="service_walk" and (not is_instance_valid(reward_stage) or not reward_stage.near()):return
 sync_sources()
 state="service"
 show_panel(NAMES[kind],"铜钱 %d · 生命 %d/%d · 护盾 %d"%[fight.player.coins,fight.player.hp,fight.player.max_hp,fight.player.shield])
 match kind:
  "shop":
   for item in stock:
    offer(item,{"heal":"干粮：回复30%生命","shield":"护经符：护盾+25","talent":"残卷：三选一修行","reroll":"灵签：重抽+1","weapon":"兵器：选择副武器","skill":"神通：替换或强化","relic":"法宝：替换当前槽","evolve":"淬锋：兵器进化","resource":"纳气香囊：资源+40"}.get(item,item),int({"heal":14,"shield":16,"talent":24,"reroll":12,"weapon":22,"skill":20,"relic":25,"evolve":30}.get(item,12)*(1-minf(.35,fight.value("discount")))))
  "rest":
   offer("heal","歇脚：回复30%生命",0)
   offer("purify","静心：清除异常与心魔",12)
  "shrine":
   for blessing in stock:
    offer(blessing,{"talent":"听土地讲经：三选一修行","shield":"祈福：护盾+25","reroll":"求灵签：重抽+1","heal":"受甘露：回复30%生命","purify":"净心：清除异常","coins":"收香火：铜钱+25","relic":"请法宝：三选一","resource":"纳地气：资源+40"}.get(blessing,blessing),int({"talent":0,"shield":10,"reroll":12,"heal":8,"purify":6,"coins":0,"relic":20,"resource":6}.get(blessing,0)))
  "reward":
   offer("relic","开启法宝匣：选择一件法宝",0)
   offer("talent","参悟残卷：选择一项修行",0)
  "curse":offer("curse","舍身求道：生命上限-15%，获得修行",0)
  "forge":
   offer("evolve","进化：选择当前兵器的互斥流派",25)
   offer("weapon","兵器：替换副武器",18)
   offer("skill","神通：替换或强化",18)
  "event":
   var ev: Dictionary=db.find("events",event_id)
   text(ev.name+" · "+ev.description)
   var action: String={"forge":"evolve"}.get(ev.effect,ev.effect)
   offer(action,{"heal":"饮泉：回复生命","evolve":"借炉：兵器进化","coins":"结善缘：铜钱+25","fight":"开封匣：额外战斗胜后奖励","talent":"读残卷：选择修行","maxhp":"采灵药：生命上限+12","damage":"习武：攻击增加12%","reroll":"求灵签：重抽+1","shield":"井中宝光：护盾+25","curse":"妖契：降低生命上限换修行","discount":"助商队：商店折扣","trial":"修断桥：接受随机试炼","purify":"清心：清除异常","resource":"参碑：恢复资源","relic":"寻宝：选择法宝","risk":"冒险：伤害换奖励战斗","regen":"莲池：持续回复","ban":"辨伪：禁止次数+1","summon":"灵兽：获得协战","chain":"雷坛：悟得雷链","cooldown":"暮鼓：降低冷却","echo":"墨画：延迟棍影","secret":"秘境：额外精英战"}.get(action,action),int(ev.cost))
   offer("event_alternative","另择机缘："+{"shield":"护盾+12","reroll":"重抽+1","coins":"铜钱+8","heal":"回复10生命","resource":"资源+20","purify":"清除异常"}.get(ev.get("alternative","coins"),"小额铜钱"),0)
 button("整理构筑",func():build_panel("service"))
 button("返回场景",func():enter_reward_stage(false);save_run())
 button("离开此房",func():
  if room_id not in visited:visited.append(room_id)
  new_route())
func buy(item: String,cost: int) -> void:
 var why=reason(item,cost)
 if why!="":notify(why);return
 fight.player.coins-=cost
 if kind=="event" and item!="event_alternative":fight.player.hp-=float(db.find("events",event_id).get("hp_cost",0))
 bought.append(item)
 match item:
  "event_alternative":
   match db.find("events",event_id).get("alternative","coins"):
    "shield":fight.player.shield=minf(150,fight.player.shield+12)
    "reroll":rerolls+=1
    "coins":fight.player.coins+=8
    "heal":fight.heal(10)
    "resource":fight.resource(20)
    "purify":fight.player.poison=0;fight.player.burn=0;fight.player.curse=0
  "heal":fight.heal(fight.player.max_hp*.3)
  "shield":fight.player.shield=minf(150,fight.player.shield+25)
  "purify":fight.player.poison=0;fight.player.burn=0;fight.player.curse=0
  "reroll":rerolls+=1
  "ban":bans+=1
  "coins":fight.player.coins+=25
  "resource":fight.resource(40)
  "maxhp":fight.player.max_hp+=12;fight.heal(12)
  "damage","chain","echo","regen","discount","cooldown":fight.take(item)
  "summon":fight.player.ally=true;notify("下一战获得灵兽协战")
  "talent","curse":
   if item=="curse":fight.player.max_hp*=.85;fight.player.hp=minf(fight.player.hp,fight.player.max_hp);fight.player.curse+=1
   offers=[]
   pending="shop"
   talent_panel()
   save_run()
   return
  "relic","weapon","skill","evolve":
   selection_kind=item
   selection_items=[]
   if item=="relic":
    var pool: Array=db.tables.relics.filter(func(r):return r.id not in relic_ids)
    for i in 3:
     var index=rng.randi_range(0,pool.size()-1)
     selection_items.append(pool[index].id)
     pool.remove_at(index)
   elif item=="weapon":
    for w in db.for_hero("weapons",hero_id):
     if w.id not in weapon_ids:selection_items.append(w.id)
   elif item=="skill":
    for ability in db.for_hero("skills",hero_id):
     if ability.id not in skill_ids:selection_items.append(ability.id)
    for target_slot in 2:
     for branch in [1,2]:
      if branches[target_slot]!=branch:selection_items.append("branch_%d_%d"%[target_slot,branch])
   else:selection_items=["evolve_1","evolve_2"]
   selection_panel()
   save_run()
   return
  "fight","trial","risk","secret":
   if item=="risk":fight.player.hp=maxf(1,fight.player.hp-15)
   enter_room("trial" if item=="trial" else "secret",true)
   return
 notify("选择已生效")
 services()
 save_run()
func selection_panel() -> void:
 state="select"
 show_panel("选择 · "+{"relic":"法宝","weapon":"副兵器","skill":"神通","evolve":"兵器进化"}.get(selection_kind,selection_kind),"交易已支付；候选随存档保留，选定后生效。")
 for id in selection_items:
  var title: String=id
  if id.begins_with("branch_"):
   var parts: PackedStringArray=id.split("_")
   var target_slot: int=int(parts[1]) if parts.size()==3 else 0
   title=db.find("skills",skill_ids[target_slot]).name+" · "+db.find("skills",skill_ids[target_slot]).branches[int(id.right(1))-1]
  elif id.begins_with("evolve_"):title=fight.weapon.evolutions[int(id.right(1))-1]
  else:
   var item: Dictionary=db.find({"relic":"relics","weapon":"weapons","skill":"skills"}.get(selection_kind,"weapons"),id)
   title=item.name+" — "+item.description
   if selection_kind=="relic":title+="\n护持职能："+item.passive_description
   if selection_kind=="weapon":title+="\n"+weapon_change_preview(id)
  if selection_kind=="skill" and not id.begins_with("branch_"):
   text(title,17)
   for target_slot in 2:button("替换"+db.find("skills",skill_ids[target_slot]).name,func():commit_selection(id,target_slot),false,id)
  else:button(title,func():commit_selection(id),false,id)
func weapon_change_preview(id: String) -> String:
 var comparison=Combat.new(db)
 comparison.reset(fight.hero,db.find("weapons",id));comparison.restore(fight.snapshot().duplicate(true));comparison.active_effects=fight.active_effects.duplicate();comparison.weapon=db.find("weapons",id)
 var dormant: Array[String]=[]
 for talent_id in fight.owned:
  if fight.owns(talent_id) and not comparison.owns(talent_id):dormant.append(db.find("talents",talent_id).name)
 return "装备后暂失效："+"、".join(dormant) if not dormant.is_empty() else "当前有效修行均可继续生效"
func commit_selection(id: String,target_slot: int=0) -> void:
 if id not in selection_items:return
 if target_slot not in [0,1]:return
 if selection_kind=="relic":relic_ids[relic_slot]=id
 elif selection_kind=="weapon":
  weapon_ids[1]=id
  if slot==1:fight.weapon=db.find("weapons",id)
 elif selection_kind=="skill":
  if id.begins_with("branch_"):
   var parts: PackedStringArray=id.split("_")
   if parts.size()==3:target_slot=int(parts[1])
   if target_slot not in [0,1]:return
   branches[target_slot]=int(id.right(1))
  else:skill_ids[target_slot]=id;branches[target_slot]=0
 elif selection_kind=="evolve":fight.evolve(int(id.right(1)))
 selection_items=[]
 selection_kind=""
 services()
 save_run()
func build_panel(back: String="playing") -> void:
 sync_sources();state="build";build_return=back
 show_panel("本局修行录",fight.hero.name+" · "+fight.weapon.name+" · %d项修行"%fight.owned.size())
 var tabs: Array=["overview","talents","relics"];var labels: Array=["战斗概览","已选天赋","法宝袋"]
 if mode=="training":tabs.append("training");labels.append("训练目录")
 if build_tab not in tabs:build_tab="overview"
 navigation(tabs,labels,build_tab,func(tab):build_tab=tab;build_panel(back))
 match build_tab:
  "overview":
   text("当前兵器 · "+fight.weapon.description,18)
   if fight.evolution()>0:text("已选进化 · "+fight.weapon.evolutions[fight.evolution()-1],16)
   text("普通增伤倍率最多3.0，暴击倍率最多2.4；修行点包含升级等级。",15)
   text("普攻间隔 %.2f秒 · 附加穿透 %d · 雷链 %d · 天赋扇射 %d发"%[fight.attack_interval(),int(fight.value("pierce")),int(fight.value("chain")+fight.value("chain_count")),1+int(fight.value("fan"))],16)
   text("护盾 %d · 闪避 %d/2 · 已击败 %d妖"%[fight.player.shield,fight.dash_stock,fight.deaths],16)
   var support: Dictionary=db.find("relics",relic_ids[1-relic_slot])
   text("护持共鸣 · "+support.name+"："+support.passive_description,16)
   text("御器出手后按"+action_key("recall")+"召回；实际回到身边才蓄势，两秒内下一次近战攻击最多增强30%。",16)
   text("换兵器后，不适用的天赋保留，但暂停生效。已选天赋页会标明状态。",16)
   var alternative: Dictionary=db.find("weapons",weapon_ids[1-slot])
   var comparison=preload("res://scripts/combat.gd").new(db)
   comparison.reset(fight.hero,alternative);comparison.active_effects=fight.active_effects.duplicate();comparison.owned=fight.owned.duplicate();comparison.rebuild_effects()
   var suspended: Array=[]
   for id in fight.owned:
    if not comparison.talent_active(db.find("talents",id)):suspended.append(db.find("talents",id).name)
   text("切换预览 · "+alternative.name+"\n"+alternative.description+"\n暂停生效："+("无" if suspended.is_empty() else "、".join(suspended)),16)
  "talents":
   if fight.owned.is_empty():text("尚未获得天赋。战斗升级后可三选一，训练场可在目录免费试用。",18)
   var grid=menu_grid(2)
   for id in fight.owned:
    var t: Dictionary=db.find("talents",id)
    button(("生效 · " if fight.talent_active(t) else "暂停生效 · ")+t.name+" +"+str(fight.owned[id])+"\n"+t.description,func():notify(t.description),false,id,grid).custom_minimum_size=Vector2(390,96)
  "relics":
   text("当前法宝以F主动释放，另一件以护持槽自动触发。点击互换职能，共鸣有独立冷却，切换不会刷新。",16)
   var grid=menu_grid(2)
   for index in relic_ids.size():
    var r: Dictionary=db.find("relics",relic_ids[index])
    var item=button(("主动槽 · " if index==relic_slot else "护持槽 · ")+r.name+"\n"+(r.description+" · F释放 · 冷却%.0f秒"%r.cooldown if index==relic_slot else fight.synergy.DESCRIPTIONS.get(r.effect,"")),func():relic_slot=index;build_panel(back),false,r.id,grid)
    item.custom_minimum_size=Vector2(390,118);selected_style(item,index==relic_slot)
  "training":training_catalog(back)
 if mode=="training":button("试招台",training_lab,false,"ui_skill",footer)
 button("返回战局" if back=="playing" else "返回路线" if back=="route" else "返回房间",func():
  if back=="route":route_panel()
  elif back=="service":services()
  else:state="playing";panel.hide(),false,"",footer)
func training_catalog(back: String) -> void:
 var weapon_selector=OptionButton.new();weapon_selector.custom_minimum_size.y=44
 var weapons: Array=db.for_hero("weapons",hero_id)
 for index in weapons.size():
  weapon_selector.add_item("试用兵器 · "+weapons[index].name)
  if weapons[index].id==fight.weapon.id:weapon_selector.select(index)
 weapon_selector.item_selected.connect(func(index):weapon_ids[slot]=weapons[index].id;fight.weapon=weapons[index];sync_sources();build_panel(back));box.add_child(weapon_selector)
 var row=HBoxContainer.new();box.add_child(row)
 button("恢复生命与冷却",restore_training,false,"ui_health",row)
 button("恢复兵器原形",func():fight.evolutions.erase(fight.weapon.id);build_panel(back),false,"ui_weapon",row)
 for branch in [1,2]:button("试用进化%d"%branch,func():fight.evolutions.erase(fight.weapon.id);fight.evolve(branch);build_panel(back),false,"",row)
 var categories: Array=["全部","shape","element","trigger","support","hero","core"]
 var filters=HBoxContainer.new();box.add_child(filters)
 var selector=OptionButton.new();selector.custom_minimum_size=Vector2(170,44)
 for category in categories:selector.add_item({"shape":"攻击形态","element":"元素状态","trigger":"触发联动","support":"生存经济","hero":"角色修行","core":"构筑核心"}.get(category,category))
 selector.select(maxi(0,categories.find(training_category)));selector.item_selected.connect(func(index):training_category=categories[index];build_panel(back));filters.add_child(selector)
 var search=LineEdit.new();search.name="TalentSearch";search.placeholder_text="搜索天赋名称或机制";search.text=talent_search;search.size_flags_horizontal=Control.SIZE_EXPAND_FILL;filters.add_child(search)
 var grid=menu_grid(2)
 for t in db.tables.talents:
  if training_category!="全部" and t.category!=training_category:continue
  var available: bool=fight.can_take(t.id)
  var label: String="可选" if available else "已满级" if int(fight.owned.get(t.id,0))>=t.max_level else "条件未满足"
  var item=button(label+" · "+t.name+"\n"+t.description,func():fight.take(t.id);build_panel(back),not available,t.id,grid)
  item.custom_minimum_size=Vector2(390,92);item.set_meta("search",t.name+" "+t.description)
  item.visible=talent_search=="" or str(item.get_meta("search")).containsn(talent_search)
 var results=text("搜索结果：%d项"%grid.get_children().filter(func(item):return item.visible).size(),15)
 search.text_changed.connect(func(value):
  talent_search=value
  for item in grid.get_children():item.visible=value=="" or str(item.get_meta("search")).containsn(value)
  var count: int=grid.get_children().filter(func(item):return item.visible).size()
  results.text="搜索结果：%d项"%count if count>0 else "没有匹配的天赋，可清空搜索或切换分类。")
func restore_training() -> void:
 fight.player.hp=fight.player.max_hp;fight.player.resource=100;fight.player.poison=0;fight.player.burn=0
 fight.skill_cd=[0.0,0.0];fight.dash_stock=2;fight.relic_cd=0;notify("生命、资源与冷却已恢复")
func show_settings() -> void:
 if state!="settings":settings_return=state
 state="settings"
 show_panel("设置与操作","修改即时生效。降低特效或关闭震屏，不影响战斗判定。")
 navigation(["display","audio","controls"],["画面与反馈","声音","按键与手柄"],settings_tab,func(tab):settings_tab=tab;show_settings())
 match settings_tab:
  "display":
   var grid=menu_grid(2)
   for key in ["effects","shake","hold_attack","reduced_flash","numbers","fullbody_walk"]:
    button({"effects":"技能特效","shake":"镜头震动","hold_attack":"长按连续普攻","reduced_flash":"降低闪光","numbers":"伤害数字","fullbody_walk":"全身行走素材"}[key]+" · "+("开启" if settings.get(key,true) else "关闭"),func():settings[key]=not settings.get(key,true);show_settings();save_run(),false,"ui_skill",grid)
   button("窗口 / 全屏切换",func():DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN))
   text("震屏强度",16)
   var intensity=HSlider.new();intensity.max_value=1;intensity.step=.05;intensity.value=settings.get("shake_strength",.5);box.add_child(intensity)
   intensity.value_changed.connect(func(value):settings.shake_strength=value;save_run())
  "audio":
   button("战斗音效 · "+("开启" if settings.sfx else "关闭"),func():settings.sfx=not settings.sfx;show_settings();save_run())
   button("西行配乐 · "+("开启" if settings.get("music",true) else "关闭"),func():settings.music=not settings.get("music",true);show_settings();save_run())
   text("总音量",16)
   var volume:=HSlider.new();volume.min_value=0;volume.max_value=1;volume.step=.05;volume.value=float(settings.get("volume",.65));volume.custom_minimum_size=Vector2(300,38);box.add_child(volume)
   volume.value_changed.connect(func(value):settings.volume=value;save_run())
   for group in ["sfx_volume","music_volume"]:
    text("音效音量" if group=="sfx_volume" else "配乐音量",16)
    var level=HSlider.new();level.max_value=1;level.step=.05;level.value=settings.get(group,1.0);box.add_child(level)
    level.value_changed.connect(func(value):settings[group]=value;save_run())
  "controls":
   text("点击动作后，按键盘、鼠标或手柄按钮；Esc取消。",16)
   var grid=menu_grid(3)
   for action in ["left","right","up","down","attack","heavy","lock","dash","skill1","skill2","ultimate","relic","switch","recall","interact","map","pause"]:
    var title: String={"left":"左移","right":"右移","up":"上移","down":"下移","attack":"普攻","heavy":"蓄力重击","lock":"锁定","dash":"闪避","skill1":"神通一","skill2":"神通二","ultimate":"绝技","relic":"法宝","switch":"换兵器","recall":"御器召回","interact":"场景交互","map":"构筑","pause":"暂停"}.get(action,action)
    button(title+"\n当前 "+action_key(action),func():mapping=action;notify("按键盘、鼠标或手柄按钮；Esc取消"),false,"",grid).custom_minimum_size=Vector2(252,70)
 button("返回",return_from_settings,false,"",footer)
func return_from_settings() -> void:
 if settings_return in ["room_paused","service_walk","service"]:enter_reward_stage(false)
 elif settings_return=="paused":pause_panel()
 else:home()
func pause_panel() -> void:
 reset_inputs()
 state="paused";show_panel("暂停","进度已保存")
 button("继续",func():state="playing";panel.hide())
 button("查看构筑",func():build_panel())
 button("设置与声音",show_settings)
 button("保存并返回主页",func():save_run();home())
 save_run()
func show_import() -> void:
 state="import"
 show_panel("导入旧版进度","导入角色解锁、功德与章节记录；不导入战斗现场。重复导入不会重复加资源。")
 button("选择进度 JSON",func():
  var dialog=FileDialog.new()
  dialog.access=FileDialog.ACCESS_FILESYSTEM
  dialog.file_mode=FileDialog.FILE_MODE_OPEN_FILE
  dialog.filters=PackedStringArray(["*.json ; Progress"])
  dialog.use_native_dialog=true
  add_child(dialog)
  dialog.file_selected.connect(import_old)
  dialog.popup_centered_ratio(.7))
 button("返回",home)
func import_old(path: String) -> void:
 var raw_text=FileAccess.get_file_as_string(path)
 var raw=JSON.parse_string(raw_text)
 if not raw is Dictionary or raw.get("format","")!="xiyou-v19-meta":notify("无效的旧版进度文件");return
 var old=raw.get("meta",{})
 if not old is Dictionary:notify("旧进度结构不正确");return
 var heroes: Array=old.get("heroUnlocks",[])
 var completed: Array=raw.get("completed",[])
 var unlocks: Array=old.get("unlocks",[])
 heroes=heroes.duplicate();completed=completed.duplicate();unlocks=unlocks.duplicate()
 heroes.sort();completed.sort();unlocks.sort()
 var merit: int=clampi(int(old.get("merit",0)),0,100000)
 var hash=JSON.stringify([heroes,completed,unlocks,merit]).sha256_text()
 if hash in meta.imports:notify("该进度已导入");return
 for id in heroes:
  if not db.find("heroes",str(id)).is_empty() and id not in meta.unlocked:meta.unlocked.append(id)
 for id in unlocks:
  var hero: String=str(id).trim_suffix("-hidden")
  var weapon: String=hero+"_w4"
  if not db.find("weapons",weapon).is_empty() and weapon not in meta.weapon_unlocks:meta.weapon_unlocks.append(weapon)
 meta.merit+=maxi(0,merit-int(meta.import_merit_highwater))
 meta.import_merit_highwater=maxi(merit,meta.import_merit_highwater)
 meta.imports.append(hash)
 for c in raw.get("completed",[]):
  if c is float or c is int:
   if int(c)>=0 and int(c)<37 and int(c) not in meta.completed:meta.completed.append(int(c))
 save_run()
 home()
 notify("永久进度导入成功")
func pack_value(item):
 if item is Vector2:return {"__v":[item.x,item.y]}
 if item is Color:return {"__c":item.to_html()}
 if item is Dictionary:
  var result: Dictionary={}
  for key in item:result[key]=pack_value(item[key])
  return result
 if item is Array:return item.map(pack_value)
 return item
func unpack_value(item):
 if item is Dictionary:
  if item.has("__v"):return Vector2(item.__v[0],item.__v[1])
  if item.has("__c"):return Color(item.__c)
  var result: Dictionary={}
  for key in item:result[key]=unpack_value(item[key])
  return result
 if item is Array:return item.map(unpack_value)
 return item
func save_run() -> void:
 if not fight.player.is_empty() and mode!="training" and state not in ["home","ended","loadout","settings","import","merit"]:
  checkpoint={"mode":mode,"state":state,"hero":hero_id,"weapons":weapon_ids,"skills":skill_ids,"ultimate":ultimate_id,"branches":branches,"relics":relic_ids,"slot":slot,"relic_slot":relic_slot,"route":route,"route_index":route_index,"chapter":chapter,"step":step,"options":options,"offers":offers,"banned":banned,"visited":visited,"bought":bought,"rerolls":rerolls,"bans":bans,"pending":pending,"kind":kind,"room_id":room_id,"run_id":run_id,"event_id":event_id,"event_seen":event_seen,"remaining":remaining,"spawn_cd":spawn_cd,"room_time":room_time,"run_time":run_time,"boss_cursor":boss_cursor,"stock":stock,"selection_items":selection_items,"selection_kind":selection_kind,"trial_index":trial_index,"protection":protection,"rng":str(rng.state),"combat":pack_value(fight.snapshot())}
 if not checkpoint.is_empty() and state not in ["home","ended"]:checkpoint.run_statistics=run_statistics.snapshot()
 if state=="ended":checkpoint={}
 if not storage.write({"meta":meta,"settings":settings,"run":checkpoint}):notify(storage.last_error)
func checkpoint_valid(s: Dictionary) -> bool:
 if s.is_empty():return false
 if not storage.valid_payload({"run":s}):return false
 if s.get("combat",{}).get("combat_version",0)!=4:return false
 if db.find("heroes",s.hero).is_empty():return false
 if s.mode not in ["short","campaign","training"]:return false
 if s.state not in ["playing","paused","build","route","service","service_walk","room_paused","talent","preview","select"]:return false
 if not s.get("branches") is Array or s.branches.size()!=2:return false
 for branch in s.branches:
  if not (branch is int or branch is float) or branch!=int(branch) or int(branch) not in [0,1,2]:return false
 if s.weapons.size()!=2 or s.skills.size()!=2 or s.relics.size()!=2:return false
 for key in ["slot","relic_slot"]:
  if int(s.get(key,-1)) not in [0,1]:return false
 for pair in [["weapons","weapons"],["skills","skills"],["relics","relics"]]:
  for id in s[pair[0]]:
   if not id is String or db.find(pair[1],id).is_empty():return false
 if db.find("ultimates",s.get("ultimate","")).is_empty():return false
 for id in s.combat.owned:
  if db.find("talents",str(id)).is_empty():return false
 for key in ["arena_origin","arena_size"]:
  if s.combat.has(key):
   var packed=s.combat[key]
   if not packed is Dictionary or not packed.has("__v"):return false
   if key=="arena_size" and (packed.__v[0]<1100 or packed.__v[1]<470 or packed.__v[0]>5000 or packed.__v[1]>5000):return false
 if s.combat.has("obstacles"):
  if not s.combat.obstacles is Array or s.combat.obstacles.size()>32:return false
  for obstacle in s.combat.obstacles:
   if not obstacle is Dictionary or not obstacle.get("pos") is Dictionary or not obstacle.pos.has("__v"):return false
   if not (obstacle.get("radius") is int or obstacle.get("radius") is float) or obstacle.radius<20 or obstacle.radius>100:return false
   if obstacle.get("kind") not in ["rock","tree","pillar"]:return false
 if s.combat.has("layout_name") and not s.combat.layout_name is String:return false
 if s.combat.has("caches"):
  if not s.combat.caches is Array or s.combat.caches.size()>16:return false
  for cache in s.combat.caches:
   if not cache is Dictionary or not cache.get("claimed") is bool or not cache.get("pos") is Dictionary or not cache.pos.has("__v"):return false
   if not (cache.get("coins") is int or cache.get("coins") is float) or cache.coins<0 or cache.coins>100:return false
 if s.combat.has("evolutions"):
  if not s.combat.evolutions is Dictionary:return false
  for weapon_id in s.combat.evolutions:
   var evolution_branch=s.combat.evolutions[weapon_id]
   if db.find("weapons",str(weapon_id)).is_empty() or not (evolution_branch is int or evolution_branch is float) or evolution_branch!=int(evolution_branch) or int(evolution_branch) not in [1,2]:return false
 if s.route.is_empty() or int(s.get("route_index",-1))<0 or int(s.route_index)>=s.route.size():return false
 for c in s.route:
  if not (c is float or c is int) or int(c)<0 or int(c)>=37:return false
 if int(s.get("chapter",-1))!=int(s.route[int(s.route_index)]):return false
 var player: Dictionary=s.combat.player
 for key in ["hp","max_hp","shield","resource","coins","level","xp","pos"]:
  if not player.has(key):return false
 return true
func resume_run() -> void:
 if checkpoint.is_empty():return
 var s: Dictionary=checkpoint
 if not checkpoint_valid(s):
  notify("战局记录不完整，已保留原存档；可以开始新历劫")
  return
 mode=s.mode
 hero_id=s.hero
 weapon_ids=s.weapons
 skill_ids=s.skills
 ultimate_id=s.ultimate
 branches=s.branches
 relic_ids=s.relics
 slot=int(s.slot)
 relic_slot=int(s.relic_slot)
 route=s.route
 route_index=int(s.route_index)
 chapter=int(s.chapter)
 step=int(s.step)
 options=s.options
 offers=s.offers
 banned=s.banned
 visited=s.visited
 bought=s.bought
 rerolls=int(s.rerolls)
 bans=int(s.bans)
 pending=s.pending
 kind=s.kind
 room_id=s.room_id
 run_id=s.run_id
 event_id=s.event_id
 event_seen=s.event_seen
 remaining=int(s.remaining)
 spawn_cd=s.spawn_cd
 room_time=s.room_time
 run_time=s.run_time
 boss_cursor=int(s.boss_cursor)
 stock=s.get("stock",[])
 selection_items=s.get("selection_items",[])
 selection_kind=s.get("selection_kind","")
 trial_index=int(s.trial_index)
 protection=s.protection
 rng.state=int(s.rng)
 fight.reset(db.find("heroes",hero_id),db.find("weapons",weapon_ids[slot]))
 var b: Dictionary=unpack_value(s.combat)
 fight.restore(b)
 run_statistics.restore(s.get("run_statistics",{}),mode=="campaign" and route_index>0)
 if kind in ["shop","shrine","event","rest","reward","forge","curse"]:enter_reward_stage(false)
 charging=false;charge=0;input_attack=0;input_dash=0
 sync_sources()
 if s.state=="route":route_panel()
 elif s.state in ["talent","preview"]:talent_panel()
 elif s.state=="select" and not selection_items.is_empty():selection_panel()
 elif s.state in ["service","service_walk","room_paused"]:
  enter_reward_stage(false)
  if s.state=="service":services()
 else:state="playing";panel.hide();notify("战局已恢复")
func end_run(won: bool) -> void:
 state="ended"
 var totals: Dictionary=run_statistics.summary("chapter:%d"%mini(route_index,maxi(0,route.size()-1)),fight)
 show_panel("真经在望" if won else "此行暂歇","历劫 %d分%d秒 · 已记录击败%d妖怪 · 已记录伤害%d\n%s"%[int(run_time)/60,int(run_time)%60,totals.kills,totals.damage,"本次历劫完成，功德与解锁保留。" if won else "败于："+str(fight.player.last_hit)+"。本局构筑结束。"])
 if not totals.complete:text("旧存档的早期章节统计未记录，以上仅包含可确认的数据。",15)
 for record in fight.player.get("hit_history",[]):text("近期受击：%s · 生命损失%d · 护盾抵挡%d · 当时资源%d"%[record.source,record.damage,record.shield,record.resource],15)
 for source in totals.sources:text(source+"："+str(int(totals.sources[source])),16)
 button("再走一程",loadout)
 button("返回主页",home)
 save_run()


func _input(event: InputEvent) -> void:
 if mapping=="":return
 var pressed: bool=(event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton) and event.pressed
 if not pressed:return
 if event is InputEventKey and event.physical_keycode==KEY_ESCAPE:
  mapping="";show_settings();get_viewport().set_input_as_handled();return
 var group: String="keys" if event is InputEventKey else "pad_keys" if event is InputEventJoypadButton else "mouse_keys"
 var code: int=event.physical_keycode if event is InputEventKey else event.button_index
 for action in InputMap.get_actions():
  if action==mapping or str(action).begins_with("ui_"):continue
  for bound in InputMap.action_get_events(action):
   if (event is InputEventKey and bound is InputEventKey and bound.physical_keycode==code) or (event is InputEventJoypadButton and bound is InputEventJoypadButton and bound.button_index==code) or (event is InputEventMouseButton and bound is InputEventMouseButton and bound.button_index==code):
    notify("该输入已绑定到 "+str(action)+"，请换一个按钮")
    get_viewport().set_input_as_handled();return
 settings[group][mapping]=code
 apply_keys();mapping="";show_settings();save_run()
 get_viewport().set_input_as_handled()
func _unhandled_input(event: InputEvent) -> void:
 if cinematic.active:
  if event.is_action_pressed("pause") or event.is_action_pressed("dash") or event.is_action_pressed("attack"):
   cinematic.skip();reset_inputs();get_viewport().set_input_as_handled()
  return
 if state=="service_walk":
  if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or (event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_A):
   if gate_ready():cross_gate();get_viewport().set_input_as_handled()
   elif is_instance_valid(reward_stage) and reward_stage.near():services();get_viewport().set_input_as_handled()
  elif event.is_action_pressed("pause"):show_panel("房间小憩","当前场景与奖励已保存。");state="room_paused";button("继续逛房",func():enter_reward_stage(false));button("设置与操作",show_settings);button("回到主页",func():save_run();home());save_run()
  return
 if state=="service" and event.is_action_pressed("pause"):enter_reward_stage(false);save_run();return
 if event.is_action_pressed("pause"):
  if state=="playing":
   pause_panel()
  elif state=="paused":state="playing";panel.hide()
  elif state=="build":
   if build_return=="route":route_panel()
   elif build_return=="service":services()
   else:state="playing";panel.hide()
  elif state=="lab":state="playing";panel.hide()
  elif state=="settings":return_from_settings()
  elif state in ["loadout","merit","import"]:home()
  return
 if state!="playing":return
 if input_release_guard:return
 if event is InputEventKey and event.echo:return
 if (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")) and gate_ready():cross_gate();get_viewport().set_input_as_handled();return
 if event.is_action_pressed("map"):
  if mode=="training":training_lab()
  else:build_panel()
  return
 if event.is_action_pressed("attack"):pending_command={};heavy_buffer=0;input_dash=0;input_attack=.12
 if event.is_action_pressed("dash"):pending_command={};input_attack=0;heavy_buffer=0;input_dash=.12
 if event.is_action_pressed("heavy"):pending_command={};input_attack=0;input_dash=0;charging=true;charge=0
 if event.is_action_released("heavy") and charging:
  heavy_buffer=.12;heavy_power=minf(charge,1);heavy_aim=aim;charging=false
 for index in 2:
  if event.is_action_pressed("skill"+str(index+1)):
   input_attack=0;input_dash=0;heavy_buffer=0;charging=false
   pending_command={"slot":index,"left":.12,"aim":aim}
 if event.is_action_pressed("recall") and fight.recall()==0:notify("没有可以召回的御器")
 if event.is_action_pressed("ultimate"):
  pending_command={};input_attack=0;input_dash=0;heavy_buffer=0;charging=false
  if not fight.ultimate(db.find("ultimates",ultimate_id),aim):notify("绝技条件：资源不足或招式尚未收势")
 if event.is_action_pressed("relic"):
  var why: String=fight.relic(db.find("relics",relic_ids[relic_slot]),aim)
  if why!="":notify(why)
 if event.is_action_pressed("switch") and switch_cd<=0 and fight.can_switch():
  slot=1-slot
  fight.weapon=db.find("weapons",weapon_ids[slot])
  switch_cd=.35
  var inactive: int=0
  for id in fight.owned:
   if not fight.talent_active(db.find("talents",id)):inactive+=1
  notify("兵器："+fight.weapon.name+(" · %d项修行暂不适用，Tab查看"%inactive if inactive>0 else ""))
 if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:relic_slot=(relic_slot+1)%relic_ids.size();sync_sources()
 if event.is_action_pressed("lock"):
  var target: Dictionary=fight.nearest(fight.player.pos)
  lock_uid=int(target.uid) if not target.is_empty() and lock_uid<0 else -1
func _exit_tree() -> void:
 if is_instance_valid(audio):audio.stop()
 playback=null
func on_joy_connection_changed(_device: int,connected: bool) -> void:
 if connected:return
 for action in InputMap.get_actions():Input.action_release(action)
 reset_inputs()
 if state in ["playing","service_walk"]:notify("手柄已断开，已清除按键；可继续使用键鼠。")
func _notification(what: int) -> void:
 if what==NOTIFICATION_WM_CLOSE_REQUEST:save_run()
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT:reset_inputs()
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT and state=="playing" and pause_on_focus_loss:
  state="paused"
  show_panel("已暂停","窗口失去焦点。")
  button("继续",func():state="playing";panel.hide())
  save_run()
func _physics_process(dt: float) -> void:
 visual_motion_active=false
 clock+=dt
 toast_time=maxf(0,toast_time-dt)
 if toast_time<=0:toast.text=""
 switch_cd=maxf(0,switch_cd-dt)
 shake=maxf(0,shake-dt*25)
 if state=="service_walk":
  if cinematic.active:queue_redraw();return
  var walking: Vector2=demo_movement_override if demo_control else Input.get_vector("left","right","up","down")
  fight.role_step_dt=dt;fight.motion.step(fight,dt,walking,float(fight.hero.speed),0.0)
  visual_motion_active=true
  update_camera(dt);reward_stage.position=camera_offset()
  update_hud();queue_redraw();return
 if state=="playing":
  if input_release_guard:
   var held: bool=false
   for action in ["attack","heavy","dash","skill1","skill2","ultimate","relic","switch"]:
    if Input.is_action_pressed(action):held=true
   if not held:input_release_guard=false
  if cinematic.active:queue_redraw();return
  if cinematic_input_guard:
   if Input.is_action_pressed("attack") or Input.is_action_pressed("heavy") or Input.is_action_pressed("dash"):queue_redraw();return
   cinematic_input_guard=false
  if hitstop>0:
   hitstop=maxf(0,hitstop-dt)
   queue_redraw();return
  var movement: Vector2=demo_movement_override if demo_control else Input.get_vector("left","right","up","down")
  var mouse: Vector2=screen_to_world(get_global_mouse_position())-fight.player.pos
  if mouse.length()>2:aim=mouse.normalized()
  if not Input.get_connected_joypads().is_empty():
   var device: int=Input.get_connected_joypads()[0]
   var stick=Vector2(Input.get_joy_axis(device,JOY_AXIS_RIGHT_X),Input.get_joy_axis(device,JOY_AXIS_RIGHT_Y))
   if stick.length()>.2:aim=stick.normalized()
  if lock_uid>=0:
   var target: Dictionary={}
   for e in fight.enemies:
    if e.uid==lock_uid:target=e
   if target.is_empty():lock_uid=-1
   else:aim=(target.pos-fight.player.pos).normalized()
  if demo_control and demo_aim_override.length()>.1:aim=demo_aim_override
  if charging:charge+=dt
  if input_dash>0 and fight.dash(movement if movement.length()>.1 else aim):
   input_dash=0;charging=false;charge=0;heavy_buffer=0;pose_time=0
  if heavy_buffer>0 and fight.attack(heavy_aim,true,heavy_power):heavy_buffer=0
  heavy_buffer=maxf(0,heavy_buffer-dt)
  if not charging and heavy_buffer<=0 and (fight.dash_time<=0 or input_attack>0) and ((settings.get("hold_attack",false) and Input.is_action_pressed("attack") and not input_release_guard) or input_attack>0):
   if fight.attack(aim):
    input_attack=0
    notify("第%d段 · "%fight.player.action.combo+fight.player.action.get("chain_name","普攻"));toast_time=.65
  input_attack=maxf(0,input_attack-dt)
  input_dash=maxf(0,input_dash-dt)
  if not pending_command.is_empty():
   var index: int=pending_command.slot
   if fight.skill(db.find("skills",skill_ids[index]),index,pending_command.aim,int(branches[index])):pending_command={}
   else:
    pending_command.left-=dt
    if pending_command.left<=0:notify(fight.skill_reason(db.find("skills",skill_ids[index]),index));pending_command={}
  var current_action: Dictionary=fight.player.get("action",{})
  if not current_action.is_empty() and (current_action.elapsed<current_action.windup or current_action.kind=="skill" and current_action.definition.get("effect","")=="breath" and current_action.elapsed<current_action.windup+current_action.active):
   var difference: float=current_action.direction.angle_to(aim)
   current_action.direction=current_action.direction.rotated(clampf(difference,-dt*2.5,dt*2.5))
   fight.player.attack_direction=current_action.direction;fight.player.facing=current_action.direction
  fight.visible_bounds=Rect2(-camera_offset()+Vector2(0,115),Vector2(1280,535))
  fight.update(dt,movement)
  visual_motion_active=true
  update_camera(dt)
  room_time+=dt
  run_time+=dt
  if mode=="training" and fight.player.hp<=0:demo_failure()
  if mode!="training":
   spawn_cd-=dt
   var living: int=fight.enemies.filter(func(e):return not e.dead).size()
   if remaining>0 and spawn_cd<=0 and living<(preload("res://scripts/journey_balance.gd").active_limit(route_index) if preload("res://scripts/journey_balance.gd").enabled(fight) else 40):
    spawn_cd=preload("res://scripts/journey_balance.gd").interval(chapter,route_index) if preload("res://scripts/journey_balance.gd").enabled(fight) else 1.1
    remaining-=1
    var types: Array=["chaser","ranged","charge","guard","summoner"]
    fight.spawn(types[rng.randi_range(0,4)],spawn_position(),chapter)
   if fight.trial=="protect" and not fight.player.get("room_cleared",false):
    for e in fight.enemies:
     if e.pos.distance_to(fight.arena_bounds().get_center())<85:protection-=dt*3
    if protection<=0:fight.player.last_hit="护灯失败";end_run(false)
   if fight.trial=="time" and room_time>65 and not fight.player.get("room_cleared",false):fight.player.last_hit="限时试炼失败";end_run(false)
   if fight.player.hp<=0:end_run(false)
   elif state=="playing" and fight.player.xp>=90+fight.player.level*45:
    fight.player.xp-=90+fight.player.level*45
    fight.player.level+=1
    offers=[]
    pending="level"
    if preload("res://scripts/combo_talents.gd").full(fight):fight.player.coins+=4;pending="";save_run();return
    talent_panel()
    save_run()
   elif remaining<=0 and fight.enemies.is_empty() and state=="playing":
    var refs: Array=db.tables.chapters[chapter].bossRefs
    if kind=="boss" and boss_cursor+1<refs.size():boss_cursor+=1;spawn_boss()
    elif not fight.player.get("room_cleared",false):
     fight.player.room_cleared=true;fight.hazards=[];fight.bullets=fight.bullets.filter(func(b):return b.get("friendly",true));notify("妖氛已散：向东寻找金色出口，沿途可收集灵物");save_run()
    elif gate_ready():pass # The player confirms at the physical exit instead of leaving accidentally.
  elif state=="playing":
   if fight.enemies.is_empty():
    for i in 6:fight.spawn("dummy",fight.player.pos+Vector2(80+i*75,-70),0)
 update_hud()
 queue_redraw()
 fill_audio()
func action_key(action: String) -> String:
 for binding in InputMap.action_get_events(action):
  if binding is InputEventKey:return OS.get_keycode_string(binding.physical_keycode)
  if binding is InputEventMouseButton:return {1:"左键",2:"右键",3:"中键",4:"滚轮上",5:"滚轮下"}.get(binding.button_index,"鼠标%d"%binding.button_index)
 return action
func update_hud() -> void:
 toast.visible=toast_time>0 and toast_state==state
 if is_instance_valid(room_interact_button):
  room_interact_button.visible=not panel.visible and state in ["playing","service_walk"] and (gate_ready() or state=="service_walk" and is_instance_valid(reward_stage) and reward_stage.near()) and not cinematic.active
  room_interact_button.text="继续西行 · G / Enter / 手柄确认" if gate_ready() else "交互 · G / Enter / 手柄确认"
 battle_hud.visible=not panel.visible and state!="home"
 if fight.player.is_empty():battle_hud.present({"title":"重生之我也要取经 · 2.0"});return
 var slots: Array=[]
 for index in 2:
  var skill: Dictionary=db.find("skills",skill_ids[index])
  var cd: float=fight.skill_cd[index]
  var skill_status: String="补给房·暂不可用" if state=="service_walk" else fight.skill_reason(skill,index)
  var ready: bool=skill_status==""
  slots.append({"id":skill.id,"name":skill.name,"key":action_key("skill"+str(index+1)),"ready":ready,"cooldown":cd,"maximum":skill.cooldown,"status":"就绪" if ready else skill_status})
 var ultimate: Dictionary=db.find("ultimates",ultimate_id)
 var ult_reason: String=fight.ultimate_reason(ultimate)
 slots.append({"id":ultimate.id,"name":ultimate.name,"key":action_key("ultimate"),"ready":ult_reason=="","cooldown":0,"maximum":1,"status":"就绪" if ult_reason=="" else ult_reason})
 var relic: Dictionary=db.find("relics",relic_ids[relic_slot])
 var reason: String=fight.relic_reason(relic)
 slots.append({"id":relic.id,"name":relic.name,"key":action_key("relic"),"ready":fight.relic_cd<=0 and reason=="","cooldown":fight.relic_cd,"maximum":relic.cooldown,"status":"%.1fs"%fight.relic_cd if fight.relic_cd>0 else "就绪" if reason=="" else reason})
 slots.append({"id":"ui_dash","name":"闪避","key":action_key("dash"),"ready":fight.dash_stock>0 and fight.role.can_cancel(fight),"cooldown":fight.dash_cd if fight.dash_stock<2 else 0,"maximum":2.8,"status":"%d/2"%fight.dash_stock if fight.role.can_cancel(fight) else "起手中"})
 slots.append({"id":weapon_ids[1-slot],"name":"切换兵器","key":action_key("switch"),"ready":switch_cd<=0 and fight.can_switch(),"cooldown":switch_cd,"maximum":.35,"status":"%.1fs"%switch_cd if switch_cd>0 else "就绪" if fight.can_switch() else "收势后切换"})
 var action: String="蓄力 %.0f%%"%(minf(1,charge)*100) if charging else {"idle":"待机","run":"奔行","attack":"连招 %d/3"%fight.combo,"heavy":"重击收势","dash":"闪避","cast":"施术","ultimate":"绝技"}.get(fight.player.get("motion_state","idle"),"待机")
 if charging:action+=" · 释放后"+str(int(maxf(0,fight.player.resource-20))) if hero_id in ["wukong","bajie","bailongma"] and fight.player.resource>=20 else " · 未强化"
 elif not fight.player.get("action",{}).is_empty():action+=" · "+{"windup":"起手","active":"命中","recovery":"收势"}.get(fight.player.get("action_phase","windup"),"")
 battle_hud.present({"marked":fight.enemies.reduce(func(n,e):return n+int(e.marks),0),"title":fight.hero.name,"hp":fight.player.hp,"max_hp":fight.player.max_hp,"shield":fight.player.shield,"resource":fight.player.resource,"role_id":hero_id,"resource_rule":preload("res://scripts/character_combat_kit.gd").resource_rule_for(hero_id),"resource_name":fight.hero.resource,"coins":fight.player.coins,"weapon":fight.weapon.name,"location":NAMES.get(kind,kind)+" · "+("试招" if mode=="training" else "第%d章"%(chapter+1)),"action":action,"help":(action_key("interact")+"场内交互 · 右侧出口离房") if state in ["service_walk","service"] else action_key("recall")+"召回 · "+action_key("map")+("试招台" if mode=="training" else "构筑")+" · "+action_key("pause")+"暂停","slots":slots})
func setup_audio() -> void:
 if DisplayServer.get_name()=="headless":return
 preload("res://scripts/audio_mix.gd").configure()
 soundscape=preload("res://scripts/soundscape.gd").new();add_child(soundscape)
 for key in ["slash","bolt","field","orbit","return","heavy","impact","hit","crit","hurt","dash","skill","ultimate","break","pickup","warning","guard","shield","wall","empty"]:audio_streams[key]=load("res://assets/audio/"+key+".wav")
 for role in ["wukong","tangseng","bajie","shaseng","bailongma"]:
  for kind in ["skill","ultimate","dash","heavy"]:audio_streams[role+"_"+kind]=load("res://assets/audio/"+role+"_"+kind+".wav")
  for category in ["skills","ultimates"]:
   for definition in db.for_hero(category,role):
    var sound_id: String=role+("_skill_" if category=="skills" else "_ultimate_")+definition.effect
    audio_streams[sound_id]=load("res://assets/audio/"+sound_id+".wav")
 for weapon in db.tables.weapons:
  for hit in ["swing","heavy"]:audio_streams[weapon.id+"_"+hit]=load("res://assets/audio/"+weapon.id+"_"+hit+".wav")
 for i in 16:
  var voice:=AudioStreamPlayer.new();voice.bus="JourneyFX";add_child(voice);audio_players.append(voice)
 music=AudioStreamPlayer.new();music.stream=load("res://assets/audio/journey-theme.wav")
 music.bus="JourneyMusic"
 music.volume_db=-20;music.finished.connect(func():music.play());add_child(music);music.play()
func fill_audio() -> void:pass
func play_sound(kind: String) -> void:
 if kind=="phase":kind="warning"
 if not settings.sfx or audio_players.is_empty():return
 if kind in ["warning","break","ultimate"] and is_instance_valid(soundscape):soundscape.duck=.35
 var key: String=hero_id+"_"+kind if kind in ["skill","ultimate","dash","heavy"] else {"wukong":"slash","tangseng":"field","bajie":"heavy","shaseng":"return","bailongma":"bolt"}.get(hero_id,"slash") if kind=="swing" else kind
 if kind in ["swing","heavy"]:key=fight.weapon.id+"_"+kind
 if kind in ["skill","ultimate"]:
  var ability_key: String=hero_id+"_"+kind+"_"+str(fight.player.get("pose_clip","")).trim_prefix(hero_id+"_")
  if audio_streams.has(ability_key):key=ability_key
 if key not in audio_streams:return
 var important: bool=kind in ["warning","ultimate","break"]
 var begin: int=12 if important else 0
 var count: int=4 if important else 12
 var chosen: int=-1
 for offset in count:
  var index: int=begin+(audio_cursor+offset)%count
  if not audio_players[index].playing:chosen=index;break
 if chosen<0 and not important:return
 if chosen<0:chosen=begin+audio_cursor%count
 var voice: AudioStreamPlayer=audio_players[chosen];audio_cursor+=1
 voice.stop();voice.bus="JourneyWarnings" if important else "JourneyFX";voice.stream=audio_streams[key];voice.pitch_scale=audiovisual_rng.randf_range(.97,1.03);voice.volume_db=-13+linear_to_db(maxf(.001,float(settings.get("volume",.65))*float(settings.get("sfx_volume",1.0))));voice.play()
func feedback(type: String,pos: Vector2,value: float) -> void:
 play_sound(type)
 if type=="phase":
  fight.bullets=fight.bullets.filter(func(b):return b.get("friendly",true));fight.hazards=[];fight.invuln=maxf(fight.invuln,1.2)
  notify("首领转势 · 调整站位")
 sound_freq={"swing":230,"heavy":110,"hit":480,"crit":730,"hurt":85,"dash":380,"skill":650,"ultimate":130,"break":160}.get(type,300)
 sound_time=.055
 if type in ["swing","heavy"]:
  pose_heavy=type=="heavy"
  pose_duration=.28 if pose_heavy else .18
  pose_time=pose_duration
  sound_freq={"slash":180,"bolt":650,"field":330,"orbit":450,"return":540}.get(fight.weapon.get("mode","slash"),230)
 if type in ["impact","break"] and clock>=next_hitstop:
  hitstop=maxf(hitstop,.045 if type=="impact" else .07);next_hitstop=clock+.3
 if type in ["hurt","impact","break","ultimate"] and settings.shake:shake=maxf(shake,(6 if type=="ultimate" else 3)*float(settings.get("shake_strength",.5)))
 if type in ["hit","impact","crit","hurt"]:numbers.append({"pos":pos,"value":int(value),"life":.6,"type":type})
func _process(dt: float) -> void:
 if not fight.player.is_empty():fight.player.visual_dt=dt if visual_motion_active and state in ["playing","service_walk"] and not cinematic.active and hitstop<=0 else 0.0
 sync_static_floor()
 if is_instance_valid(reward_stage):reward_stage.position=camera_offset()
 if is_instance_valid(soundscape):
  var phase: int=0
  for enemy in fight.enemies:
   if not enemy.dead and enemy.has("profile"):phase=maxi(phase,int(enemy.get("phase",1)))
  soundscape.update_mix(dt,current_biome(),phase,settings.sfx and state in ["playing","service_walk","service"],float(settings.get("volume",.65))*float(settings.get("sfx_volume",1)))
 if music!=null:music.volume_db=-20+linear_to_db(maxf(.001,float(settings.get("volume",.65))*float(settings.get("music_volume",1.0)))) if settings.get("music",true) else -80
 if music!=null and is_instance_valid(soundscape):music.volume_db+=preload("res://scripts/audio_mix.gd").duck_db(soundscape.duck>0)
 ghost_cd=maxf(0,ghost_cd-dt)
 if state=="playing" and not fight.player.is_empty() and fight.dash_time>0 and ghost_cd<=0 and settings.effects:
  afterimages.append({"pos":fight.player.pos,"life":.18});ghost_cd=.035
 for ghost in afterimages:ghost.life-=dt
 afterimages=afterimages.filter(func(ghost):return ghost.life>0)
 pose_time=maxf(0,pose_time-dt)
 for n in numbers:n.life-=dt;n.pos.y-=dt*30
 numbers=numbers.filter(func(n):return n.life>0)
func camera_offset() -> Vector2:
 if fight.player.is_empty() or fight.arena_size.x<=1280:return Vector2.ZERO
 var viewport_size=Vector2(1280,535)
 var top_left: Vector2=((camera_focus if camera_initialized else fight.player.pos)-viewport_size*.5).clamp(fight.arena_origin,fight.arena_origin+fight.arena_size-viewport_size)
 return Vector2(0,115)-top_left
func update_camera(dt: float) -> void:
 if fight.player.is_empty():return
 var look: Vector2=(aim*28+fight.player.get("velocity",Vector2.ZERO)*.06).limit_length(52)
 var desired: Vector2=fight.player.pos+look
 if not camera_initialized:camera_focus=fight.player.pos;camera_initialized=true
 camera_focus=camera_focus.lerp(desired,1-exp(-dt*12))
 if camera_focus.distance_to(fight.player.pos)>110:camera_focus=fight.player.pos+(camera_focus-fight.player.pos).limit_length(110)
func screen_to_world(position: Vector2) -> Vector2:
 return position-camera_offset()
func spawn_position() -> Vector2:
 # Reinforcements arrive outside the immediate melee range without spawning unreachable across the map.
 for attempt in 20:
  var candidate: Vector2=fight.clamp_actor(fight.player.pos+Vector2.RIGHT.rotated(rng.randf()*TAU)*rng.randf_range(330,580),50)
  if candidate.distance_to(fight.player.pos)>=280:return candidate
 return fight.clamp_actor(fight.player.pos.move_toward(fight.arena_bounds().get_center(),400),50)
func draw_minimap() -> void:
 if fight.player.is_empty() or panel.visible:return
 var rect=Rect2(1134,654,134,62)
 draw_rect(rect,Color("314643"))
 var scale: float=minf((rect.size.x-10)/fight.arena_size.x,(rect.size.y-10)/fight.arena_size.y)
 var start: Vector2=rect.get_center()-fight.arena_size*scale*.5
 draw_rect(Rect2(start,fight.arena_size*scale),Color("a48e61"),false,1)
 for obstacle in fight.obstacles:draw_circle(start+(obstacle.pos-fight.arena_origin)*scale,maxf(1,obstacle.radius*scale),Color("66736b"))
 for cache in fight.caches:
  if not cache.claimed:draw_circle(start+(cache.pos-fight.arena_origin)*scale,2,Color("d7b765"))
 for e in fight.enemies:
  if not e.dead:draw_circle(start+(e.pos-fight.arena_origin)*scale,2,Color("d06d5a"))
 draw_circle(start+(fight.exit_position()-fight.arena_origin)*scale,3,Color("e5c979") if fight.player.get("room_cleared",false) else Color("727b71"))
 draw_circle(start+(fight.player.pos-fight.arena_origin)*scale,3,Color("a9dfd5"))
 draw_string(font,Vector2(24,693),"%s · %d × %d · 灵物 %d/%d · %s"%[fight.layout_name,fight.arena_size.x,fight.arena_size.y,fight.caches.filter(func(c):return c.claimed).size(),fight.caches.size(),"走近东侧关口按 G 继续" if fight.player.get("room_cleared",false) else "探索并清除妖氛" if mode!="training" else "训练场自由试用"],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("e4d1ab"))
func current_biome() -> String:
 if mode=="short":return ["forest","temple","river"][mini(2,route_index)]
 if mode=="training":
  for enemy in fight.enemies:
   if enemy.has("profile"):return enemy.profile.biome
  return "forest"
 var plan: Dictionary=preload("res://scripts/chapter_scenery.gd").composition(chapter)
 return plan.get("floor_biome",db.tables.chapters[chapter].get("biome","wild"))
func current_environment() -> Texture2D:
 return preload("res://scripts/journey_scene_art.gd").texture(current_biome())
func sync_static_floor() -> void:
 static_floor.visible=state!="home" and not is_instance_valid(reward_stage)
 if not static_floor.visible:return
 static_floor.position=camera_offset()
 var bounds: Rect2=fight.arena_bounds() if not fight.player.is_empty() and fight.arena_size.x>1280 else Rect2(0,115,1280,535)
 static_floor.configure(bounds,current_environment(),current_biome(),chapter)
func projectile_in_view(projectile: Dictionary) -> bool:
 # Include every supported projectile trail, bitmap, glow, radius and camera shake.
 var margin: float=maxf(80,float(projectile.get("radius",0))+64)+shake
 return Rect2(-camera_offset()+Vector2(0,115),Vector2(1280,535)).grow(margin).has_point(projectile.pos)
func _draw() -> void:
 sync_static_floor()
 if state=="home":return
 draw_set_transform(Vector2.ZERO)
 draw_rect(Rect2(0,0,1280,115),Color("192e2d"))
 draw_rect(Rect2(0,650,1280,70),Color("192e2d"))
 if fight.player.is_empty() or fight.arena_size.x<=1280:draw_rect(Rect2(88,152,1104,472),Color("a18450"),false,2)
 if not fight.player.is_empty():
  var offset=Vector2(sin(clock*23),cos(clock*31))*shake
  material_draw_base=Transform2D(0,camera_offset()+offset)
  draw_set_transform(camera_offset()+offset)
  for f in fight.fields:preload("res://scripts/combat_presentation.gd").field(self,f,fight.time,not settings.effects)
  role_art.draw_seals(self,fight.player.get("seals",[]),fight.time)
  for cache in fight.caches:
   if cache.claimed:continue
   preload("res://scripts/spirit_props.gd").cache(self,cache,fight.caches.find(cache),clock,font,cache.pos.distance_to(fight.player.pos)<160)
  var gate: Vector2=fight.exit_position()
  var gate_color=Color("d9b76f") if fight.player.get("room_cleared",false) else Color("647364")
  if not is_instance_valid(reward_stage):
   preload("res://scripts/journey_scene_art.gd").gate(self,gate,fight.player.get("room_cleared",false))
   preload("res://scripts/journey_scene_art.gd").gate(self,fight.arena_origin+Vector2(110,fight.arena_size.y*.5),true,true)
   draw_string(font,gate+Vector2(-32,-65),"出口开启" if fight.player.get("room_cleared",false) else "清敌开启",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("34433b"))
  for drop in fight.loot:draw_circle(drop.pos,5,Color("d5ac51"))
  for ghost in afterimages:draw_hero(ghost.pos,Color(1,1,1,ghost.life*.9))
  draw_world_actors()
  if settings.effects:preload("res://scripts/weapon_effects.gd").action_trail(self,fight.player.get("action",{}),fight.player.pos,settings.get("reduced_flash",false))
  for b in fight.bullets:
   if cull_friendly_projectiles and b.get("friendly",true) and not projectile_in_view(b):continue
   if role_art.draw_projectile(self,b):continue
   if not b.get("friendly",true):
    var art=preload("res://scripts/painterly_assets.gd")
    preload("res://scripts/enemy_effects.gd").projectile(self,b)
    continue
   draw_line(b.pos-b.dir*22,b.pos,b.color.darkened(.2),3,true)
   draw_circle(b.pos,b.radius,b.color)
   if settings.effects:
    match b.get("visual",""):
     "beam":draw_line(b.pos-b.dir*46,b.pos+b.dir*8,Color("fff0c3"),5,true)
     "breath":
      draw_colored_polygon(PackedVector2Array([b.pos+b.dir*12,b.pos-b.dir*28+b.dir.orthogonal()*10,b.pos-b.dir*18,b.pos-b.dir*28-b.dir.orthogonal()*10]),Color("e9965a"))
     "fan":draw_arc(b.pos,12,b.dir.angle()-PI*.4,b.dir.angle()+PI*.4,14,Color("f4d491"),3,true)
     "pursue":draw_arc(b.pos,12,clock*5,clock*5+PI*1.5,16,Color("a8d6b6"),2,true)
   if b.back:
    draw_arc(b.pos,11,0,TAU,14,Color("8cd6d3"),2,true)
    draw_line(b.pos-b.dir*35,b.pos,Color("82c1bf"),2,true)
  draw_line(fight.player.pos+aim*22,fight.player.pos+aim*42,Color("f4e6b7"),2,true)
  if charging:draw_arc(fight.player.pos,45,-PI/2,-PI/2+TAU*minf(1,charge),32,Color("cfa449"),4,true)
  if fight.player.shield>0:preload("res://scripts/painterly_assets.gd").stamp(self,preload("res://scripts/painterly_assets.gd").relic("relic_7"),fight.player.pos-Vector2(0,28),Vector2(38,38),0,.22)
  if fight.has("orbit") or fight.time<fight.player.get("orbit_until",0):
   for i in 1+int(fight.value("orbit_count")):
    var p: Vector2=fight.player.pos+Vector2.RIGHT.rotated(fight.time*3*(1+fight.value("orbit_speed"))+i*PI)*78
    preload("res://scripts/painterly_assets.gd").stamp(self,preload("res://scripts/painterly_assets.gd").weapon(fight.weapon.id),p,Vector2(65,52),fight.time*3+i*PI,.7)
  for v in fight.visuals:
   if v.kind=="boss_fall":continue
   if not settings.effects and v.kind!="line" and v.get("effect","")!="clone_replay":continue
   var color: Color=v.color
   color.a=clampf(v.life/v.max,0,1)
   if v.kind=="material_hit":
    var material: Array=preload("res://scripts/weapon_effects.gd").MATERIALS.get(v.weapon_style,["c7b78d","metal",4,2.0])
    preload("res://scripts/weapon_effects.gd").grains(self,v.pos,v.dir,v.radius,1-v.life/v.max,material,.8)
   elif v.kind=="role_fx":role_art.draw(self,v,settings.get("reduced_flash",false) or not settings.effects)
   elif v.kind=="line":
    var delta: Vector2=v.pos-v["from"]
    preload("res://scripts/abilities_visual.gd").stream(self,v["from"]-Vector2(0,20),delta.normalized(),delta.length(),1-v.life/v.max,Color("c7bd86",v.life/v.max),1.8)
   else:preload("res://scripts/weapon_effects.gd").grains(self,v.pos,Vector2.RIGHT.rotated(v.get("angle",0)),minf(45,v.get("radius",60)),1-v.life/v.max,["baa47a","dust",5,3.0],.6)
  if fight.trial=="protect":
   draw_circle(fight.arena_bounds().get_center(),18,Color("f0ce6d"))
   draw_string(font,fight.arena_bounds().get_center()+Vector2(-40,-30),"灯火%d"%protection,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("213a34"))
  for n in numbers if settings.get("numbers",true) else []:draw_string(font,n.pos,str(n.value),HORIZONTAL_ALIGNMENT_LEFT,-1,21 if n.type=="crit" else 16,Color("b74d40") if n.type=="hurt" else Color("8c542e"))
  draw_danger()
  draw_set_transform(Vector2.ZERO)
  draw_rect(Rect2(0,0,1280,115),Color("192e2d"))
  draw_rect(Rect2(0,650,1280,70),Color("192e2d"))
  draw_boss_hud()
  draw_minimap()
 if panel.visible:
  draw_set_transform(Vector2.ZERO)
  draw_rect(Rect2(0,0,1280,720),Color(.035,.08,.07,.28))

func draw_obstacle(obstacle: Dictionary) -> void:
 if obstacle.has("art_index"):
  preload("res://scripts/chapter_scenery.gd").draw(self,obstacle,fight.player.pos)
  return
 var pos: Vector2=obstacle.pos
 var r: float=obstacle.radius
 var source: Rect2={"rock":Rect2(0,210,750,550),"tree":Rect2(760,60,760,700),"pillar":Rect2(1540,10,508,750)}[obstacle.kind]
 var width: float=r*2.5 if obstacle.kind=="tree" else r*2.1
 var size: Vector2=Vector2(width,width*source.size.y/source.size.x)
 var dest=Rect2(pos+Vector2(-size.x*.5,r*.45-size.y),size)
 var fade: bool=dest.grow(12).has_point(fight.player.pos+Vector2(0,-45)) and fight.player.pos.y<pos.y
 var tint=Color(1,1,1,.36 if fade else 1.0)
 ellipse(pos+Vector2(5,r*.3),Vector2(r,r*.36),Color(0,0,0,.14))
 if props_texture!=null:draw_texture_rect_region(props_texture,dest,source,tint)
 if settings.effects:draw_arc(pos,r,0,TAU,32,Color(.31,.41,.34,.16),1,true)
func draw_world_actors() -> void:
 var actors: Array=[]
 if is_instance_valid(reward_stage):actors.append({"y":reward_stage.interaction.y,"kind":"reward_prop"})
 for obstacle in fight.obstacles:
  if is_instance_valid(reward_stage) and not obstacle.has("art_index"):continue
  actors.append({"y":obstacle.pos.y,"kind":"obstacle","data":obstacle})
 for e in fight.enemies:actors.append({"y":e.pos.y,"kind":"enemy","data":e})
 for summon in fight.summons:actors.append({"y":summon.pos.y,"kind":"summon","data":summon})
 for v in fight.visuals:
  if v.kind=="boss_fall":actors.append({"y":v.pos.y,"kind":"boss_fall","data":v})
 actors.append({"y":fight.player.pos.y,"kind":"hero"})
 actors.sort_custom(func(a,b):return a.y<b.y)
 for actor in actors:
  match actor.kind:
   "reward_prop":
    preload("res://scripts/spirit_props.gd").room(self,kind,reward_stage.interaction)
    preload("res://scripts/journey_scene_art.gd").room_extras(self,kind,reward_stage.interaction,current_biome(),clock)
   "obstacle":draw_obstacle(actor.data)
   "enemy":draw_enemy(actor.data)
   "boss_fall":
    var fallen: Dictionary=actor.data.actor.duplicate()
    fallen.fall_progress=1-actor.data.life/actor.data.max
    preload("res://scripts/boss_rig.gd").draw(self,fallen,1-smoothstep(.5,1,fallen.fall_progress))
   "summon":draw_hero(actor.data.pos,Color(1,1,1,.4))
   "hero":draw_hero(fight.player.pos,Color(1,1,1,.78) if fight.invuln>0 and not demo_control else Color.WHITE)

func draw_boss_hud() -> void:
 if panel.visible:return
 for e in fight.enemies:
  if e.kind!="boss":continue
  draw_rect(Rect2(340,117,600,66),Color(.09,.16,.15,.94))
  var phase: String=["一阶段","二阶段","三阶段 · 狂势"][clampi(int(e.phase)-1,0,2)]
  var state_text: String="转阶段蓄势" if e.get("transition",0)>0 else "破势 · 反击 +15%" if e.stagger>0 else "反击窗口 +15%伤害" if e.get("exposed",0)>0 else fight.bosses.TITLES.get(e.get("action",""),"寻机")
  draw_string(font,Vector2(352,137),e.name+" · "+e.get("form","")+" · "+phase+" · "+state_text,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("ecdcb3"))
  draw_rect(Rect2(352,145,574,5),Color("5c5b4c"))
  draw_rect(Rect2(352,145,574*maxf(0,e.hp)/e.max_hp,5),Color("b95642"))
  draw_rect(Rect2(352,154,574*minf(100,e["break"])/100,3),Color("d3ba78"))
  var hint: String=preload("res://scripts/boss_tactics.gd").plan(e.profile.id)[3] if e.has("profile") else "避开预警，在收招时反击"
  draw_string(font,Vector2(352,176),hint,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("d0bd93"))
  break

func legacy_draw_danger() -> void:
 for h in fight.hazards:
  var warning: bool=h.warn>0
  var red=Color("bd493d") if warning else Color("a13229")
  var outline:=Color(.10,.08,.08,.78)
  if h.kind=="laser":draw_line(h.pos,h.end,outline,9 if warning else 12,true)
  elif h.kind=="ring":
   draw_arc(h.pos,h.radius-28,0,TAU,64,outline,6,true);draw_arc(h.pos,h.radius+28,0,TAU,64,outline,6,true)
  else:draw_arc(h.pos,h.radius,0,TAU,48,outline,7,true)
  var wash=red
  wash.a=.16 if warning else .26
  if h.kind=="laser":
   draw_line(h.pos,h.end,wash,h.radius*2,true)
   draw_line(h.pos,h.end,red,3 if warning else 7,true)
  elif h.kind=="ring":
   draw_arc(h.pos,h.radius,0,TAU,64,wash,56,true)
   draw_arc(h.pos,h.radius-28,0,TAU,64,red,2,true)
   draw_arc(h.pos,h.radius+28,0,TAU,64,red,2,true)
  else:
   draw_circle(h.pos,h.radius,wash)
   draw_arc(h.pos,h.radius,0,TAU,48,red,3,true)
   if warning:draw_arc(h.pos,h.radius+4,-PI/2,-PI/2+TAU*(1-h.warn/maxf(.01,h.warning)),48,Color("ffe9b0"),3,true)
   else:
    var mark: String={"fire":"火","ice":"冰","poison":"毒","web":"缚","pull":"摄","gust":"风","fog":"雾"}.get(h.kind,"")
    if mark!="":draw_string(font,h.pos+Vector2(-8,6),mark,HORIZONTAL_ALIGNMENT_LEFT,-1,18,red)
 for e in fight.enemies:
  if not e.has("profile"):continue
  if e.get("ward",0)>0:
   draw_arc(e.pos,55,0,TAU,40,Color("e4d49b"),5,true)
   draw_string(font,e.pos+Vector2(-55,-70),"护身 · 重击破除",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("892f25"))
  if e.warning<=0:continue
  draw_string(font,e.pos+Vector2(-55,45),fight.bosses.TITLES.get(e.action,e.action),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("a7372d"))
  if e.action=="charge":
   var target: Vector2=fight.clamp_actor(e.pos+(e.target-e.pos).normalized()*375,e.radius)
   draw_line(e.pos,target,Color(.73,.22,.18,.23),70,true)
   draw_line(e.pos,target,Color("ad3f32"),3,true)
  elif e.action in ["fan","wave","burst"]:
   for direction in fight.bosses.projectile_directions(e):draw_line(e.pos,e.pos+direction*230,Color("ad3f32"),2,true)
func ellipse(center: Vector2,radius: Vector2,color: Color) -> void:
 var points=PackedVector2Array()
 for i in 24:points.append(center+Vector2(cos(i*TAU/24)*radius.x,sin(i*TAU/24)*radius.y))
 draw_colored_polygon(points,color)
func draw_hero(pos: Vector2,tint: Color) -> void:
 var offset: Vector2=camera_offset()+Vector2(sin(clock*23),cos(clock*31))*shake
 ellipse(pos+Vector2(0,2),Vector2(25 if hero_id=="bajie" else 20,6),Color(0,0,0,.22)*tint)
 var index: int=0
 for i in db.tables.heroes.size():
  if db.tables.heroes[i].id==hero_id:index=i
 fight.player.fullbody_walk_enabled=settings.get("fullbody_walk",true)
 character_pose.draw(self,index,fight.player,tint,fight.time,Transform2D(0,offset+pos),hero_id)
 draw_set_transform(offset)
func draw_enemy(e: Dictionary) -> void:
 var pos: Vector2=e.pos
 var r: float=e.radius
 var col=Color("85594a") if e.kind=="boss" else Color("577464") if e.kind=="guard" else Color("786378") if e.kind=="summoner" else Color("9b754f")
 if e.flash>0:col=Color("f1e3ba")
 ellipse(pos+Vector2(0,3),Vector2(r,r*.3),Color(0,0,0,.2))
 var premium_index: int={"红孩儿":0,"牛魔王":1,"青牛精":1,"白骨精":2}.get(e.name,-1)
 if e.kind=="summoner" and int(e.get("visual_variant",0))==2:premium_index=3
 if e.kind!="dummy" and enemy_rig_available:
  preload("res://scripts/enemy_rig.gd").draw(self,e)
 elif premium_index>=0 and boss_texture!=null:
  var source: Rect2=boss_source(premium_index)
  var size: Vector2=Vector2(r*7*source.size.x/source.size.y,r*7)
  var breathe: float=sin(clock*2+e.uid)*1.6
  draw_texture_rect_region(boss_texture,Rect2(pos+Vector2(-size.x*.5,-size.y*.88-breathe),size),source,Color(1.3,1.2,1.1) if e.flash>0 else Color.WHITE)
 elif enemies_texture!=null:
  var index: int={"chaser":0,"ranged":1,"charge":2,"guard":3,"summoner":4,"elite":5,"boss":6,"dummy":7}.get(e.kind,0)
  if e.has("profile"):index={"tiger":5,"bear":6,"wind":4,"bone":4,"robe":4,"horn":6,"fire":4,"fish":1,"bull":6,"scorpion":2,"monkey":0,"fan":1,"brow":4,"beast":5,"spider":4,"bird":1,"deer":3,"mouse":0,"leopard":5,"lion":5,"rhino":6,"rabbit":1}.get(e.profile.type,6)
  if e.kind!="boss" and e.kind!="dummy":index=[0,3,1,4,2,1,6,4][int(e.get("skin",0))]
  var cuts: Array=[0.0,.117,.236,.342,.493,.609,.77,.91,1.0]
  var width: float=enemies_texture.get_width()
  var tops: Array=[.36,.20,.38,.17,.28,.22,.11,.39]
  var height: float=enemies_texture.get_height()
  var source:=Rect2(width*cuts[index],height*tops[index],width*(cuts[index+1]-cuts[index]),height*(.93-tops[index]))
  var size:=Vector2(r*4.2,r*6.2)*(float(e.get("body_scale",1)) if e.kind=="boss" else 1.0)
  draw_texture_rect_region(enemies_texture,Rect2(pos+Vector2(-size.x*.5,-size.y*.78),size),source,Color(1.2,1.2,1.2) if e.flash>0 else Color.WHITE.lerp(Color(e.profile.accent),.15) if e.has("profile") else [Color.WHITE,Color("c4dbc8"),Color("dfc6b3")][int(e.get("visual_variant",0))])
 if e.get("exposed",0)>0 and e.kind!="boss":
  draw_arc(pos,r+13,0,TAU,40,Color("dfbd61"),3,true)
 if e.get("affix","")!="":draw_string(font,pos+Vector2(-20,-r-20),e.affix,HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("8c3655"))
 if e.has("profile") and premium_index<0 and not boss_heads_available:
  var accent=Color(e.profile.accent)
  # Equipment overlays keep a boss silhouette and attack cue distinct from ordinary enemies.
  var tip=pos+Vector2(r*1.4,-r*.4)
  draw_line(pos+Vector2(12,-18),tip,Color("6a503b"),6,true)
  if e.profile.type in ["tiger","bull","horn","rhino"]:
   draw_colored_polygon(PackedVector2Array([tip+Vector2(-14,-26),tip+Vector2(18,-16),tip+Vector2(8,12)]),accent)
  elif e.profile.type in ["fire","wind","fan","bird"]:draw_arc(tip,20,-PI,0,20,accent,5,true)
  else:draw_circle(tip,12,accent);draw_arc(tip,18,0,TAU,20,accent,2,true)
  if e.transition>0:draw_arc(pos,r+16,-PI/2,-PI/2+TAU*(1-e.transition/1.2),40,accent,5,true)
 if e.kind!="boss":
  draw_rect(Rect2(pos+Vector2(-r,-r-12),Vector2(r*2,4)),Color("3a4033"))
  draw_rect(Rect2(pos+Vector2(-r,-r-12),Vector2(r*2*maxf(0,e.hp/e.max_hp),4)),Color("b64d3a"))
 if e.slow>0:draw_arc(pos,r+6,0,TAU,20,Color("6babb1"),2,true)
 if e.burn>0:draw_arc(pos,r+9,PI,TAU,12,Color("d96c37"),3,true)
 if e.poison>0:
  draw_circle(pos+Vector2(r+8,-6),4,Color("71915b"))
  draw_circle(pos+Vector2(r+12,4),3,Color("71915b"))
 if e.root>0:
  draw_line(pos+Vector2(-r,-r),pos+Vector2(r,r),Color("76bfc5"),2,true)
  draw_line(pos+Vector2(r,-r),pos+Vector2(-r,r),Color("76bfc5"),2,true)
 if e.marks>0:draw_string(font,pos+Vector2(-10,r+20),str(e.marks),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("526342"))
func draw_preview() -> void:
 var center=Vector2(640,490)
 var phase=fmod(clock,2.0)/2
 draw_rect(Rect2(390,425,500,155),Color("213b36"))
 if preview in ["chain","crit_chain"]:
  for i in 3:draw_line(center+Vector2(-150+i*90,-20),center+Vector2(-60+i*90,25),Color("e7c979"),3,true)
 elif preview in ["orbit","orbit_count","orbit_speed"]:
  draw_arc(center,55,0,TAU,40,Color("d7c181"),2,true)
  draw_circle(center+Vector2.RIGHT.rotated(phase*TAU)*55,9,Color("eed49b"))
 elif preview in ["split","fan","fork"]:
  for i in 3:draw_circle(center+Vector2((phase-.5)*260,(i-1)*phase*65),7,Color("e4c085"))
 elif preview in ["return","bounce"]:draw_circle(center+Vector2(sin(phase*TAU)*150,0),9,Color("e4c085"))
 else:draw_arc(center,25+phase*70,0,TAU,40,Color("d7c181"),3,true)


func play_cinematic(title: String, story: String, boss: bool=false) -> void:
 if not cinematics_enabled:return
 if not cinematic.is_inside_tree():
  var layer:=CanvasLayer.new();layer.layer=30;add_child(layer);layer.add_child(cinematic)
 cinematic.duration=1.4 if boss else .85
 cinematic.font=font
 var index: int=0
 for i in db.tables.heroes.size():
  if db.tables.heroes[i].id==hero_id:index=i
 cinematic.boss_portrait=null
 if boss:
  for enemy in fight.enemies:
   var id: int={"红孩儿":0,"牛魔王":1,"青牛精":1,"白骨精":2}.get(enemy.name,-1)
   if id>=0:
    var portrait:=AtlasTexture.new();portrait.atlas=boss_texture;portrait.region=boss_source(id);cinematic.boss_portrait=portrait;break
 reset_inputs();cinematic_input_guard=true;cinematic.play(title,story,heroes_texture,index,boss)

func boss_source(index: int) -> Rect2:
 var cuts: Array=[0.0,.224,.5,.742,1.0]
 return Rect2(cuts[index]*boss_texture.get_width(),0,(cuts[index+1]-cuts[index])*boss_texture.get_width(),boss_texture.get_height())

func draw_danger() -> void:
 var art=preload("res://scripts/enemy_effects.gd")
 for hazard in fight.hazards:art.hazard(self,hazard,fight.time,not settings.effects)
 for enemy in fight.enemies:
  if not enemy.dead:art.actor(self,enemy,fight.time)

func gate_ready() -> bool:
 if cinematic.active or fight.player.is_empty() or state not in ["playing","service_walk"]:return false
 if state=="playing" and (mode=="training" or not fight.player.get("room_cleared",false)):return false
 return fight.player.pos.distance_to(fight.exit_position())<90
func cross_gate() -> void:
 if not gate_ready():return
 reset_inputs();fight.player.velocity=Vector2.ZERO
 if state=="service_walk":
  if room_id not in visited:visited.append(room_id)
  new_route()
 else:room_reward()

