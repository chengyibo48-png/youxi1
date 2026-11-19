from pathlib import Path
import json
R=Path(__file__).resolve().parents[1]
def edit(n,o,v):
 p=R/n;s=p.read_text(encoding='utf-8');assert o in s,(n,o[:45]);p.write_text(s.replace(o,v,1),encoding='utf-8')
items=[
 ('combo_open','探路直刺','第一段转为直刺，距离增加25%，伤害降低10%',['melee'],'',1),
 ('combo_lateral','侧翼星芒','第二段主攻击伤害降低10%，附加两枚15%伤害侧翼星芒；派生不触发命中联动',['projectile'],'',1),
 ('combo_final','收式破阵','第三段消耗10资源，伤害增加25%、距离增加15%；资源不足时不强化',['melee'],'',2),
 ('combo_return','归器收式','第三段主动召回返程兵器，本段基础伤害降低20%',['projectile'],'',1),
 ('combo_anchor','二式留阵','第二段落下1.2秒墨阵，每0.6秒造成12%攻击伤害；同目标只触发一次命中联动',[],'',2),
 ('combo_aegis','三式护身','第三段消耗6资源换8护盾，护盾上限100',[],'',1),
 ('combo_stride','退进两仪','第二段后退20像素，第三段前进35像素，必须管理落脚位置',['melee'],'',1),
 ('combo_ink','收式迟影','第三段落点延迟0.35秒追加25%攻击伤害，不触发命中联动',[],'',2),
 ('combo_frugal','吐纳换息','第一段回复2资源；第三段消耗4资源使两项神通冷却各减少0.25秒',[],'',1),
 ('combo_draw','蓄式换势','第三段伤害降低20%，让下一次重击伤害增加20%；不能重复叠加',[],'',3),
 ('w_combo_vault','踏云落棍','第三段前移35像素，落点0.18秒后追加25%伤害，不触发命中联动',['melee'],'wukong',2),
 ('w_echo_staff','二式影棍','第二段身前留下延迟0.22秒的22%伤害棍影，不再派生分身',[],'wukong',3),
 ('t_combo_lotus','落印生莲','第三段在脚下留下1.8秒小莲阵；站在阵内每0.6秒回复2生命',[],'tangseng',1),
 ('t_recall_print','归珠落印','返程兵器收回时在脚下布小法印，至少间隔1.2秒',['projectile'],'tangseng',3),
 ('b_combo_guard','回耙架势','第二段命中阶段获得0.15秒格挡窗口，只能挡一次',[],'bajie',2),
 ('b_shield_spend','护甲换攻','第三段有至少8护盾时消耗8护盾，伤害提高30%；无盾不强化',[],'bajie',3),
 ('s_combo_transfer','流印牵线','第二段把附近第一个目标的一枚印搬到另一目标，需至少两敌',[],'shaseng',1),
 ('s_combo_refund','收砂还息','第三段消耗附近至多三枚流沙印，每枚回复3资源；牺牲印裂爆发',[],'shaseng',2),
 ('d_combo_recall','三式归潮','第三段召回兵器并积一层回收势，最多三层，保持2秒',['projectile'],'bailongma',1),
 ('d_tide_precision','潮势穿心','第三段资源至少50时消耗12资源，距离与伤害各增加20%',['melee'],'bailongma',3)]
p=R/'data/talents.json';data=json.loads(p.read_text(encoding='utf-8'))
for i,(id,name,description,tags,hero,tier) in enumerate(items):
 if tier>1:tags=tags+['journey_mid' if tier==2 else 'journey_late']
 item=dict(id=id,name=name,category='hero' if hero else 'shape' if i in [0,1,3,4,6,7] else 'trigger',effect=id,amount=1,description=description,tags=tags,hero=hero,exclusive='',max_level=1,unlock_stage=tier)
 if id=='t_recall_print':item['requires_any']=['return'] # Newcomers need a real return source, eligibility expanded below.
 data.append(item)
 lines=['[gd_resource type="Resource" script_class="JourneyTalent" load_steps=2 format=3]','[ext_resource type="Script" path="res://scripts/talent_resource.gd" id="1"]','[resource]','script = ExtResource("1")']
 for key,value in [('id',id),('title',name),('description',description),('category',item['category']),('effect',id)]:lines.append(key+' = '+json.dumps(value,ensure_ascii=False))
 lines+=['amount = 1','max_level = 1','tags = Array[String]('+json.dumps(tags)+')','requires_any = Array[String]('+json.dumps(item.get('requires_any',[]))+')']
 (R/'data/talents'/(id+'.tres')).write_text('\n'.join(lines)+'\n',encoding='utf-8')
 shape=f'<path d="M14 44 L25 17 34 38 48 15 M13 48 H51" fill="none"/><circle cx="{18+i%5*6}" cy="{26+i%4*5}" r="5" fill="#d3b77e"/>'
 (R/'assets/ui'/('extra-'+id+'.svg')).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><rect x="2" y="2" width="60" height="60" rx="8" fill="#233a36" stroke="#ab8b5d"/><g stroke="#d3b77e" stroke-width="3">{shape}</g></svg>',encoding='utf-8')
