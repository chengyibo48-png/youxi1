"""Create a separate local-only comparison runner; preserve the previous reel."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
text=(ROOT/'tools/painted_showcase.gd').read_text(encoding='utf-8')
text=text.replace('painted-showcase-only.json','remaining-showcase-only.json')
text=text.replace('"frames":180','"frames":240').replace('"frames":60','"frames":100')
text=text.replace('for chapter in [0,1,3,4,6,7,19,22]','for chapter in [2,5,8,9,10,11,12,13,14,15,16,17,18,20,21,23,24,25,26,27,28,29,30,31,32,33,34,35,36]')
text=text.replace('for room in ["shop","shrine","forge"]','for room in ["shop","shrine","event","rest","reward","forge","curse"]')
text=text.replace('scene.chapter=6;scene.kind=item.id','scene.chapter=25;scene.kind=item.id')
old='''  scene.demo_movement_override=directions[mini(3,local/22)] if local<88 else Vector2.ZERO
  scene.demo_aim_override=scene.demo_movement_override if local<88 else Vector2.RIGHT
  if local in [96,117,138]:press("attack")
  if local==157:scene.fight.skill_cd[0]=0;press("skill1")'''
new='''  var segment: int=local/60
  scene.demo_aim_override=directions[mini(3,segment)]
  scene.demo_movement_override=directions[mini(3,segment)] if local%60<12 else Vector2.ZERO
  if local%60 in [17,33,49]:press("attack")
 if item.kind=="boss" and not scene.fight.enemies.is_empty():
  var e: Dictionary=scene.fight.enemies[0]
  if local==30:e.transition=1.2
  if local==65:e.flash=.1
  if local==76:scene.fight.die(e)'''
assert old in text
text=text.replace(old,new)
text=text.replace('local in [18,40,62,84,125]','local in [23,83,143,203]').replace('local==40','local in [40,83]')
text=text.replace('painted-view-','remaining-view-')
text=text.replace('"boss_13",4','"boss_13",2')
(ROOT/'tools/remaining_showcase.gd').write_text(text,encoding='utf-8')
