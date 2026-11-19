import json,re
from pathlib import Path
root=Path(__file__).resolve().parents[1]
extra={
'wukong':['第三段普攻改为绕身旋棍。','第三段普攻追加迟影分身，分身不能再次产生分身。','重击命中附加1秒减速与15破势。','','第三段普攻标记弱点2秒。','重击命中恢复棍势4点。'],
'tangseng':['落印时获得4点基础护盾。','度化协战命中落印，独立冷却0.8秒。','第二段普攻追加两枚斜向念珠。','念诵在原地留下短暂莲台，独立冷却0.8秒。','相邻法印形成可伤敌的连接线。','重击引爆每枚法印返还3禅意。'],
'bajie':['受击积累反击伤害，下一重击消耗。','成功格挡反弹160范围内的敌弹，反弹不触发派生。','重击范围延长20%。','第三段普攻命中回复2生命。','第三段普攻将敌人向身前勾回，首领位移减弱。','消耗战意的强化重击追加延迟震地。'],
'shaseng':['','流沙领域改为缓慢跟随自身，取消直线漂移。','','逐次引爆后飞出两枚碎沙刃，碎刃不再次触发自身。','','第三段普攻命中恢复5沙息；月刃回收额外恢复3沙息。'],
'bailongma':['移动时每0.6秒留下短暂水痕。','水幕拦截敌弹回复3护盾，冷却0.2秒。','御剑普攻额外放出一柄剑。','侧闪反刺增加一次回收蓄势。','','御剑回收增加蓄势并恢复2潮势。']}
path=root/'data/talents.json'
talents=json.loads(path.read_text(encoding='utf-8'))
for t in talents:
 if t['hero'] not in extra:continue
 index=int(t['id'].rsplit('t',1)[1]);addition=extra[t['hero']][index]
 if addition and not t['description'].startswith(addition):t['description']=addition+t['description']
 resource=root/'data/talents'/f"{t['id']}.tres"
 source=resource.read_text(encoding='utf-8')
 source=re.sub(r'^description = .*$', 'description = '+json.dumps(t['description'],ensure_ascii=False),source,flags=re.M)
 resource.write_text(source,encoding='utf-8')
path.write_text(json.dumps(talents,ensure_ascii=False,indent=2),encoding='utf-8')
path=root/'data/heroes.json';heroes=json.loads(path.read_text(encoding='utf-8'))
for h in heroes:
 if h['id']=='shaseng':h['resource']='沙息'
path.write_text(json.dumps(heroes,ensure_ascii=False,indent=2),encoding='utf-8')
path=root/'scripts/main.gd';source=path.read_text(encoding='utf-8')
source=source.replace('mini(6,fight.enemies.reduce(func(n,e):return n+int(e.marks),0))','fight.enemies.reduce(func(n,e):return n+int(e.marks),0)')
path.write_text(source,encoding='utf-8')
path=root/'tools/local_demo.gd';source=path.read_text(encoding='utf-8').replace('local-demo-only.json','local-role-demo-only.json');path.write_text(source,encoding='utf-8')
path=root/'assets/manifest.json';manifest=json.loads(path.read_text(encoding='utf-8'))
manifest['role_rebuild']={'character_atlas':'characters/role-rig-atlas.png','ability_icons':'ui/role-abilities.png','icon_count':40,'art_origin':'AI-assisted original artwork; no Warm Snow game assets used','animation':'Layered joint hierarchy and procedural authored action poses, not a finished professionally animated sprite set','audio_origin':'Original synthesized waveforms, tools/compose_role_audio.py','audio_count':64}
path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print('Role descriptions and asset provenance updated.')
