from pathlib import Path
import json,re
R=Path(__file__).resolve().parents[1]
def edit(n,o,v):
 p=R/n;s=p.read_text(encoding='utf-8');assert o in s,(n,o[:45]);p.write_text(s.replace(o,v,1),encoding='utf-8')
edit('scripts/combat.gd',' if int(player.get("progress_tier",3))>=2:', ''' if weapon.get("attack_style","") in ["rosary","hook","meteor","crescent","twin_moon","wave_sword","stars","disc","tether"] or (owned.has("return") and "projectile" in out) or active_effects.any(func(e):return e in ["arrow_rain","windwheel","ring_storm","sandburst","tide","sky_bow"]) or (hero.id=="shaseng" and "wave" in active_effects):out.append("return_source")
 if owned.has("combo_aegis") and "shield_source" not in out:out.append("shield_source")
 if int(player.get("progress_tier",3))>=2:''')
p=R/'data/talents.json';data=json.loads(p.read_text(encoding='utf-8'))
for t in data:
 if t['id'] in ['combo_return','t_recall_print','d_combo_recall']:
  t['requires_any']=[];t['source_tags_any']=['return_source']
  p2=R/'data/talents'/(t['id']+'.tres');s=p2.read_text(encoding='utf-8');s=re.sub(r'^requires_any = .*$', 'requires_any = Array[String]([])',s,flags=re.M);s+='\nsource_tags_any = Array[String](["return_source"])\n';p2.write_text(s,encoding='utf-8')
 if t['id']=='b_shield_spend':
  t['needs_shield']=True;p2=R/'data/talents'/(t['id']+'.tres');s=p2.read_text(encoding='utf-8');p2.write_text(s+'\nneeds_shield = true\n',encoding='utf-8')
