from pathlib import Path
import json,re
R=Path(__file__).resolve().parents[1]
def edit(n,o,v):
 p=R/n;s=p.read_text(encoding='utf-8');assert o in s,(n,o[:45]);p.write_text(s.replace(o,v,1),encoding='utf-8')
edit('scripts/weapon_arts.gd','var haste: float=maxf(.65,1+c.value("haste"))','var haste: float=clampf(1+c.value("haste")+(c.value("cast_haste") if c.time<c.cast_haste_until else 0),.65,2.0)/(1.2 if c.has("domain") else 1.0)')
edit('scripts/weapon_arts.gd',' if c.has("converge"):d=d.slerp(a.direction,.65)',''' if config.trigger:
  config.pierce=int(config.get("pierce",0))+int(c.value("pierce"))
 if c.has("converge"):
  d=d.slerp(a.direction,.65);config.life*=1.15
  if config.get("return",false):config.turn_after=float(config.get("turn_after",.5))*1.15
 if c.has("fan") and config.trigger:
  if not a.get("fan_emitted",false):
   a.fan_emitted=true
   for sign in [-1,1]:c.shoot(pos,d.rotated(sign*.28),damage*.35,config)
  damage*=.85''')
p=R/'scripts/weapon_arts.gd';s=p.read_text(encoding='utf-8');s=s.replace('+int(c.value("fan"))','').replace('(i-c.value("fan")*.5)','i').replace('3+int(c.value("pierce"))','3');p.write_text(s,encoding='utf-8')
edit('scripts/role_combat.gd','a.sweep_scale=float(a.get("sweep_scale",1.0))+(c.value("wide") if c.hero.id=="bajie" else 0.0)','a.sweep_scale=float(a.get("sweep_scale",1.0))*(1+c.value("wide"))')
edit('scripts/role_combat.gd','if heavy:a.damage*=1+c.value("hero_heavy_power")+(.5 if empowered else 0)','if heavy:a.damage*=1+c.value("hero_heavy_power")+(.5 if empowered else 0)+(.25 if c.has("immovable") else 0)')
edit('scripts/role_combat.gd','a.damage*=1.6;c.player.combo_charge=false','a.damage*=1.4+.2*c.value("combo_charge");c.player.combo_charge=false')
edit('scripts/role_combat.gd','.35 if c.has("echo") else .9','.35 if c.has("echo") else 1.2')
edit('scripts/role_combat.gd','if c.has("cast_echo"):delay(c,pos,20,80,.3)','if c.has("cast_echo"):delay(c,pos,14+6*c.value("cast_echo"),70+10*c.value("cast_echo"),.3)')
edit('scripts/role_combat.gd','if c.has("purify"):c.player.poison=0;c.player.burn=0','if c.has("purify"):c.player.poison=0;c.player.burn=0;c.resource(2*c.value("purify"))')
# The extension's early return must honour the same common casting talents.
edit('scripts/role_combat.gd',' if preload("res://scripts/content_extension.gd").skill(c,a):\n  c.synergy.trigger',' if preload("res://scripts/content_extension.gd").skill(c,a):\n  if c.has("cast_echo"):delay(c,pos,14+6*c.value("cast_echo"),70+10*c.value("cast_echo"),.3)\n  if c.has("purify"):c.player.poison=0;c.player.burn=0;c.resource(2*c.value("purify"))\n  if c.has("seal_wheel"):c.player.seal_until=c.time+3\n  c.synergy.trigger')
edit('scripts/combat.gd','if has("summoner"):factor*=.75','if has("summoner") and source in ["attack","heavy"]:factor*=.75')
edit('scripts/combat.gd','if critical:dmg*=1.6+value("crit_power")','if critical:dmg*=minf(2.4,1.6+value("crit_power"))')
edit('scripts/combat.gd','area(player.pos,115,30,"反盾",false)','area(player.pos,80+10*value("shield_burst"),8+6*value("shield_burst"),"反盾",false)')
edit('scripts/combat.gd','if has("burn"):e.burn=3*(1+value("burn_time"))','if has("burn"):e.burn=(2+value("burn"))*(1+value("burn_time"))')
edit('scripts/combat.gd','if has("poison"):e.poison=4','if has("poison"):e.poison=2+2*value("poison")')
edit('scripts/combat.gd','1+int(ceil(value("hero_sand_gain")*5))','int(value("sand"))+int(ceil(value("hero_sand_gain")*5))')
edit('scripts/combat.gd','e.slow=2*(1+value("frost_time"))','e.slow=(1.5+.5*value("frost"))*(1+value("frost_time"))')
edit('scripts/combat.gd','for i in 6:shoot(e.pos,Vector2.RIGHT.rotated(i*TAU/6),12,','for i in 4+int(2*value("iceburst")):shoot(e.pos,Vector2.RIGHT.rotated(i*TAU/(4+2*value("iceburst"))),8+2*value("iceburst"),')
edit('scripts/combat.gd','area(e.pos,65,22,"焰爆",false)','area(e.pos,50+15*value("fireburst"),16+6*value("fireburst"),"焰爆",false)')
edit('scripts/combat.gd','add_field(e.pos,55,5,3,"poison")','add_field(e.pos,45+10*value("venomspread"),3+2*value("venomspread"),2+value("venomspread"),"poison")')
edit('scripts/combat.gd','"radius":70,"damage":24*(1+value("hero_dash_power"))','"radius":60+10*value("dash_trail"),"damage":(16+8*value("dash_trail"))*(1+value("hero_dash_power"))')
edit('scripts/combat.gd','definition.cooldown*maxf(.35,1-value("relic_cd"))','definition.cooldown*maxf(.35,1-value("relic_cd"))*(1.2 if has("relicmaster") else 1.0)')
edit('scripts/combat.gd','3*(1+value("burn_power")),"灼烧"','(2+value("burn"))*(1+value("burn_power")),"灼烧"')
edit('scripts/combat.gd','2.5*(1+value("poison_power")),"中毒"','(2+.5*value("poison"))*(1+value("poison_power")),"中毒"')
edit('scripts/combat.gd','hit(e,4,"蒸汽",false,0)','hit(e,2+2*value("steam"),"蒸汽",false,0)')
edit('scripts/combat.gd','time+=dt;attack_cd=','player.shield=clampf(player.shield,0,150)\n time+=dt;attack_cd=')
edit('scripts/combat.gd','player.action={};player.delayed=[];player.seals=[]','player.action={};player.delayed=[];player.seals=[];player.motion_state="idle";player.action_phase="idle";player.pose_clip="attack"')
descriptions={
 'fan':'每次出手附加两枚35%伤害扇形副弹，本体投射伤害降低15%；每招只追加一次',
 'burn':'命中灼烧；等级1/2/3持续3/4/5秒，每半秒基础伤害3/4/5，可再受燃烧强化影响',
 'frost':'命中减速；等级1/2/3持续2/2.5/3秒，小妖累计四次命中后冻结；首领只减速与破势',
 'poison':'命中中毒；等级1/2/3持续4/6/8秒，每半秒基础伤害2.5/3/3.5',
 'sand':'命中增加1/2/3枚流沙印并减速，单目标最多6枚',
 'purify':'神通命中阶段清除自身毒与灼烧，返还2/4/6资源；不降低技能消耗门槛',
 'iceburst':'冻结小妖死亡时产生6/8/10枚不递归碎片，各造成10/12/14基础伤害',
 'fireburst':'灼烧目标死亡时产生65/80/95半径爆炸，造成22/28/34基础伤害，不触发命中联动',
 'venomspread':'中毒目标死亡留下55/65/75半径毒阵，持续3/4/5秒，每次造成5/7/9基础伤害',
 'steam':'同时灼烧与减速的敌人，每半秒追加4/6/8基础伤害，不再次产生联动',
 'dash_trail':'闪避原地留痕，0.35秒后在70/80/90半径造成24/32/40基础伤害，不触发命中联动',
 'combo_charge':'第三段普攻强化下一次重击，额外伤害60%/80%/100%；只储存一次',
 'shield_burst':'敌人击破护盾时反震90/100/110半径，造成14/20/26基础伤害；自损不触发',
 'cast_echo':'神通释放后0.3秒追加80/90/100半径余响，造成20/26/32基础伤害；不触发命中联动',
 'immovable':'重击伤害增加25%，受伤减免增加20个百分点（总上限55%），移动速度降低20%',
 'crit_power':'暴击倍率增加0.25/0.5/0.75，总暴击倍率最多2.4',
 'converge':'投射方向偏向瞄准轴，散角缩小65%；飞行与自动回返时间延长15%'}
p=R/'data/talents.json';data=json.loads(p.read_text(encoding='utf-8'))
for t in data:
 if t['id'] in descriptions:
  t['description']=descriptions[t['id']]
  p2=R/'data/talents'/(t['id']+'.tres');s=p2.read_text(encoding='utf-8');s=re.sub(r'^description = .*$',lambda _: 'description = '+json.dumps(t['description'],ensure_ascii=False),s,flags=re.M);p2.write_text(s,encoding='utf-8')
p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
edit('scripts/main.gd','"help":action_key("recall")+"召回','"help":(action_key("interact")+"场内交互 · 右侧出口离房") if state in ["service_walk","service"] else action_key("recall")+"召回')
edit('scripts/main.gd','   text("普攻间隔 %.2f秒','   text("普通增伤倍率最多3.0，暴击倍率最多2.4；修行点包含升级等级。",15)\n   text("普攻间隔 %.2f秒')
print('Corrected rank effects, actual tradeoffs, projectile talent compatibility and bounded numeric gains.')
