from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]

def edit(name, old, new):
    p = ROOT / name
    text = p.read_text(encoding='utf-8-sig')
    if old not in text:
        raise RuntimeError(f'Patch anchor missing: {name}: {old[:80]}')
    p.write_text(text.replace(old, new, 1), encoding='utf-8')

edit('scripts/combat.gd', 'var passive_relic=""', 'var role=preload("res://scripts/role_combat.gd").new()\nvar role_step_dt: float=0.0\nvar passive_relic=""')
edit('scripts/combat.gd', ' motion.reset(player)\n clear_room()', ' motion.reset(player)\n role.reset(self)\n clear_room()')
edit('scripts/combat.gd', 'func attack(direction:', 'func legacy_attack(direction:')
edit('scripts/combat.gd', 'func skill(definition:', 'func legacy_skill(definition:')
edit('scripts/combat.gd', 'func ultimate(definition:', 'func legacy_ultimate(definition:')
edit('scripts/combat.gd', 'func dash(direction: Vector2) -> bool:\n if dash_stock<=0 or dash_time>0:return false', '''func attack(direction: Vector2, heavy: bool=false, charge: float=0.0) -> bool:
 return role.begin(self,"attack",direction,{},heavy,charge)
func skill_reason(definition: Dictionary, slot: int) -> String:
 return role.skill_reason(self,definition,slot)
func skill(definition: Dictionary, slot: int, direction: Vector2, branch: int=0) -> bool:
 if skill_reason(definition,slot)!="":return false
 var payload: Dictionary=definition.duplicate(true);payload.branch=branch
 if not role.begin(self,"skill",direction,payload):return false
 skill_cd[slot]=definition.cooldown*maxf(.35,1-value("cooldown"))*(1.2 if branch==1 else .8 if branch==2 else 1)
 cast_haste_until=time+3
 return true
func ultimate(definition: Dictionary, direction: Vector2=Vector2.RIGHT) -> bool:
 if definition.is_empty() or definition.get("hero","")!=hero.id:return false
 return role.begin(self,"ultimate",direction,definition)
func can_switch() -> bool:
 return not role.busy(self) and player.get("skill_left",0)<=0 and dash_time<=0
func dash(direction: Vector2) -> bool:
 if dash_stock<=0 or dash_time>0 or not role.can_cancel(self):return false
 player.action={};player.action_phase="idle"''')
edit('scripts/combat.gd', 'dash_time=.23;invuln=.18;attack_cd=0', 'dash_time=preload("res://scripts/character_combat_kit.gd").for_hero(hero.id).dash_duration;invuln=minf(.18,dash_time);attack_cd=0')
edit('scripts/combat.gd', 'func hurt(amount: float, source: String) -> void:\n', '''func hurt(amount: float, source: String) -> void:
 if time<player.get("guard_until",0):
  player.guard_until=0;resource(15);area(player.pos,140,35,"格挡反击",false)
  role.art(self,"guard",player.pos,player.get("facing",Vector2.RIGHT),140,.5)
  feedback.emit("guard",player.pos,0);invuln=.2;return
''')
edit('scripts/combat.gd', ' if invuln>0:\n', ' if invuln>0:\n  if dash_time>0 and hero.id=="wukong" and time>=player.get("dodge_reward_at",0):player.precise_until=time+2;player.dodge_reward_at=time+1;resource(6)\n')
edit('scripts/combat.gd', ' player.hp=maxf(0,player.hp-dmg);player.last_hit=source;invuln=.6', ''' if hero.id=="bajie" and dmg>0:resource(minf(12,dmg*.4))
 player.hit_history.append({"source":source,"damage":dmg,"shield":blocked,"resource":player.resource,"time":time})
 if player.hit_history.size()>6:player.hit_history.pop_front()
 player.hp=maxf(0,player.hp-dmg);player.last_hit=source;invuln=.6''')