p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
edit('scripts/main.gd',' if room_id in visited:return\n kind=type',' if room_id in visited or state!="route" or type not in options:return\n kind=type') if False else None
edit('scripts/main.gd','func enter_room(type: String) -> void:\n if room_id in visited:return','func enter_room(type: String) -> void:\n if room_id in visited or state!="route" or type not in options:return')
edit('tests/role_combat.gd','scene.room_id="room-check-"+room_type;scene.enter_room(room_type)','scene.room_id="room-check-"+room_type;scene.state="route";scene.options=[room_type];scene.enter_room(room_type)')
edit('tests/role_visual.gd','scene.room_id="visual-"+type;scene.visited=[];scene.enter_room(type)','scene.room_id="visual-"+type;scene.visited=[];scene.state="route";scene.options=[type];scene.enter_room(type)')
tests=''' for talent_id in ["burn","poison","sand","frost","purify","iceburst","fireburst","venomspread","steam","dash_trail","shield_burst","combo_charge","cast_echo"]:
  var low=fresh();var high=fresh()
  for combatant in [low,high]:
   if talent_id in ["iceburst","steam"]:combatant.take("frost")
   if talent_id in ["fireburst","steam"]:combatant.take("burn")
   if talent_id=="venomspread":combatant.take("poison")
   if talent_id=="shield_burst":combatant.take("shield")
   combatant.take(talent_id)
  high.take(talent_id);high.take(talent_id)
  check(int(high.owned.get(talent_id,0))==3,talent_id+" legitimately upgrades to rank three")
  var one: Dictionary=target(low);var three: Dictionary=target(high)
  low.player.resource=30;high.player.resource=30;low.skill_cd=[0.0,0.0];high.skill_cd=[0.0,0.0]
  match talent_id:
   "burn","poison","sand","frost","steam":low.hit(one,10,"attack");high.hit(three,10,"attack");advance(low,.6);advance(high,.6)
   "purify","cast_echo":low.skill(db.find("skills","wukong_s2"),0,Vector2.RIGHT);high.skill(db.find("skills","wukong_s2"),0,Vector2.RIGHT);advance(low,.8);advance(high,.8)
   "iceburst","fireburst","venomspread":one.root=1;one.burn=1;one.poison=1;three.root=1;three.burn=1;three.poison=1;low.die(one);high.die(three)
   "dash_trail":low.dash(Vector2.RIGHT);high.dash(Vector2.RIGHT)
   "shield_burst":low.player.shield=3;high.player.shield=3;low.hurt(12,"enemy");high.hurt(12,"enemy")
   "combo_charge":low.player.combo_charge=true;high.player.combo_charge=true;low.attack(Vector2.RIGHT,true);high.attack(Vector2.RIGHT,true)
  var low_state: String=JSON.stringify(scene.pack_value(low.snapshot()));var high_state: String=JSON.stringify(scene.pack_value(high.snapshot()))
  # Compare executed values rather than owned/effect dictionaries, which only mirror data.
  var evidence: bool=low.dealt!=high.dealt or low.player.resource!=high.player.resource or low.bullets.size()!=high.bullets.size() or one.burn!=three.burn or one.poison!=three.poison or one.marks!=three.marks or one.slow!=three.slow
  if low.fields.size()>0 and high.fields.size()>0:evidence=evidence or low.fields[0].damage!=high.fields[0].damage or low.fields[0].radius!=high.fields[0].radius
  if low.bullets.size()>0 and high.bullets.size()>0:evidence=evidence or low.bullets[0].damage!=high.bullets[0].damage
  if not low.player.action.is_empty() and not high.player.action.is_empty():evidence=evidence or low.player.action.damage!=high.player.action.damage
  check(evidence,talent_id+" rank three alters actual executed effect, not just description")
 c=fresh("bailongma",5);c.active_effects=[];c.rebuild_effects()
 check(not c.can_take("combo_return"),"return finisher rejected without actual return source")
 c.take("return");check(c.can_take("combo_return"),"return finisher becomes eligible after real return source")
 c=fresh("tangseng",2);check(c.can_take("t_recall_print"),"natural returning rosary allows recall seal without filler talent")
 c=fresh();var fast: float=0;var slow: float=0
 c.attack(Vector2.RIGHT);fast=c.player.action.duration;c=fresh();c.take("domain");c.attack(Vector2.RIGHT);slow=c.player.action.duration
 check(slow>fast,"domain core really slows attack timeline")
 c=fresh();c.attack(Vector2.RIGHT,true);var base_heavy: float=c.player.action.damage;c=fresh();c.take("immovable");c.attack(Vector2.RIGHT,true)
 check(c.player.action.damage>base_heavy,"immovable core grants the advertised heavy power")
 c=fresh();c.player.resource=0;c.relic(db.find("relics","relic_16"),Vector2.RIGHT);var ordinary_cd: float=c.relic_cd
 c=fresh();c.take("relicmaster");c.player.resource=0;c.relic(db.find("relics","relic_16"),Vector2.RIGHT)
 check(c.relic_cd>ordinary_cd,"relic mastery has an actual cooldown cost")
 for chapter_index in 37:
  c=fresh("wukong",5);c.player.talent_budget=12;c.player.progress_tier=1+mini(2,int(chapter_index/12));c.rng.seed=700+chapter_index
  for reward in 12:
   var pool: Array=db.choices(c.hero.id,c.tags(),c.owned,[],c.rng)
   check(not pool.is_empty(),"chapter %d still has a valid choice before its cap"%(chapter_index+1))
   if pool.is_empty():break
   check(c.take(pool[0]),"chapter %d reward %d is usable"%[chapter_index+1,reward+1])
  check(NewTalents.points(c)==12 and c.owned.size()<db.tables.talents.size()/2,"chapter %d cannot exhaust the game-wide pool"%(chapter_index+1))
 for role_id in ["wukong","tangseng","bajie","shaseng","bailongma"]:
  c=fresh(role_id,5);c.player.talent_budget=24
  for reward in 24:
   c.player.progress_tier=1+mini(2,int(reward/8))
   var candidates: Array=db.choices(role_id,c.tags(),c.owned,[],c.rng)
   check(not candidates.is_empty(),role_id+" short run reward pool does not drain early")
   if candidates.is_empty():break
   check(c.take(candidates[0]),role_id+" short run candidate can really apply")
  check(NewTalents.points(c)==24,role_id+" short run stays within total progression budget")
'''
edit('tests/role_combat.gd',' scene.queue_free();await process_frame',tests+' scene.queue_free();await process_frame')
print('Added real rank comparisons, eligibility, core tradeoffs and complete progression-pool simulations.')
