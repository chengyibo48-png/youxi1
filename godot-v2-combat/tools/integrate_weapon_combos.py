from pathlib import Path
import json
R=Path(__file__).resolve().parents[1]
def edit(n,o,v):
 p=R/n;s=p.read_text(encoding='utf-8');assert o in s,(n,o[:50]);p.write_text(s.replace(o,v,1),encoding='utf-8')
edit('scripts/weapon_combo.gd','const Arts=preload("res://scripts/weapon_arts.gd")\n','')
edit('scripts/weapon_combo.gd',' if a.heavy or a.combo==1:return false',' var Arts=load("res://scripts/weapon_arts.gd")\n if a.heavy or a.combo==1:return false')
edit('scripts/weapon_arts.gd',' a.sweep_scale=1.3 if a.weapon_style=="dual" else 1.0',' a.sweep_scale=1.3 if a.weapon_style=="dual" else 1.0\n preload("res://scripts/weapon_combo.gd").configure(a)')
edit('scripts/weapon_arts.gd',' c.feedback.emit("heavy" if h else "swing",p,power)\n match', ' c.feedback.emit("heavy" if h else "swing",p,power)\n if preload("res://scripts/weapon_combo.gd").payload(c,a):return\n match')
edit('scripts/role_combat.gd',' if busy(c) or c.player.hp<=0 or c.dash_time>0 or c.player.get("skill_left",0)>0:return false',''' if busy(c):
  var previous: Dictionary=c.player.action
  if kind!="attack" or heavy or previous.kind!="attack" or previous.heavy or previous.combo>=3 or previous.elapsed<previous.cancel_at:return false
  c.player.last_action=previous.duplicate(true);c.player.action={}
 if c.player.hp<=0 or c.dash_time>0 or c.player.get("skill_left",0)>0:return false''')
edit('scripts/role_combat.gd','if c.evolution()==1:a.damage','if kind=="attack" and c.evolution()==1:a.damage')
edit('scripts/role_combat.gd','elif c.evolution()==2:a.reach','elif kind=="attack" and c.evolution()==2:a.reach')
# Prevent a universal hero post-step from overwriting the per-weapon sweep geometry.
edit('scripts/role_combat.gd','a.role=c.hero.id;a.sweep_scale=1.2+c.value("wide") if c.hero.id=="bajie" else 1.0','a.role=c.hero.id;a.sweep_scale=float(a.get("sweep_scale",1.0))+(c.value("wide") if c.hero.id=="bajie" else 0.0)')
edit('scripts/layered_rig.gd','  for j in pose.size():pose[j]*=stage','''  if not a.heavy and a.combo==2:
   pose[0]*=-.85;pose[1]=-.45-pose[1]*.45;pose[2]-=.45;pose[3]*=-.6;pose[5]-=1.5
  elif not a.heavy and a.combo==3:
   pose[0]+=.18;pose[1]-=.5;pose[2]+=.25;pose[3]+=.28;pose[4]-=.18;pose[5]+=2.0
  for j in pose.size():pose[j]*=stage''')
# A hitstop freezes combat time, including the pending action's 120ms buffer.
edit('scripts/main.gd','   input_attack=maxf(0,input_attack-dt);input_dash=maxf(0,input_dash-dt);heavy_buffer=maxf(0,heavy_buffer-dt)\n   if not pending_command.is_empty():\n    pending_command.left-=dt\n    if pending_command.left<=0:pending_command={}\n   queue_redraw();return','   queue_redraw();return')
edit('scripts/main.gd','if fight.attack(aim):input_attack=0','if fight.attack(aim):\n    input_attack=0\n    notify("第%d段 · "%fight.player.action.combo+fight.player.action.get("chain_name","普攻"));toast_time=.65')
# Pair a chain listing with the card's real behaviour.
p=R/'data/weapons.json';data=json.loads(p.read_text(encoding='utf-8'))
import ast
chains=ast.literal_eval((R/'scripts/weapon_combo.gd').read_text(encoding='utf-8').split('const CHAINS=',1)[1].split('\nstatic',1)[0])
for w in data:w['combo']=chains[w['attack_style']];w['description']=' → '.join(w['combo'])+'；'+w['description']
p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
tests=''' for weapon in db.tables.weapons:
  c=fresh(weapon.hero,int(str(weapon.id).right(1)))
  for offset in [Vector2(80,0),Vector2(140,0),Vector2(210,0),Vector2(100,60),Vector2(-60,0)]:target(c,offset)
  var chain_names: Array=[];var total_start: float=c.dealt
  for stage in 3:
   check(c.attack(Vector2.RIGHT),weapon.id+" chain stage %d accepted"%(stage+1))
   check(c.player.action.combo==stage+1,weapon.id+" correct combo index %d"%(stage+1))
   chain_names.append(c.player.action.chain_name)
   var last_action: Dictionary=c.player.action
   advance(c,last_action.cancel_at+.015 if stage<2 else last_action.duration+.02)
   check(c.dealt>total_start,weapon.id+" stage %d has real damage"%(stage+1));total_start=c.dealt
  check(chain_names.size()==3 and chain_names[0]!=chain_names[1] and chain_names[1]!=chain_names[2],weapon.id+" three explicit unique chain moves")
  advance(c,1.5);check(c.attack(Vector2.RIGHT) and c.player.action.combo==1,weapon.id+" combo resets after break")
 c=fresh();target(c);c.attack(Vector2.RIGHT);var current: Dictionary=c.player.action
 advance(c,current.cancel_at+.01)
 check(c.attack(Vector2.RIGHT) and c.player.action.combo==2,"recovery can flow directly into next basic move")
 c=fresh();c.attack(Vector2.RIGHT,true)
 check(not c.attack(Vector2.RIGHT),"combo chaining never cancels heavy startup")
'''
edit('tests/role_combat.gd',' scene.queue_free();await process_frame',tests+' scene.queue_free();await process_frame')
print('Thirty weapons now own three named combo moves with distinct trajectories and recovery chaining.')