edit('scripts/combat.gd', ' player.room_cleared=false;player.skill_left=0.0;player.attack_left=0.0;player.lunge=Vector2.ZERO;player.velocity=Vector2.ZERO\n enemies=', ' player.room_cleared=false;player.skill_left=0.0;player.attack_left=0.0;player.lunge=Vector2.ZERO;player.velocity=Vector2.ZERO\n player.action={};player.delayed=[];player.seals=[]\n enemies=')
edit('scripts/combat.gd', ' motion.step(self,dt,movement,speed,dash_remaining)', ' role_step_dt=dt\n motion.step(self,dt,movement,speed,dash_remaining)\n role.tick(self,dt,movement)')
edit('scripts/combat.gd', ' if hero.id=="tangseng" and movement.length()<.05 and dash_time<=0:resource(dt)\n if hero.id=="bailongma" and movement.length()>.1:resource(.8*dt)\n', '')
edit('scripts/combat.gd', '  var next: Vector2=b.pos+b.dir*b.speed*dt', '  var previous_position: Vector2=b.pos\n  var next: Vector2=b.pos+b.dir*b.speed*dt')
edit('scripts/combat.gd', '    if b.pos.distance_to(e.pos)<e.radius+b.radius:', '    if Geometry2D.get_closest_point_to_segment(e.pos,previous_position,b.pos).distance_to(e.pos)<e.radius+b.radius:')
edit('scripts/combat.gd', '     b.hit.append(e.uid);hit(e,b.damage,b.source,b.trigger)', '''     b.hit.append(e.uid);hit(e,b.damage,b.source,b.trigger)
     if b.get("apply_marks",false) or b.get("role","")=="shaseng":
      if b.get("carry_marks",false) and b.back:
       if b.get("carried",0)>0:e.marks=mini(6,e.marks+int(b.carried));b.carried=0
      elif b.get("carry_marks",false):b.carried=mini(6,int(b.get("carried",0))+int(e.marks));e.marks=0
      else:e.marks=mini(6,e.marks+1)
     if b.get("role","")=="bailongma":e.dragon_mark=time+3''')
edit('scripts/combat.gd', '  elif b.pos.distance_to(player.pos)<18:', '  elif Geometry2D.get_closest_point_to_segment(player.pos,previous_position,b.pos).distance_to(player.pos)<18+b.radius:')
edit('scripts/combat.gd', 'hit(e,f.damage,"领域",true,5)', 'hit(e,f.damage,"领域",false,5)')
edit('scripts/combat.gd', '{"trigger":true,"source":"协战","return":false}', '{"trigger":not s.get("non_recursive",false),"source":"协战","return":false}')
edit('scripts/combat.gd', ' state.sources=damage_sources', ' state.combat_version=3\n state.sources=damage_sources')
edit('scripts/combat.gd', ' if not player.has("velocity"):motion.reset(player)', ' if not player.has("velocity"):motion.reset(player)\n if not player.has("action_schema"):role.reset(self)')

edit('scripts/action_motion.gd', ' var acceleration: float=speed/(.045 if movement.length()<.05 else .055)', ' var kit=preload("res://scripts/character_combat_kit.gd").for_hero(c.hero.id)\n var acceleration: float=speed/(kit.braking_time if movement.length()<.05 else kit.acceleration_time)')
edit('scripts/action_motion.gd', ' var desired: Vector2=player.velocity*(.72 if player.attack_heavy else .9) if player.attack_left>0 else player.velocity', ' var movement_factor: float=.30 if c.hero.id=="bajie" else .45 if c.hero.id=="tangseng" else .65 if c.hero.id=="shaseng" else .82\n var desired: Vector2=player.velocity*movement_factor if player.attack_left>0 else player.velocity')
edit('scripts/action_motion.gd', 'c.dash_direction*950*dash_delta', 'c.dash_direction*kit.dash_speed*dash_delta')