p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
edit('scripts/role_traits.gd',' if a.kind!="attack":return',' preload("res://scripts/combo_talents.gd").started(c,a)\n if a.kind!="attack":return')
edit('scripts/role_traits.gd','static func return_home(c, _bullet: Dictionary) -> void:','static func return_home(c, _bullet: Dictionary) -> void:\n preload("res://scripts/combo_talents.gd").return_home(c,_bullet)')
edit('scripts/role_combat.gd',' Weapons.payload(c,a)',' Weapons.payload(c,a)\n preload("res://scripts/combo_talents.gd").payload(c,a)')
edit('scripts/combat.gd','func can_take(id: String, banned: Array = []) -> bool:\n','func can_take(id: String, banned: Array = []) -> bool:\n if preload("res://scripts/combo_talents.gd").full(self):return false\n')
edit('scripts/combat.gd',' return out\nfunc can_take',' if int(player.get("progress_tier",3))>=2:out.append("journey_mid")\n if int(player.get("progress_tier",3))>=3:out.append("journey_late")\n return out\nfunc can_take')
edit('scripts/combat.gd',' return base*factor',' return base*minf(factor,3.0)')
edit('scripts/main.gd','func sync_sources() -> void:\n','func sync_sources() -> void:\n fight.player.talent_budget=0 if mode=="training" else 12 if mode=="campaign" else 24\n fight.player.progress_tier=3 if mode=="training" else 1+mini(2,int(chapter/12)) if mode=="campaign" else 1+mini(2,route_index)\n')
edit('scripts/main.gd',' if offers.is_empty():offers=db.choices(hero_id,fight.tags(),fight.owned,banned,rng)',' if preload("res://scripts/combo_talents.gd").full(fight):offers=[]\n elif offers.is_empty():offers=db.choices(hero_id,fight.tags(),fight.owned,banned,rng)')
edit('scripts/main.gd',' show_panel("选择一项修行","选前可演示。候选、重抽与禁止状态随存档保留。")',''' var spent: int=preload("res://scripts/combo_talents.gd").points(fight)
 var limit: int=int(fight.player.get("talent_budget",0))
 show_panel("选择一项修行","修行点 %d / %s · 前中后段逐步开放新修行；本章结束后重新构筑。"%[spent,str(limit) if limit>0 else "不限（试炼）"])
 if offers.is_empty():text("当前构筑已达上限或无有效候选；可将本次奖励换为铜钱。",17)''')
edit('scripts/main.gd',' rerolls-=1\n offers=', ' if preload("res://scripts/combo_talents.gd").full(fight):return\n rerolls-=1\n offers=')
edit('scripts/main.gd',' if item in ["talent","curse"] and not db.tables',' if item in ["talent","curse"] and preload("res://scripts/combo_talents.gd").full(fight):return "本段修行点已满"\n if item in ["talent","curse"] and not db.tables')
edit('scripts/main.gd',' offers=[]\n talent_panel()\n save_run()',' offers=[]\n if preload("res://scripts/combo_talents.gd").full(fight):\n  fight.player.coins+=8;finish_choice();return\n talent_panel()\n save_run()')
edit('scripts/main.gd','fight.player.xp>=60+fight.player.level*25','fight.player.xp>=90+fight.player.level*45')
edit('scripts/main.gd','fight.player.xp-=60+fight.player.level*25','fight.player.xp-=90+fight.player.level*45')
edit('scripts/main.gd','    pending="level"\n    talent_panel()','    pending="level"\n    if preload("res://scripts/combo_talents.gd").full(fight):fight.player.coins+=4;pending="";save_run();return\n    talent_panel()')
edit('tests/role_combat.gd','advance(c,last_action.cancel_at+.015 if stage<2 else last_action.duration+.02)','advance(c,last_action.duration+.3)')
edit('tests/role_combat.gd','Vector2(100,60),Vector2(-60,0)]:target(c,offset)','Vector2(100,60),Vector2(70,35),Vector2(70,-35),Vector2(-60,0)]:target(c,offset)')
print('Added twenty mechanism talents. Campaign: 12 points per chapter; short run: 24 points; three-stage unlock pools.')
