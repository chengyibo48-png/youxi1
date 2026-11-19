"""Align existing painted shapes with names, attack descriptions and skill branches."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
path=root/'data/weapons.json'
items=json.loads(path.read_text(encoding='utf-8'))
names={'tangseng_w2':'回音金铙','shaseng_w3':'镇沙法印','shaseng_w4':'双月刃','bailongma_w1':'踏浪剑','bajie_w3':'霜齿战耙','bajie_w4':'天蓬链耙'}
for item in items:
    if item['id'] in names:item['name']=names[item['id']]
    if item['id']=='tangseng_w2':
        item['combo']=['抛铙','双铙交织','归铙回震']
        item['description']='抛铙 → 双铙交织 → 归铙回震；金铙飞旋返回，重击召回并绕身护持。'
    if item['id']=='tangseng_w3':
        item['combo']=['念珠布印','双串结印','印间经爆']
        item['description']='念珠布印 → 双串结印 → 印间经爆；以念珠结印，重击沿法印引发经文连爆。'
path.write_text(json.dumps(items,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
path=root/'data/skills.json';skills=json.loads(path.read_text(encoding='utf-8'))
for skill in skills:
    effect=skill['effect']
    benefit={'summon':'分身复招伤害','mark':'弱点标记持续时间','orbit':'格挡与环绕持续时间','heal':'念诵伤害与治疗','convert':'度化伤害与控制时间','counter':'反制窗口','shield':'获得护盾','root':'束缚持续时间','blink':'闪避追击有效时间','waterwall':'获得护盾','rake_wall':'获得护盾'}.get(effect,'伤害')
    skill['branches']=[f'凝势：{benefit}提升35%，冷却增加20%','流转：冷却降低20%；效果强度保持原值']
path.write_text(json.dumps(skills,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
for name in ['weapon_arts.gd','weapon_combo.gd']:
    path=root/'scripts'/name;code=path.read_text(encoding='utf-8')
    for before,after in [('念珠盘绕','金铙回旋'),('念珠扇出并返回；重击收珠','金铙抛出并返回；重击收铙'),('经页折阵','念珠结阵'),('经页远射布双印','念珠远射布双印'),('沙印布阵','镇沙法印'),('双月轮转','双月刃轮转'),('"散珠","双列穿珠","归珠回震"','"抛铙","双铙交织","归铙回震"'),('"翻页布印","双页夹印","印间经爆"','"念珠布印","双串结印","印间经爆"')]:code=code.replace(before,after)
    path.write_text(code,encoding='utf-8')
path=root/'scripts/main.gd';code=path.read_text(encoding='utf-8').replace('reroll,rerolls<=0,"ui_talent",footer','reroll,rerolls<=0 or preload("res://scripts/combo_talents.gd").full(fight),"ui_talent",footer')
code=code.replace('var skill_status: String=fight.skill_reason(skill,index)','var skill_status: String="补给房·暂不可用" if state=="service_walk" else fight.skill_reason(skill,index)')
path.write_text(code,encoding='utf-8')