edit('scripts/main.gd', 'var character_pose=preload("res://scripts/character_pose.gd").new()', 'var character_pose=preload("res://scripts/layered_rig.gd").new()\nvar role_art=preload("res://scripts/role_presentation.gd").new()\nvar pending_command: Dictionary={}\nvar input_release_guard: bool=false')
edit('scripts/main.gd', '"mouse_keys":{}}', '"mouse_keys":{},"hold_attack":false,"reduced_flash":false,"numbers":true,"shake_strength":.5}')
edit('scripts/main.gd', 'func training_lab() -> void:', '''func role_demo(hero: String, build_index: int=-1) -> void:
 if mode!="training":return
 hero_id=hero;weapon_ids=[hero+"_w0",hero+"_w1"];slot=0
 skill_ids=[hero+"_s0",hero+"_s2"];ultimate_id=hero+"_u0";branches=[0,0]
 if build_index==1:
  skill_ids=[hero+"_s1",hero+"_s4"]
  if hero in ["shaseng","bailongma"]:slot=1
 elif build_index==2:skill_ids=[hero+"_s3",hero+"_s5"];ultimate_id=hero+"_u1"
 fight.reset(db.find("heroes",hero),db.find("weapons",weapon_ids[slot]));sync_sources()
 fight.configure_arena(Vector2(2400,1400));fight.create_layout("training","forest")
 if build_index>=0:
  for id in preload("res://scripts/build_modifier.gd").BUILDS[hero][build_index][1]:
   if not fight.take(id):
    var talent: Dictionary=db.tables.talents.filter(func(t):return t.hero==hero).front()
    fight.take(talent.id)
 fight.player.resource=100;lock_uid=-1;reset_inputs();demo_dummies()
func role_lab() -> void:
 state="lab";reset_inputs()
 show_panel("五行试招 · 五角色重做","每人六神通、两绝技、三种构筑。基础试招不携带修行。")
 var rows=menu_grid(2)
 for hero in db.tables.heroes:
  button(hero.name+" · 基础招式",func():role_demo(hero.id),false,hero.id,rows)
  var kit=preload("res://scripts/character_combat_kit.gd").for_hero(hero.id)
  text(kit.resource_rule,15)
  for index in 3:
   var build: Array=preload("res://scripts/build_modifier.gd").BUILDS[hero.id][index]
   button(hero.name+" · "+build[0]+"\n"+build[2]+" / "+build[3],func():role_demo(hero.id,index))
 button("返回试招台",training_lab,false,"",footer)
func training_lab() -> void:''')
edit('scripts/main.gd', ' text("当前 · "+fight.weapon.name', ' button("五角色 · 基础招式与15种构筑",role_lab)\n text("当前 · "+fight.weapon.name')
edit('scripts/main.gd', 'charging=false;charge=0;input_attack=0;input_dash=0;hitstop=0;heavy_buffer=0;afterimages=[]', 'charging=false;charge=0;input_attack=0;input_dash=0;hitstop=0;heavy_buffer=0;afterimages=[];pending_command={};input_release_guard=true')
edit('scripts/main.gd', ' if state!="playing":return\n if event.is_action_pressed("map"):', ' if state!="playing":return\n if input_release_guard:return\n if event is InputEventKey and event.echo:return\n if event.is_action_pressed("map"):')
edit('scripts/main.gd', 'if event.is_action_pressed("attack"):input_attack=.18', 'if event.is_action_pressed("attack"):pending_command={};heavy_buffer=0;input_dash=0;input_attack=.12')
edit('scripts/main.gd', 'if event.is_action_pressed("dash"):input_dash=.16', 'if event.is_action_pressed("dash"):pending_command={};input_attack=0;heavy_buffer=0;input_dash=.12')
edit('scripts/main.gd', 'if event.is_action_pressed("heavy"):charging=true;charge=0', 'if event.is_action_pressed("heavy"):pending_command={};input_attack=0;input_dash=0;charging=true;charge=0')
edit('scripts/main.gd', 'heavy_buffer=.22;heavy_power=', 'heavy_buffer=.12;heavy_power=')
edit('scripts/main.gd', ' if event.is_action_pressed("skill1"):fight.skill(db.find("skills",skill_ids[0]),0,aim,int(branches[0]))\n if event.is_action_pressed("skill2"):fight.skill(db.find("skills",skill_ids[1]),1,aim,int(branches[1]))', ''' for index in 2:
  if event.is_action_pressed("skill"+str(index+1)):
   input_attack=0;input_dash=0;heavy_buffer=0;charging=false
   pending_command={"slot":index,"left":.12,"aim":aim}''')
