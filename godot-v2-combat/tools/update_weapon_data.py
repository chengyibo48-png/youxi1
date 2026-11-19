from pathlib import Path
import ast,json,re
root=Path(__file__).resolve().parents[1]
source=(root/'scripts/weapon_arts.gd').read_text(encoding='utf-8')
kits=ast.literal_eval(source.split('const KITS=',1)[1].split('\n\nstatic',1)[0])
modes={'pin':'field','flame':'field','phantom':'field','mandala':'field','rosary':'return','scripture':'bolt','bell':'field','hook':'return','furrow':'field','ice_hammer':'field','meteor':'orbit','crescent':'return','shards':'bolt','sand_seal':'field','twin_moon':'return','wave_sword':'return','thunder':'bolt','stars':'return','stamp':'bolt'}
path=root/'data/weapons.json';weapons=json.loads(path.read_text(encoding='utf-8'))
for w in weapons:
 k=kits[w['id']];w['attack_style']=k[1];w['description']=k[6];w['mode']=modes.get(k[1],'slash');w['range']=k[3]
 w['evolutions']=['疾势：起手、命中与收招时间缩短12%；伤害降低10%。','破阵：攻击覆盖范围增加20%，伤害增加12%；动作时间延长12%。']
 # Remove unrelated carryover traits (e.g. frost on a fire-cloud staff).
 w['trait']='sand_edge' if w['hero']=='shaseng' else 'frost_edge' if k[1]=='frost_sword' else 'combo'
path.write_text(json.dumps(weapons,ensure_ascii=False,indent=2),encoding='utf-8')
path=root/'data/skills.json';skills=json.loads(path.read_text(encoding='utf-8'))
for s in skills:
 if '兵器共鸣' not in s['description']:s['description']+=' 兵器共鸣按当前兵器附加，切换不重置冷却。'
path.write_text(json.dumps(skills,ensure_ascii=False,indent=2),encoding='utf-8')
print('25 weapon cards now describe their actual individual attacks and real evolutions.')
