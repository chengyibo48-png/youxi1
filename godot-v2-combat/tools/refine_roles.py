from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[1]
def patch(name,old,new):
 p=ROOT/name;s=p.read_text(encoding='utf-8-sig')
 if old not in s:raise RuntimeError(name+': '+old[:100])
 p.write_text(s.replace(old,new,1),encoding='utf-8')

patch('scripts/combat.gd','var role_step_dt: float=0.0','var role_step_dt: float=0.0\nvar visible_bounds: Rect2=Rect2(-100000,-100000,200000,200000)')
patch('scripts/combat.gd',' var out: Array = ["melee"] if weapon.mode == "slash" else ["projectile"]',' var out: Array = ["melee"] if weapon.mode == "slash" else ["projectile"]\n if hero.get("id","")=="tangseng":out.append("field");out.append("melee")\n if "field_source" in out:out.append("field")')
patch('scripts/combat.gd',' if "pull" in active_effects:out.append("pull_source")',' if "field_source" in out and "field" not in out:out.append("field")\n if "pull" in active_effects:out.append("pull_source")')
patch('scripts/combat.gd',' if shield_before>0 and player.shield<=0',' if blocked>0:feedback.emit("shield",player.pos,blocked)\n if dmg<=0:return\n if shield_before>0 and player.shield<=0')
patch('scripts/combat.gd',' if e.kind=="guard":',' if hero.id=="bajie" and source=="heavy" and owned.has("bajie_t0"):\n  dmg+=float(player.get("retaliation",0));player.retaliation=0.0\n if e.kind=="guard":')
patch('scripts/combat.gd',' if hero.id=="bajie" and dmg>0:resource(minf(12,dmg*.4))',' if hero.id=="bajie" and dmg>0:\n  resource(minf(12,dmg*.4))\n  if owned.has("bajie_t0"):player.retaliation=minf(40,float(player.get("retaliation",0))+dmg*.5)')

patch('scripts/role_combat.gd','c.player.seals.append({"pos":position,"radius":radius,"life":7.0})','c.player.seals.append({"pos":position,"radius":radius*(1.5 if c.has("domain") else 1),"life":7.0*(1+c.value("field_time"))})\n if c.owned.has("tangseng_t0"):c.player.shield=minf(100,c.player.shield+4)')
patch('scripts/role_combat.gd','if c.hero.id=="tangseng" and c.has("pulse"):','if c.hero.id=="tangseng" and (c.has("pulse") or c.owned.has("tangseng_t4")):')
patch('scripts/role_combat.gd','c.player.still>1.0:c.resource(-dt*4)','c.player.still>1.0:c.resource(-dt*4)\n if c.hero.id=="bailongma" and c.owned.has("bailongma_t0") and movement.length()>.1 and c.time>=c.player.get("wake_at",0):\n  c.player.wake_at=c.time+.6;c.add_field(c.player.pos,32,5,1.1,"water")')
patch('scripts/role_combat.gd','  if a.heavy:\n   for seal in c.player.seals:', '  if a.heavy:\n   if c.owned.has("tangseng_t5"):c.resource(c.player.seals.size()*3)\n   for seal in c.player.seals:')
patch('scripts/role_combat.gd','   if a.combo>=2:place_seal', '   if c.owned.has("tangseng_t2") and a.combo==2:\n    for side in [-1,1]:c.shoot(pos,d.rotated(side*.45),a.damage*.4,{"trigger":false,"source":"交错法印","return":false,"visual":"bead","role":"tangseng"})\n   if a.combo>=2:place_seal')
patch('scripts/role_combat.gd','e.marks*.2*(1+c.value("sand_damage"))','e.marks*.2*(1+c.value("sand_damage")+c.value("hero_sand_damage"))')
patch('scripts/role_combat.gd','if c.hero.id=="wukong":c.resource(4 if a.combo==3 else 2)','''if c.hero.id=="wukong":
    c.resource(4 if a.combo==3 else 2)
    if c.owned.has("wukong_t4") and a.combo==3:e.mark=2
    if c.owned.has("wukong_t5") and a.heavy:c.resource(4)
    if c.owned.has("wukong_t1") and a.combo==3 and not a.heavy and c.player.delayed.size()<32:
     c.player.delayed.append({"kind":"clone","left":.2,"pos":origin+d.orthogonal()*45,"action":a.duplicate(true)})''')