edit('scripts/main.gd', ' if event.is_action_pressed("ultimate") and not fight.ultimate(db.find("ultimates",ultimate_id),aim):notify("绝技需要80资源")', ''' if event.is_action_pressed("ultimate"):
  pending_command={};input_attack=0;input_dash=0;heavy_buffer=0;charging=false
  if not fight.ultimate(db.find("ultimates",ultimate_id),aim):notify("绝技条件：资源不足或招式尚未收势")''')
edit('scripts/main.gd', 'if event.is_action_pressed("switch") and switch_cd<=0:', 'if event.is_action_pressed("switch") and switch_cd<=0 and fight.can_switch():')
edit('scripts/main.gd', 'switch_cd=.6', 'switch_cd=.35')
edit('scripts/main.gd', ' if what==NOTIFICATION_APPLICATION_FOCUS_OUT', ' if what==NOTIFICATION_APPLICATION_FOCUS_OUT:reset_inputs()\n if what==NOTIFICATION_APPLICATION_FOCUS_OUT')
edit('scripts/main.gd', '  if cinematic.active:queue_redraw();return', '''  if input_release_guard:
   var held: bool=false
   for action in ["attack","heavy","dash","skill1","skill2","ultimate","relic","switch"]:
    if Input.is_action_pressed(action):held=true
   if not held:input_release_guard=false
  if cinematic.active:queue_redraw();return''')
edit('scripts/main.gd', '(Input.is_action_pressed("attack") or input_attack>0)', '((settings.get("hold_attack",false) and Input.is_action_pressed("attack") and not input_release_guard) or input_attack>0)')
edit('scripts/main.gd', '  fight.update(dt,movement)', '''  if not pending_command.is_empty():
   var index: int=pending_command.slot
   if fight.skill(db.find("skills",skill_ids[index]),index,pending_command.aim,int(branches[index])):pending_command={}
   else:
    pending_command.left-=dt
    if pending_command.left<=0:notify(fight.skill_reason(db.find("skills",skill_ids[index]),index));pending_command={}
  fight.update(dt,movement)''')
