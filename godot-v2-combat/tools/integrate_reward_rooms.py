from pathlib import Path
R=Path(__file__).resolve().parents[1]
def edit(n,o,v):
 p=R/n;s=p.read_text(encoding='utf-8');assert o in s,(n,o[:45]);p.write_text(s.replace(o,v,1),encoding='utf-8')
p=R/'scripts/reward_room.gd';s=p.read_text(encoding='utf-8');s='\n'.join(x for x in s.splitlines() if 'exit_position_override' not in x)+'\n';s=s.replace('c.obstacles=[{"rect":Rect2(interaction+Vector2(-105,-135),Vector2(210,65)),"kind":"stone"}]','c.obstacles=[]\n  for i in 3:c.obstacles.append({"pos":interaction+Vector2((i-1)*65,-105),"radius":42.0,"kind":"pillar"})');s=s.replace('bounds.position+Vector2(1500,450)','combat.exit_position()');p.write_text(s,encoding='utf-8')
(R/'scenes/rewards').mkdir(parents=True,exist_ok=True)
for kind in ['shop','shrine','event','rest','reward','forge','curse']:
 (R/'scenes/rewards'/(kind+'.tscn')).write_text(f'[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://scripts/reward_room.gd" id="1"]\n[node name="{kind.title()}Room" type="Node2D"]\nshow_behind_parent = true\nscript = ExtResource("1")\nroom_kind = "{kind}"\n',encoding='utf-8')
edit('scripts/main.gd','var icons=','var reward_stage\nvar room_interact_button: Button\nvar icons=')
edit('scripts/main.gd',' layer.add_child(panel)\n',' layer.add_child(panel)\n room_interact_button=Button.new();room_interact_button.position=Vector2(490,570);room_interact_button.size=Vector2(300,48);room_interact_button.text="交互 · G / Enter / 手柄确认";room_interact_button.hide();layer.add_child(room_interact_button)\n room_interact_button.pressed.connect(func():\n  if state=="service_walk" and is_instance_valid(reward_stage) and reward_stage.near():services())\n')
edit('scripts/main.gd','[["left",KEY_A]','[["interact",KEY_G],["left",KEY_A]')
edit('scripts/main.gd','func enter_room(type: String) -> void:\n','''func clear_reward_stage() -> void:
 if is_instance_valid(reward_stage):reward_stage.queue_free()
 reward_stage=null
 if is_instance_valid(room_interact_button):room_interact_button.hide()
func enter_reward_stage(fresh: bool=true) -> void:
 clear_reward_stage()
 reward_stage=load("res://scenes/rewards/"+kind+".tscn").instantiate();add_child(reward_stage)
 reward_stage.configure(fight,font,fresh);camera_initialized=false
 state="service_walk";panel.hide();reset_inputs();update_camera(.2);reward_stage.position=camera_offset()
 notify(NAMES[kind]+" · 走近场景物件选择奖励，右侧出口继续赶路")
func enter_room(type: String) -> void:
''')
edit('scripts/main.gd',' kind=type\n fight.clear_room()',' clear_reward_stage()\n kind=type\n fight.clear_room()')
edit('scripts/main.gd','  stock=offers.duplicate()\n  services()','  stock=offers.duplicate()\n  enter_reward_stage()\n  play_cinematic(NAMES[kind],"走近场景中的物件，选择所需的修行与补给")')
edit('scripts/main.gd','func home() -> void:\n','func home() -> void:\n clear_reward_stage()\n')
edit('scripts/main.gd','func new_route() -> void:\n','func new_route() -> void:\n clear_reward_stage()\n')
edit('scripts/main.gd','func role_demo(hero: String, build_index: int=-1) -> void:\n','func role_demo(hero: String, build_index: int=-1) -> void:\n clear_reward_stage()\n')
edit('scripts/main.gd','func services() -> void:\n','func services() -> void:\n if state=="service_walk" and (not is_instance_valid(reward_stage) or not reward_stage.near()):return\n')
edit('scripts/main.gd',' button("继续赶路",func():visited.append(room_id);new_route())',' button("返回场景",func():enter_reward_stage(false);save_run())\n button("离开此房",func():\n  if room_id not in visited:visited.append(room_id)\n  new_route())')
edit('scripts/main.gd',' if event.is_action_pressed("pause"):\n',''' if state=="service_walk":
  if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or (event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_A):
   if is_instance_valid(reward_stage) and reward_stage.near():services();get_viewport().set_input_as_handled()
  elif event.is_action_pressed("pause"):show_panel("房间小憩","当前场景与奖励已保存。");state="room_paused";button("继续逛房",func():enter_reward_stage(false));button("设置与操作",show_settings);button("回到主页",func():save_run();home());save_run()
  return
 if state=="service" and event.is_action_pressed("pause"):enter_reward_stage(false);save_run();return
 if event.is_action_pressed("pause"):
''')
edit('scripts/main.gd',' if state=="playing":\n  if input_release_guard:',''' if state=="service_walk":
  if cinematic.active:queue_redraw();return
  var walking: Vector2=demo_movement_override if demo_control else Input.get_vector("left","right","up","down")
  fight.role_step_dt=dt;fight.motion.update(fight.player,walking,dt,fight.hero.id)
  fight.player.pos=fight.geometry.move(fight.player.pos,fight.player.velocity*dt)
  update_camera(dt);reward_stage.position=camera_offset()
  if fight.player.pos.distance_to(fight.exit_position())<65:
   if room_id not in visited:visited.append(room_id)
   new_route();return
  update_hud();queue_redraw();return
 if state=="playing":
  if input_release_guard:''')
# Keep the scene's background positioned correctly while reward dialogs pause walking.
edit('scripts/main.gd','func _process(dt: float) -> void:\n','func _process(dt: float) -> void:\n if is_instance_valid(reward_stage):reward_stage.position=camera_offset()\n')
edit('scripts/main.gd',' if not fight.player.is_empty() and fight.arena_size.x>1280:\n  draw_rect',' if is_instance_valid(reward_stage):pass\n elif not fight.player.is_empty() and fight.arena_size.x>1280:\n  draw_rect')
edit('scripts/main.gd','for obstacle in fight.obstacles:actors.append','for obstacle in ([] if is_instance_valid(reward_stage) else fight.obstacles):actors.append')
edit('scripts/main.gd',' toast.visible=toast_time>0 and toast_state==state',' toast.visible=toast_time>0 and toast_state==state\n if is_instance_valid(room_interact_button):room_interact_button.visible=state=="service_walk" and is_instance_valid(reward_stage) and reward_stage.near() and not cinematic.active')
edit('scripts/main.gd','["playing","paused","build","route","service","talent","preview","select"]','["playing","paused","build","route","service","service_walk","room_paused","talent","preview","select"]')
edit('scripts/main.gd',' elif s.state=="service":services()',' elif s.state in ["service","service_walk","room_paused"]:\n  enter_reward_stage(false)\n  if s.state=="service":services()')
edit('scripts/main.gd',' cinematic.font=font',' cinematic.duration=1.4 if boss else .85\n cinematic.font=font')
print('Seven separate reward room scenes; 0.85 second transitions and physical interaction.')
