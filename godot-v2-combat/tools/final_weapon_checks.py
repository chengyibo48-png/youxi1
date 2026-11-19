from pathlib import Path
R=Path(__file__).resolve().parents[1]
def edit(n,o,v):
 p=R/n;s=p.read_text(encoding='utf-8');assert o in s,(n,o[:40]);p.write_text(s.replace(o,v,1),encoding='utf-8')
edit('scripts/home_screen.gd','五角色 · 二十五兵器 · 免费试用','五角色 · 三十兵器 · 免费试用')
edit('scripts/role_combat.gd','if c.hero.id=="bailongma":a.shape="thrust"','if c.hero.id=="bailongma" and a.weapon_style=="lance":a.shape="thrust"')
# Do not make casting speed depend on which weapon happens to be held.
edit('scripts/role_combat.gd','var weapon_haste: float=.38/maxf(.15,float(c.weapon.interval))','var weapon_haste: float=1.0')
edit('scripts/role_combat.gd','c.player.action_schema=3','c.player.action_schema=4')
edit('scripts/combat.gd','state.combat_version=3','state.combat_version=4')
edit('scripts/main.gd','get("combat_version",0)!=3','get("combat_version",0)!=4')
edit('scripts/save.gd','if valid_payload(raw.payload):return raw.payload','''if valid_payload(raw.payload):
    var run: Dictionary=raw.payload.get("run",{})
    if not run.is_empty() and run.get("combat",{}).get("combat_version",0)<4:
     if DirAccess.copy_absolute(location+suffix,location+".pre-weapon-backup.json")!=OK:
      last_error="旧战斗备份失败，已保留原存档，请重新选择章节。";return {}
     return {"meta":raw.payload.get("meta",{}),"settings":raw.payload.get("settings",{}),"run":{},"migration_note":"兵器动作系统已更新：永久进度保留，旧战斗已备份，请重新开始本章。"}
    return raw.payload''')
# Evolution coverage affects actual field radius/projectile distance, not just VFX reach.
edit('scripts/weapon_arts.gd','config.merge(options,true)','config.merge(options,true)\n if c.evolution()==2:config.life*=1.2;config.turn_after=float(config.get("turn_after",.5))*1.2')
edit('scripts/weapon_arts.gd','c.add_field(pos,radius,damage,duration,kind)','c.add_field(pos,radius*(1.2 if c.evolution()==2 else 1.0),damage,duration,kind)')
edit('scripts/layered_rig.gd','"tide":[-.2,-2.1,-.8,.4,-.3,-6.0]','"tide":[-.2,-2.1,-.8,.4,-.3,-6.0],"windwheel":[-.3,-1.8,-.4,.4,-.2,-3.0],"wake_bell":[.1,-.3,-1.5,0.0,0.0,-2.0],"rake_wall":[.25,-1.3,-1.7,.5,-.2,3.0],"sand_guardian":[.05,-2.1,-.8,.15,0,2.0],"arrow_rain":[-.15,-1.2,-2.0,.5,-.2,-3.0],"ring_storm":[-.35,-2.2,-.5,.4,-.2,-6.0],"golden_city":[.0,-1.8,-1.8,0,0,-4.0],"mountain_rake":[.5,-2.3,.8,.8,-.4,9.0],"mark_collapse":[-.15,-.5,-1.6,.3,-.1,3.0],"sky_bow":[-.2,-1.5,-2.2,.5,-.3,-5.0]')
# Persistent defence and healing fields retain their identity after cast FX expires.
edit('scripts/main.gd','if f.kind in ["waterwall","rake_wall"]:\n    for band','''if f.kind=="rake_wall":
    for tooth in 9:draw_line(f.pos+Vector2(-30+tooth*7,-24),f.pos+Vector2(-30+tooth*7,24),Color("b9ad8b"),3,true)
    draw_line(f.pos+Vector2(-34,5),f.pos+Vector2(34,5),Color("817856"),5,true)
   elif f.kind=="lotus":
    for petal in 8:
     var axis=Vector2.RIGHT.rotated(petal*TAU/8)
     draw_colored_polygon(PackedVector2Array([f.pos+axis*f.radius*.6,f.pos+axis*f.radius*.3+axis.orthogonal()*7,f.pos,f.pos+axis*f.radius*.3-axis.orthogonal()*7]),Color("d1b891",.35))
   elif f.kind=="waterwall":
    for band''')