edit('scripts/main.gd', 'var ready: bool=cd<=0 and (fight.player.resource>=skill.cost or (fight.has("blood") and fight.player.hp>skill.cost+1))', 'var skill_status: String=fight.skill_reason(skill,index)\n  var ready: bool=skill_status==""')
edit('scripts/main.gd', '"status":"%.1fs"%cd if cd>0 else "就绪" if ready else "资源不足"', '"status":"就绪" if ready else skill_status')
edit('scripts/main.gd', '"maximum":.6', '"maximum":.35')
edit('scripts/main.gd', '"resource_name":fight.hero.resource', '"role_id":hero_id,"resource_rule":preload("res://scripts/character_combat_kit.gd").for_hero(hero_id).resource_rule,"resource_name":fight.hero.resource')
edit('scripts/main.gd', 'for key in ["effects","shake"]:', 'for key in ["effects","shake","hold_attack","reduced_flash","numbers"]:')
edit('scripts/main.gd', '{"effects":"技能特效","shake":"镜头震动"}', '{"effects":"技能特效","shake":"镜头震动","hold_attack":"长按连续普攻","reduced_flash":"降低闪光","numbers":"伤害数字"}')
edit('scripts/main.gd', 'for n in numbers:draw_string', 'for n in numbers if settings.get("numbers",true) else []:draw_string')
edit('scripts/main.gd', 'if type in ["hurt","impact","break","ultimate"] and settings.shake:shake=maxf(shake,6 if type=="ultimate" else 3)', 'if type in ["hurt","impact","break","ultimate"] and settings.shake:shake=maxf(shake,(6 if type=="ultimate" else 3)*float(settings.get("shake_strength",.5)))')
edit('scripts/main.gd', '   if v.kind=="spell":spell_art.draw(self,v)', '   if v.kind=="role_fx":role_art.draw(self,v,settings.get("reduced_flash",false))\n   elif v.kind=="spell":spell_art.draw(self,v)')
edit('scripts/main.gd', '  for cache in fight.caches:', '  role_art.draw_seals(self,fight.player.get("seals",[]),fight.time)\n  for cache in fight.caches:')
edit('scripts/main.gd', '  for b in fight.bullets:\n   draw_line', '  for b in fight.bullets:\n   if role_art.draw_projectile(self,b):continue\n   draw_line')
start=(ROOT/'scripts/main.gd').read_text(encoding='utf-8')
left=start.index('func draw_hero(');right=start.index('func draw_enemy(',left)
start=start[:left]+'''func draw_hero(pos: Vector2,tint: Color) -> void:
 var offset: Vector2=camera_offset()+Vector2(sin(clock*23),cos(clock*31))*shake
 ellipse(pos+Vector2(0,14),Vector2(25 if hero_id=="bajie" else 20,6),Color(0,0,0,.22)*tint)
 var index: int=0
 for i in db.tables.heroes.size():
  if db.tables.heroes[i].id==hero_id:index=i
 character_pose.draw(self,index,fight.player,tint,fight.time,Transform2D(0,offset+pos),hero_id)
 draw_set_transform(offset)
''' + start[right:]
(ROOT/'scripts/main.gd').write_text(start,encoding='utf-8')
edit('scripts/main.gd', ' if not storage.valid_payload({"run":s}):return false', ' if not storage.valid_payload({"run":s}):return false\n if s.combat.get("combat_version",0)!=3:return false')
edit('scripts/main.gd', ' show_panel("演示 · "+t.name,t.description)', ' show_panel("演示 · "+t.name,t.description+"\\n"+preload("res://scripts/build_modifier.gd").description(hero_id,t.id))')
edit('scripts/main.gd', 'func pause_panel() -> void:\n', 'func pause_panel() -> void:\n reset_inputs()\n')
edit('scripts/main.gd', ' for source in fight.damage_sources:text', ' for record in fight.player.get("hit_history",[]):text("近期受击：%s · 生命损失%d · 护盾抵挡%d · 当时资源%d"%[record.source,record.damage,record.shield,record.resource],15)\n for source in fight.damage_sources:text')
edit('scripts/save.gd', '"user://journey-v2.json"', '"user://journey-role-v3.json"')
edit('scripts/save.gd', ' last_error = "存档不存在或损坏，已保留原文件。"', ''' if location==PATH and not FileAccess.file_exists(location):
  var legacy=JSON.parse_string(FileAccess.get_file_as_string("user://journey-v2.json")) if FileAccess.file_exists("user://journey-v2.json") else null
  if legacy is Dictionary and legacy.get("payload") is Dictionary and valid_payload(legacy.payload):
   if DirAccess.copy_absolute("user://journey-v2.json","user://journey-v2.pre-role-backup.json")==OK:
    return {"meta":legacy.payload.get("meta",{}),"settings":legacy.payload.get("settings",{}),"run":{},"migration_note":"永久进度已导入；旧战斗现场已备份，请重新开始本章。"}
 last_error = "存档不存在或损坏，已保留原文件。"''')
edit('tools/local_demo.gd', 'scene.start_demo();scene.demo_build(4);scene.training_lab()', 'scene.start_demo();scene.role_lab()')

weapons_path=ROOT/'data/weapons.json'
weapons=json.loads(weapons_path.read_text(encoding='utf-8-sig'))
for w in weapons:
    role=w['hero']; variant=int(w['id'].rsplit('w',1)[1])
    w['mode']='bolt' if role=='tangseng' else 'return' if role in ('shaseng','bailongma') and variant%2 else 'slash'
    w['description']=f"{w['name']}：专属招式变体，基础攻击随角色战斗体系执行。"
weapons_path.write_text(json.dumps(weapons,ensure_ascii=False,indent=2),encoding='utf-8')
print('Role combat integrated into independent project.')
