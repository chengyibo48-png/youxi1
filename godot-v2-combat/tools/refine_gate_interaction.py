from pathlib import Path
p=Path(__file__).resolve().parents[1]/'scripts/main.gd';s=p.read_text(encoding='utf-8')
s=s.replace('  if state=="service_walk" and is_instance_valid(reward_stage) and reward_stage.near():services())','  if gate_ready():cross_gate()\n  elif state=="service_walk" and is_instance_valid(reward_stage) and reward_stage.near():services())',1)
s=s.replace('   if is_instance_valid(reward_stage) and reward_stage.near():services();get_viewport().set_input_as_handled()','   if gate_ready():cross_gate();get_viewport().set_input_as_handled()\n   elif is_instance_valid(reward_stage) and reward_stage.near():services();get_viewport().set_input_as_handled()',1)
s=s.replace(' if state!="playing":return\n if event is InputEventKey and event.echo:return',' if state!="playing":return\n if event is InputEventKey and event.echo:return\n if event.is_action_pressed("interact") and gate_ready():cross_gate();get_viewport().set_input_as_handled();return',1)
old='''  if fight.player.pos.distance_to(fight.exit_position())<65:
   if room_id not in visited:visited.append(room_id)
   new_route();return
''';assert old in s;s=s.replace(old,'',1)
s=s.replace('    elif fight.player.pos.distance_to(fight.exit_position())<65:room_reward()','    elif gate_ready():pass # The player confirms at the physical exit instead of leaving accidentally.',1)
old=' if is_instance_valid(room_interact_button):room_interact_button.visible=state=="service_walk" and is_instance_valid(reward_stage) and reward_stage.near() and not cinematic.active'
new=''' if is_instance_valid(room_interact_button):
  room_interact_button.visible=(gate_ready() or state=="service_walk" and is_instance_valid(reward_stage) and reward_stage.near()) and not cinematic.active
  room_interact_button.text="继续西行 · G / Enter / 手柄确认" if gate_ready() else "交互 · G / Enter / 手柄确认"''';assert old in s;s=s.replace(old,new,1)
s+='''\nfunc gate_ready() -> bool:
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
''';p.write_text(s,encoding='utf-8')
print('Physical exits require confirmation; entry cinematics and visited-room guard retained.')