patch('scripts/role_combat.gd','elif c.hero.id=="shaseng" and not a.heavy:e.marks=mini(6,e.marks+1);c.resource(2)','elif c.hero.id=="shaseng" and not a.heavy:e.marks=mini(6,e.marks+(2 if c.owned.has("shaseng_t0") else 1));c.resource(5 if c.owned.has("shaseng_t5") and a.combo==3 else 2)\n   elif c.hero.id=="bajie" and c.owned.has("bajie_t3") and a.combo==3:c.heal(2)')
patch('scripts/role_combat.gd',' else:e.root=maxf(e.root,duration*(1+c.value("hero_control_time")))',' else:e.root=maxf(e.root,duration*(1+c.value("hero_control_time")))') if False else None
patch('scripts/role_combat.gd','"sand":c.fields.append({"pos":pos,"radius":130.0,"damage":12*power,"life":5.0,"kind":"sand","tick":0.0,"velocity":d*55})','"sand":\n     var previous_count: int=c.fields.size();c.add_field(pos,130,12*power,5,"sand")\n     if c.fields.size()>previous_count:c.fields.back().velocity=d*55')
patch('scripts/role_combat.gd','for i in 5:c.shoot(pos,d.rotated((i-2)*.22),18*power','for i in 5+int(round(c.value("hero_extra_skill_shots")*10)):c.shoot(pos,d.rotated((i-2)*.22),18*power')
patch('scripts/role_combat.gd','"life":4.0,"cd":0.0,"damage":15.0','"life":4.0*(1+c.value("hero_summon_time")),"cd":0.0,"damage":15.0')
patch('scripts/role_combat.gd','c.player.shield+25)', 'c.player.shield+25*(1+c.value("hero_shield_gain")))')
patch('scripts/role_combat.gd','else .75),e.radius)', 'else minf(.9,.75+c.value("hero_pull_power"))),e.radius)')
patch('scripts/role_combat.gd','c.boost_until=c.time+4','c.boost_until=c.time+4*(1+c.value("hero_buff_time"))')
patch('scripts/role_combat.gd','c.player.precise_until=c.time+2\n    "waterwall":', 'c.player.precise_until=c.time+2\n     if c.owned.has("bailongma_t3"):c.player.recall_charge=mini(3,int(c.player.get("recall_charge",0))+1);c.player.recall_until=c.time+2\n    "waterwall":')

patch('scripts/main.gd','if build_index==1:\n  skill_ids=[hero+"_s1",hero+"_s4"]','if build_index==1:\n  skill_ids=[hero+"_s1",hero+"_s4"]\n  if hero=="wukong":skill_ids=[hero+"_s0",hero+"_s4"]\n  if hero=="shaseng":skill_ids=[hero+"_s0",hero+"_s3"]')
patch('scripts/main.gd','if build_index>=0:\n  for id', 'if build_index==0 and hero=="shaseng":skill_ids=[hero+"_s1",hero+"_s5"];sync_sources()\n if build_index>=0:\n  for id')
patch('scripts/main.gd','''   if not fight.take(id):
    var talent: Dictionary=db.tables.talents.filter(func(t):return t.hero==hero).front()
    fight.take(talent.id)''','''   if not fight.take(id):push_error("无效构筑候选："+hero+" / "+id)''')
patch('scripts/main.gd',' var quick=menu_grid(2)',''' text("招式阶段：起手不可闪避取消；有效命中后可取消收招。重击按住蓄力，松开释放。",15)
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
 var quick=menu_grid(2)''')
patch('scripts/main.gd','  fight.update(dt,movement)','''  var current_action: Dictionary=fight.player.get("action",{})
  if not current_action.is_empty() and current_action.elapsed<current_action.windup:
   var difference: float=current_action.direction.angle_to(aim)
   current_action.direction=current_action.direction.rotated(clampf(difference,-dt*2.5,dt*2.5))
   fight.player.attack_direction=current_action.direction;fight.player.facing=current_action.direction
  fight.visible_bounds=Rect2(-camera_offset()+Vector2(0,115),Vector2(1280,535))
  fight.update(dt,movement)''')
