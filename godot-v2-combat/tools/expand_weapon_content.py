from pathlib import Path
import json,re
R=Path(__file__).resolve().parents[1]
def edit(name,old,new):
 p=R/name;s=p.read_text(encoding='utf-8');assert old in s,(name,old[:60]);p.write_text(s.replace(old,new,1),encoding='utf-8')
heroes=['wukong','tangseng','bajie','shaseng','bailongma']
styles=['disc','lotus_lantern','gate_shield','tether','tide_bow']
names=['金刚飞环','照夜莲灯','山门巨盾','缚妖沙索','潮汐长弓']
desc=['金环往返贯穿；重击三环分向回收，管理回程命中','在瞄准点点亮莲灯，靠近灯阵回复；重击三灯成列','举盾顶撞获得短格挡；重击消耗最多8护盾转为震击','飞索缚敌布印并牵引；重击定向引爆流沙印','后撤放出穿透水箭；重击五箭扇射，需要保持射距']
timings=[[.14,.09,.19],[.24,.1,.24],[.18,.2,.26],[.16,.11,.21],[.22,.09,.22]]
reach=[280,240,125,300,350]
kit=',\n'+',\n'.join(' "%s_w5":%s'%(h,json.dumps([n,st,t,r,'thrust' if st=='gate_shield' else 'seal','seal',d],ensure_ascii=False)) for h,n,st,t,r,d in zip(heroes,names,styles,timings,reach,desc))
edit('scripts/weapon_arts.gd','合流"]\n}', '合流"]'+kit+'\n}')
payload='''  "disc":
   for i in (3 if h else 1):shot(c,a,p,d.rotated((i-1)*.4 if h else 0),power*.7,"disc",{"return":true,"pierce":5,"turn_after":.5,"speed":430.0})
  "lotus_lantern":
   for i in (3 if h else 1):
    var point: Vector2=c.geometry.move(p,d*(90+i*65))
    field(c,a,point,65,power*.5,2.5,"lotus");fx(c,a,point,d,65,"lotus_lantern",1.0)
  "gate_shield":
   if h:
    var spent: float=minf(8,c.player.shield);c.player.shield-=spent
    c.area(p+d*75,120,power+spent*3,source,true);fx(c,a,p+d*75,d,120,"gate_shield",.6)
   else:c.player.guard_until=c.time+.2
  "tether":
   if h:marks(c,a,p,d)
   shot(c,a,p,d,power*.6,"tether",{"pull":65.0,"apply_marks":not h,"pierce":3,"return":true,"turn_after":.35})
  "tide_bow":
   if not h:c.player.pos=c.geometry.move(p,-d*16)
   for i in (5 if h else 1):shot(c,a,c.player.pos,d.rotated((i-2)*.18 if h else 0),power*.7,"water_arrow",{"pierce":3,"speed":780.0,"life":1.2})
'''
edit('scripts/weapon_arts.gd',' if c.hero.id=="tangseng" and h',payload+' if c.hero.id=="tangseng" and h')
p=R/'scripts/weapon_arts.gd';s=p.read_text(encoding='utf-8');s+='''  "disc":shot(c,a,p,d,10,"disc",{"return":true,"trigger":false,"pierce":3})
  "lotus_lantern":c.add_field(p,50,5,1.5,"lotus")
  "gate_shield":c.player.shield=minf(150,c.player.shield+6)
  "tether":shot(c,a,p,d,8,"tether",{"pull":30.0,"apply_marks":true,"trigger":false})
  "tide_bow":shot(c,a,p,d,12,"water_arrow",{"pierce":3,"trigger":false,"speed":780.0})
''';p.write_text(s,encoding='utf-8')
skills=[('风轮掠棍','windwheel','三枚风轮往返贯穿，回程可再次命中'),('梵钟醒世','wake_bell','清除近身敌弹，震荡小妖；首领转为破势'),('耙阵拦关','rake_wall','身前布下三面耙阵，阻挡敌弹并提供12护盾'),('聚沙成傀','sand_guardian','原地召唤5秒沙傀，发射布印沙刃，不能再触发召唤'),('回潮箭阵','arrow_rain','四道穿透潮箭从两侧交错，回程产生第二次命中')]
ults=[('乾坤环阵','ring_storm','十二枚金环向外扩张，再回收穿透'),('万字金城','golden_city','四角法印建立金城，阻弹并回复，需守在阵内'),('山河倒耙','mountain_rake','三列九点地脉依次翻起，预判敌人位置'),('百印归墟','mark_collapse','消耗附近流沙印逐一引爆；无印时只布印，必须先布置'),('潮汐天弓','sky_bow','九箭扇形穿透后归潮，获得短暂回收强化')]
relics=[('回风轮','relic_recall','召回在场的返程兵器，资源回复8；无返程兵器不能使用','第三连击追加一枚回旋环，至少间隔1秒'),('照心莲座','relic_lotus','在脚下布置回复莲阵并清除灼烧与毒','施术额外回复2生命，至少间隔1秒'),('镇山铜钟','relic_bell','震开180范围敌人并清除范围内敌弹','护盾受击产生小范围反震，至少间隔2秒'),('缚妖沙漏','relic_hourglass','为240范围敌人布两枚流沙印并减速','重击为附近敌人追加一枚流沙印，至少间隔1秒'),('星河箭匣','relic_quiver','释放六道穿透回潮箭','闪避追加一枚穿透水箭，至少间隔1秒')]
for table in ['weapons','skills','ultimates','relics']:
 p=R/'data'/f'{table}.json';data=json.loads(p.read_text(encoding='utf-8'))
 for i,h in enumerate(heroes):
  if table=='weapons':data.append(dict(id=h+'_w5',hero=h,name=names[i],mode='slash' if i==2 else 'field' if i==1 else 'projectile',range=reach[i],damage=[22,20,27,21,25][i],interval=sum(timings[i]),description=desc[i],evolutions=data[0]['evolutions'],trait='sand_edge' if i==3 else 'combo',attack_style=styles[i]))
  elif table=='skills':
   n,e,d=skills[i];data.append(dict(id=h+'_s6',hero=h,name=n,effect=e,cooldown=12+i,cost=16,description=d+'；附加当前兵器共鸣。',branches=data[0]['branches']))
  elif table=='ultimates':
   n,e,d=ults[i];data.append(dict(id=h+'_u2',hero=h,name=n,effect=e,cost=80,description=d))
  else:
   n,e,d,pas=relics[i];data.append(dict(id='relic_'+str(18+i),name=n,effect=e,cooldown=22+i,description=d,passive_description=pas))
 p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
