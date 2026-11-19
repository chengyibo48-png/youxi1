from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'scripts/role_combat.gd';s=path.read_text(encoding='utf-8')
s=s.replace('const Geometry =', 'const Weapons = preload("res://scripts/weapon_arts.gd")\nconst Abilities = preload("res://scripts/ability_actions.gd")\nconst Geometry =',1)
start=s.index('  spec.windup=.24 if kind=="ultimate"');end=s.index(' if heavy and kind=="attack"',start)
s=s[:start]+'  Abilities.apply(spec,c.hero.id,kind,definition)\n'+s[end:]
start=s.index(' var variant: int=int(str(c.weapon.id).right(1))');end=s.index(' if c.evolution()==1',start)
s=s[:start]+' if kind=="attack":Weapons.configure(c,a)\n'+s[end:]
s=s.replace('c.player.pose_clip=spec.clip','c.player.pose_clip=a.clip')
start=s.index(' art(c,"heavy" if a.heavy else "strike",pos,d,a.reach,a.active+.18)');end=s.index(' if (a.shape=="seal"',start)
s=s[:start]+' Weapons.payload(c,a)\n'+s[end:]
s=s.replace('   elif task.kind=="chant":', '   elif task.kind=="weapon_echo":\n    c.area(task.pos,task.radius,task.damage,"兵器迟影",false);Weapons.fx(c,{"weapon_style":task.style,"weapon_id":task.weapon_id,"heavy":false,"combo":1},task.pos,task.dir,task.radius)\n   elif task.kind=="chant":')
s=s.replace(' match c.hero.id:\n  "wukong":\n   match effect:', ' Weapons.synergy(c,a)\n match c.hero.id:\n  "wukong":\n   match effect:',1)
needle=' c.synergy.trigger(c,"ultimate",d)'
s=s.replace(needle,' Weapons.synergy(c,a)\n'+needle)
path.write_text(s,encoding='utf-8')
path=root/'scripts/main.gd';s=path.read_text(encoding='utf-8');s=s.replace('var panel: PanelContainer','var homepage=preload("res://scripts/home_screen.gd").new()\nvar panel: PanelContainer',1)
s=s.replace(' layer.add_child(panel)',' layer.add_child(homepage);homepage.configure(font)\n homepage.chosen.connect(func(choice):\n  if choice=="resume":resume_run()\n  else:mode=choice;loadout())\n homepage.utility.connect(func(action):\n  if action=="settings":show_settings()\n  elif action=="merit":merit_shop()\n  else:show_import())\n layer.add_child(panel)',1)
s=s.replace('func show_panel(title: String, subtitle: String="") -> void:', 'func show_panel(title: String, subtitle: String="") -> void:\n homepage.hide()',1)
start=s.index('func home() -> void:');end=s.index('func repair_meta()',start)
s=s[:start]+'''func home() -> void:
 cinematic.skip();cinematic_input_guard=false;reset_inputs()
 state="home";panel.hide();battle_hud.hide();homepage.show()
 homepage.present(not checkpoint.is_empty(),int(meta.merit),meta.unlocked.size())
 queue_redraw()
'''+s[end:]
s=s.replace('func _draw() -> void:\n', 'func _draw() -> void:\n if state=="home":return\n',1)
s=s.replace(' battle_hud.visible=not panel.visible',' battle_hud.visible=not panel.visible and state!="home"')
path.write_text(s,encoding='utf-8')
path=root/'scripts/role_presentation.gd';s=path.read_text(encoding='utf-8')
s=s.replace('func draw_projectile(canvas: CanvasItem, shot: Dictionary) -> bool:', 'func draw_projectile(canvas: CanvasItem, shot: Dictionary) -> bool:\n if preload("res://scripts/weapon_visual.gd").projectile(canvas,shot):return true')
s=s.replace('func draw(canvas: CanvasItem, v: Dictionary, reduced_flash: bool=false) -> void:', 'func draw(canvas: CanvasItem, v: Dictionary, reduced_flash: bool=false) -> void:\n if v.effect=="weapon":\n  preload("res://scripts/weapon_visual.gd").effect(canvas,v,reduced_flash);return')
path.write_text(s,encoding='utf-8')
path=root/'scripts/layered_rig.gd';s=path.read_text(encoding='utf-8')
s=s.replace(' part(canvas,index,9,right_hand,angle-PI*.5,Vector2(30 if role in ["bajie","shaseng"] else 17,weapon_length),base,tint)', ' preload("res://scripts/weapon_visual.gd").held(canvas,player.get("weapon_id",role+"_w0"),right_hand,angle,weapon_length,base,tint)')
s=s.replace(' var bob: float=', ''' if not a.is_empty() and a.kind=="attack":
  var style: String=a.get("weapon_style","")
  pose=([.28,-1.8,.4,.7,-.3,-3.0] if style in ["extend","lance","crescent_staff"] else [.04,-.7,-1.25,.05,0.0,-1.0] if style in ["stamp","mandala","rosary","scripture","bell","sand_seal","stars"] else [.35,-1.1,.6,.5,-.2,5.0] if style in ["rake","furrow","ice_hammer","meteor"] else [-.2,-1.9,.2,.55,-.2,-2.0])
  for j in pose.size():pose[j]*=stage
 var bob: float=''')
path.write_text(s,encoding='utf-8')
path=root/'scripts/combat.gd';s=path.read_text(encoding='utf-8')
s=s.replace('  weapon=new_weapon', '  weapon=new_weapon\n  if not player.is_empty():player.weapon_id=new_weapon.id',1)
s=s.replace('"last_hit":"","evolution":0', '"last_hit":"","weapon_id":weapon.id,"evolution":0')
s=s.replace('     if b.get("role","")=="bailongma":e.dragon_mark=time+3', '     if b.get("role","")=="bailongma":e.dragon_mark=time+3\n     if b.get("frost",false):e.slow=maxf(e.slow,1.4)\n     if b.get("pull",0)>0:e.pos=geometry.move(e.pos,(player.pos-e.pos).normalized()*float(b.pull)*(.15 if e.kind=="boss" else 1.0),e.radius)')
path.write_text(s,encoding='utf-8')
path=root/'tools/local_demo.gd';s=path.read_text(encoding='utf-8').replace('scene.start_demo();scene.role_lab()','scene.home()');path.write_text(s,encoding='utf-8')
print('Independent homepage and 25 weapon kits integrated.')