patch('scripts/main.gd','"ready":switch_cd<=0,"cooldown":switch_cd','"ready":switch_cd<=0 and fight.can_switch(),"cooldown":switch_cd')
patch('scripts/main.gd',' var action: String="蓄力 %.0f%%"', ' var action: String="蓄力 %.0f%%"') if False else None
patch('scripts/main.gd',' battle_hud.present({"title":fight.hero.name', ''' if charging:action+=" · 释放后"+str(int(maxf(0,fight.player.resource-20))) if hero_id in ["wukong","bajie","bailongma"] and fight.player.resource>=20 else " · 未强化"
 elif not fight.player.get("action",{}).is_empty():action+=" · "+{"windup":"起手","active":"命中","recovery":"收势"}.get(fight.player.get("action_phase","windup"),"")
 battle_hud.present({"marked":mini(6,fight.enemies.reduce(func(n,e):return n+int(e.marks),0)),"title":fight.hero.name''')
patch('scripts/main.gd','for key in ["slash","bolt","field","orbit","return","heavy","impact","hit","crit","hurt","dash","skill","ultimate","break","pickup","warning"]','for key in ["slash","bolt","field","orbit","return","heavy","impact","hit","crit","hurt","dash","skill","ultimate","break","pickup","warning","guard","shield","wall","empty"]')
patch('scripts/main.gd','var key: String=fight.weapon.get("mode","slash") if kind=="swing" else kind','var key: String={"wukong":"slash","tangseng":"field","bajie":"heavy","shaseng":"return","bailongma":"bolt"}.get(hero_id,"slash") if kind=="swing" else kind')
patch('scripts/main.gd',' var voice: AudioStreamPlayer=audio_players[audio_cursor];audio_cursor=(audio_cursor+1)%audio_players.size()', ''' var important: bool=kind in ["warning","ultimate","break"]
 var begin: int=12 if important else 0
 var count: int=4 if important else 12
 var chosen: int=-1
 for offset in count:
  var index: int=begin+(audio_cursor+offset)%count
  if not audio_players[index].playing:chosen=index;break
 if chosen<0 and not important:return
 if chosen<0:chosen=begin+audio_cursor%count
 var voice: AudioStreamPlayer=audio_players[chosen];audio_cursor+=1''')
patch('scripts/main.gd','func feedback(type: String,pos: Vector2,value: float) -> void:\n play_sound(type)','func feedback(type: String,pos: Vector2,value: float) -> void:\n play_sound(type)\n if type=="phase":\n  fight.bullets=fight.bullets.filter(func(b):return b.get("friendly",true));fight.hazards=[];fight.invuln=maxf(fight.invuln,1.2)\n  notify("首领转势 · 调整站位")')
patch('scripts/main.gd','  if not held:input_release_guard=false','  if not held:input_release_guard=false') if False else None
patch('scripts/main.gd','  if hitstop>0:hitstop=maxf(0,hitstop-dt);queue_redraw();return','''  if hitstop>0:
   hitstop=maxf(0,hitstop-dt)
   input_attack=maxf(0,input_attack-dt);input_dash=maxf(0,input_dash-dt);heavy_buffer=maxf(0,heavy_buffer-dt)
   if not pending_command.is_empty():
    pending_command.left-=dt
    if pending_command.left<=0:pending_command={}
   queue_redraw();return''')
patch('scripts/main.gd',' if saved.is_empty():', ' if saved.is_empty():') if False else None
patch('scripts/main.gd',' home()\nfunc setup_input()', ' home()\n if saved.has("migration_note"):notify(saved.migration_note)\nfunc setup_input()')

patch('scripts/enemy_controller.gd','func begin(c, e: Dictionary, action: String) -> void:\n', '''func begin(c, e: Dictionary, action: String) -> void:
 if not c.visible_bounds.grow(40).has_point(e.pos) or not c.geometry.visible(e.pos,c.player.pos):e.cooldown=.3;return
 var attackers: int=c.enemies.filter(func(other):return other.get("telegraph",0)>0 or other.get("rush_time",0)>0).size()
 if attackers>=3 or action=="rush" and c.enemies.any(func(other):return other.get("rush_time",0)>0 or other.get("attack","")=="rush" and other.get("telegraph",0)>0):e.cooldown=.25;return
''')
patch('scripts/enemy_controller.gd','e.telegraph=.8 if action', 'e.telegraph=.95 if e.attack_count==0 else .8 if action')
patch('scripts/boss_controller.gd',' if c.hazards.size()>=24:return',''' if c.hazards.size()>=24:return
 var safe: bool=false
 var bounds: Rect2=c.arena_bounds().grow(-30)
 for i in 12:
  var candidate: Vector2=c.player.pos+Vector2.RIGHT.rotated(i*TAU/12)*180
  if not bounds.has_point(candidate) or not c.geometry.visible(c.player.pos,candidate,20):continue
  if candidate.distance_to(center)<=radius+25:continue
  if c.hazards.any(func(h):return h.kind!="laser" and h.life>0 and candidate.distance_to(h.pos)<=h.radius+25):continue
  safe=true;break
 if not safe and kind not in ["summon","blink","fog"]:return''')