edit('scripts/ability_actions.gd','var timing: Array=ULTIMATES[hero][index] if kind=="ultimate" else TIMES[hero][index]','var timing: Array=([.38,.25,.35] if kind=="ultimate" else [.22,.16,.23]) if (kind=="ultimate" and index==2) or (kind=="skill" and index==6) else ULTIMATES[hero][index] if kind=="ultimate" else TIMES[hero][index]')
# A shared extension owns only the new content; the existing role implementations remain intact.
edit('scripts/role_combat.gd',' match c.hero.id:\n', ' match c.hero.id:\n') # validate file
edit('scripts/role_combat.gd',' Weapons.synergy(c,a)\n', ' Weapons.synergy(c,a)\n if preload("res://scripts/content_extension.gd").skill(c,a):\n  c.synergy.trigger(c,"skill",a.direction);c.changed.emit();return\n')
edit('scripts/role_combat.gd',' match effect:\n  "giant":',' preload("res://scripts/content_extension.gd").ultimate(c,a)\n match effect:\n  "giant":')
edit('scripts/combat.gd',' var eff: String=definition.effect\n if eff in', ' var eff: String=definition.effect\n var extension: String=preload("res://scripts/content_extension.gd").relic_reason(self,eff)\n if extension!="":return extension\n if eff in')
edit('scripts/combat.gd',' var factor:=1.5 if has("relicmaster") else 1.0\n match eff:', ' var factor:=1.5 if has("relicmaster") else 1.0\n preload("res://scripts/content_extension.gd").relic(self,eff,direction,factor)\n match eff:')
edit('scripts/combat.gd','s.life-=dt;s.cd-=dt;s.pos=s.pos.lerp(player.pos+Vector2(50,-30),dt*3)','s.life-=dt;s.cd-=dt\n  if not s.get("stationary",false):s.pos=s.pos.lerp(player.pos+Vector2(50,-30),dt*3)')
edit('scripts/combat.gd','"source":"协战","return":false}', '"source":"协战","return":false,"apply_marks":s.get("apply_marks",false),"visual":s.get("visual",""),"role":s.get("role",""),"weapon_style":s.get("weapon_style","")}')
edit('scripts/combat.gd','if f.kind=="sanctuary" and player.pos.distance_to(f.pos)<f.radius:heal(4)','if f.kind in ["sanctuary","lotus"] and player.pos.distance_to(f.pos)<f.radius:heal(2 if f.kind=="lotus" else 4)')
# New defence has its own artwork, while collision shares the proven shield-field primitive.
edit('scripts/combat.gd','f.kind=="waterwall" and Geometry2D','f.kind in ["waterwall","rake_wall"] and Geometry2D')
edit('scripts/combat.gd','if f.kind=="waterwall":','if f.kind in ["waterwall","rake_wall"]:')
edit('scripts/combat.gd','"shield","counter","waterwall","barrier"','"shield","counter","waterwall","rake_wall","golden_city","barrier"')
# SVG icons preserve the existing code-native item icon system without editing bitmap sheets.
icons=[]
for i,h in enumerate(heroes):icons += [(h+'_w5',i),(h+'_s6',5+i),(h+'_u2',10+i),('relic_'+str(18+i),15+i)]
shapes=[ '<circle cx="32" cy="32" r="19" fill="none" stroke-width="7"/>','<path d="M13 36 Q32 9 51 36 L42 49 H22 Z"/><path d="M32 12 V54" fill="none"/>','<path d="M13 13 H51 V40 L32 55 13 40 Z" fill="none" stroke-width="5"/><path d="M22 25 H42 M32 19 V45"/>','<path d="M11 46 Q14 13 35 19 T50 42 Q30 54 24 33" fill="none" stroke-width="5"/>','<path d="M17 10 Q49 32 17 54 M17 10 V54 M12 32 H53 M44 24 L53 32 44 40" fill="none"/>']
for id,i in icons:
 color=['#ddb768','#d6bb91','#a5b4a1','#c1ad82','#99d5df'][i%5]
 shape=shapes[i%5];marks=''.join(f'<circle cx="{12+j*10}" cy="58" r="2"/>' for j in range(i//5+1))
 (R/'assets/ui'/('extra-'+id+'.svg')).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><rect x="2" y="2" width="60" height="60" rx="8" fill="#233a36" stroke="#a98d5e"/><g fill="{color}" stroke="{color}" stroke-width="2">{shape}{marks}</g></svg>',encoding='utf-8')
edit('scripts/icon_catalog.gd',' var roles: Array=', ' var extra: String="res://assets/ui/extra-"+id+".svg"\n if ResourceLoader.exists(extra):\n  if not cache.has(id):cache[id]=load(extra)\n  return cache[id]\n var roles: Array=')
edit('tests/role_combat.gd','styles.size()==25','styles.size()==30')
edit('tests/role_combat.gd','25 explicit weapon kits','30 explicit weapon kits')
print('Added five weapons, five skills, five ultimates, five relics and twenty vector icons.')