newtests=''' for relic_id in ["relic_18","relic_19","relic_20","relic_21","relic_22"]:
  c=fresh();c.player.hp=c.player.max_hp*.5;target(c)
  if relic_id=="relic_18":c.shoot(c.player.pos,Vector2.RIGHT,10,{"return":true})
  var definition: Dictionary=db.find("relics",relic_id)
  check(c.relic_reason(definition)=="",relic_id+" shared condition allows valid use")
  var before_state: Array=fingerprint(c)
  check(c.relic(definition,Vector2.RIGHT)=="",relic_id+" active executes")
  check(fingerprint(c)!=before_state or c.bullets.any(func(b):return b.get("manual_recall",false)),relic_id+" actual active result")
  check(c.relic_cd>0,relic_id+" cooldown starts once")
  check(c.relic(definition,Vector2.RIGHT)!="",relic_id+" prevents repeated activation")
  c.passive_relic=definition.effect;c.player.relic_cooldowns={}
  var event: String=c.synergy.EVENTS[definition.effect];before_state=fingerprint(c)
  check(c.synergy.trigger(c,event,Vector2.RIGHT),relic_id+" passive executes its own event")
  check(fingerprint(c)!=before_state,relic_id+" passive changes combat")
  check(not c.synergy.trigger(c,event,Vector2.RIGHT),relic_id+" passive cannot recurse within cooldown")
 c=fresh();var recall=db.find("relics","relic_18")
 check(c.relic(recall,Vector2.RIGHT)!="" and c.relic_cd==0,"empty recall relic rejects without cooldown")
 c=fresh();c.trial="noheal";c.player.hp=40
 check(c.relic(db.find("relics","relic_19"),Vector2.RIGHT)!="" and c.relic_cd==0,"lotus follows no-heal rule")
 c=fresh();check(c.relic(db.find("relics","relic_21"),Vector2.RIGHT)!="" and c.relic_cd==0,"sand relic rejects empty targets")
 c=fresh("bajie",5);c.player.shield=8;target(c);c.attack(Vector2.RIGHT,true);advance(c,1)
 check(c.player.shield==0 and c.dealt>0,"new shield heavy actually trades shield for impact")
 c=fresh("shaseng",5);var marked=target(c);marked.marks=3;c.attack(Vector2.RIGHT,true);advance(c,1.5)
 check(marked.marks==0 and c.damage_sources.has("印裂"),"tether heavy consumes existing marks without reapplying")
 c=fresh("shaseng");target(c);c.skill(db.find("skills","shaseng_s6"),0,Vector2.RIGHT);advance(c,.5)
 var idol_position: Vector2=c.summons[0].pos;advance(c,1)
 check(c.summons[0].pos==idol_position and c.enemies.any(func(e):return e.marks>3),"sand idol stays placed and genuinely adds marks")
 c=fresh("bajie");target(c);c.skill(db.find("skills","bajie_s6"),0,Vector2.RIGHT);advance(c,.5)
 c.shoot(c.player.pos+Vector2(140,0),Vector2.LEFT,50,{"friendly":false,"return":false,"speed":500.0})
 var shield_hp: float=c.player.hp;advance(c,.4)
 check(c.player.hp==shield_hp and not c.bullets.any(func(b):return not b.friendly),"rake wall blocks hostile projectile collision")
 for item in db.tables.weapons+db.tables.skills+db.tables.ultimates+db.tables.relics:
  check(scene.icons.icon(item.id)!=null,item.id+" selectable icon exists")
'''
# main icon instance uses icon_catalog (looked up below if name differs).
p=R/'scripts/main.gd';m=p.read_text(encoding='utf-8');import re
icon_name=re.search(r'var (\w+)=preload\("res://scripts/icon_catalog.gd"\)',m)
if icon_name:newtests=newtests.replace('scene.icons.', 'scene.'+icon_name.group(1)+'.')
edit('tests/role_combat.gd',' scene.queue_free();await process_frame',newtests+' scene.queue_free();await process_frame')
print('Added condition, passive, geometry and icon integration checks; migration keeps permanent progress.')