patch('scripts/combat.gd','  if e.kind!="dummy":enemy_ai.update(self,e,dt)', '  if e.kind!="dummy":enemy_ai.update(self,e,dt)') if False else None
patch('scripts/combat.gd','func spawn(kind: String, position: Vector2, tier: int, boss_name: String = "") -> Dictionary:\n', '''func spawn(kind: String, position: Vector2, tier: int, boss_name: String = "") -> Dictionary:
 if kind!="dummy" and position.distance_to(player.pos)<120:
  position=clamp_actor(player.pos+(position-player.pos).normalized()*180 if position.distance_to(player.pos)>1 else player.pos+Vector2(180,0),40)
 if kind!="dummy" and position.distance_to(exit_position())<100:position=clamp_actor(position+Vector2(-150,0),40)
''')
patch('scripts/combat.gd','   if b.life<=0:continue','   if b.life<=0:\n    if b.get("friendly",true):feedback.emit("wall",b.pos,0)\n    continue')

# Synchronize descriptions with the new behavior; IDs and pool sizes remain stable.
skill_descriptions={
 'wukong':['两个分身依次复现上一招，不重复产生命中触发','腾跃前进，落点预示后追加落棍','控制附近小妖；首领减速并积累破势','棍撑突进，沿途每目标命中一次','识破前方敌人的弱点，强化后续攻击','短暂格棍反击，随后护棍绕身'],
 'tangseng':['连续念诵五次，回复生命并净化身边妖氛','暂时束缚小妖，化出短暂护法；首领仅受破势','连接法印形成光束；不足两印时先补印','落下净土法印与回复领域，重击可以引爆法印','结印反制一次攻击，并在脚下落印','念珠连线牵引前方敌人；首领牵引减弱'],
 'bajie':['架耙格挡一次攻击，积累战意并反击','后撤后朝反方向重耙，适合追兵近身时使用','前方三处依次震地，预示对应实际爆发','持续冲撞前进，沿途聚怪并造成伤害','以窄长勾耙拉回前方敌人，首领只轻微位移','消费技能战意回复生命并获得少量护盾'],
 'shaseng':['释放缓慢向前移动的流沙领域，持续布印','月牙刃往返，去程取印、回程搬印','扇形沙刃命中布印，子弹不递归触发','束缚附近有印记的敌人，首领转为减速破势','与上一处沙影换位；初次使用建立沙影','消费附近敌人的印记，按层数逐次引爆'],
 'bailongma':['沿前进路线掀起移动浪潮','化龙高速穿行，命中沿途目标并短暂强化','转向龙息由前方五条水流覆盖区域','侧闪召回御剑，强化下一次追击','沿剑路展开三段水幕，拦截敌方投射物','追击附近被穿身标记的目标；无标记时发射追踪剑']}
for table in ['skills','ultimates']:
 p=ROOT/f'data/{table}.json';data=json.loads(p.read_text(encoding='utf-8-sig'))
 if table=='skills':
  for entry in data:entry['description']=skill_descriptions[entry['hero']][int(entry['id'].rsplit('s',1)[1])]
 else:
  names={'giant':('巨棍镇场','沿前方长直线造成重击与高破势'),'avatars':('群分身接力','六个分身依次复现上一招'),'purification':('多层净土','落下三枚大法印并展开回复领域'),'chant':('经文洪流','沿前方逐段爆发经文法印'),'marshal':('天蓬重砸','范围重砸、护盾与短暂格挡'),'quakes':('战意狂攻','进入强化状态并返还部分战意'),'sandstorm':('流沙葬阵','大范围流沙持续布印'),'sandburst':('月刃绞击','六枚往返月刃搬运印记'),'dragonflight':('龙形贯穿','高速化龙贯穿，沿途每目标命中一次'),'tide':('御剑归潮','八枚御剑往返，并强化回收追击')}
  for entry in data:entry['name'],entry['description']=names[entry['effect']]
 p.write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')
print('Applicability, role feedback, UI and encounter fairness refined.')
