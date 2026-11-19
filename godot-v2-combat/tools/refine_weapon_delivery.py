from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'scripts/role_combat.gd';s=path.read_text(encoding='utf-8')
s=s.replace(' c.player.lunge=Vector2.ZERO\n return true', ' c.player.lunge=Vector2.ZERO\n if kind=="ultimate":preload("res://scripts/ultimate_visual.gd").emit(c,a,"prepare")\n return true',1)
s=s.replace(' art(c,effect,pos,d,320,1.0);c.feedback.emit("ultimate",pos,0)',' art(c,effect,pos,d,320,1.0);preload("res://scripts/ultimate_visual.gd").emit(c,a,"release");c.feedback.emit("ultimate",pos,0)')
s=s.replace(' art(c,"clone",pos,d,float(a.get("reach",135)),.5)', ' art(c,"clone",pos,d,float(a.get("reach",135)),.5)\n if a.has("weapon_style"):Weapons.fx(c,a,pos,d,float(a.get("reach",135)))')
path.write_text(s,encoding='utf-8')
path=root/'scripts/role_presentation.gd';s=path.read_text(encoding='utf-8')
s=s.replace(' if v.effect=="weapon":',' if v.effect=="ultimate_stage":\n  preload("res://scripts/ultimate_visual.gd").draw(canvas,v,reduced_flash);return\n if v.effect=="weapon":',1);path.write_text(s,encoding='utf-8')
path=root/'scripts/main.gd';s=path.read_text(encoding='utf-8')
s=s.replace(' for i in 16:\n  var voice', ' for weapon in db.tables.weapons:\n  for hit in ["swing","heavy"]:audio_streams[weapon.id+"_"+hit]=load("res://assets/audio/"+weapon.id+"_"+hit+".wav")\n for i in 16:\n  var voice',1)
s=s.replace(' if kind in ["skill","ultimate"]:', ' if kind in ["swing","heavy"]:key=fight.weapon.id+"_"+kind\n if kind in ["skill","ultimate"]:',1)
s=s.replace(' if charging and hero_id in ["wukong","bajie","bailongma"] and fight.player.resource>=20:action+=" · 释放后%d"%maxf(0,fight.player.resource-20)\n','')
path.write_text(s,encoding='utf-8')
path=root/'scripts/layered_rig.gd';s=path.read_text(encoding='utf-8')
start=s.index('  pose=([.28,-1.8');end=s.index('\n  for j in pose.size()',start)
poses={
'extend':[.28,-1.8,.4,.7,-.3,-3.0],'pin':[-.1,-1.2,-.9,.25,-.1,2.0],'flame':[.22,-1.3,-1.4,.4,-.1,-1.0],'dual':[-.25,-1.95,-.7,.5,-.2,-2.0],'phantom':[-.3,-.7,-1.4,.1,.15,-4.0],
'stamp':[.04,-.7,-1.25,.05,0,-1.0],'mandala':[-.1,-1.7,-1.8,.1,0,-3.0],'rosary':[.13,-1.1,-.3,.2,0,-1.5],'scripture':[-.08,-.6,-1.8,.04,.1,-2.0],'bell':[.1,-.3,-.9,0,.2,2.0],
'rake':[.35,-1.1,.6,.5,-.2,5.0],'hook':[-.2,-1.8,.5,.3,-.1,-1.0],'furrow':[.45,-.3,.7,.6,-.4,8.0],'ice_hammer':[.3,-2.3,-.5,.25,-.2,6.0],'meteor':[-.25,-1.4,-.6,.5,-.4,-2.0],
'crescent_staff':[.22,-1.7,.2,.6,-.2,-1.5],'crescent':[-.12,-1.6,-.9,.25,-.1,-2.0],'shards':[.15,-1.15,-1.6,.3,.1,-1.0],'sand_seal':[.07,-.6,-1.5,.0,.1,1.0],'twin_moon':[-.2,-2.0,-1.8,.4,-.3,-3.0],
'lance':[.4,-1.7,.1,1.0,-.45,-4.0],'wave_sword':[.2,-1.5,-.6,.5,-.1,-2.5],'frost_sword':[-.13,-1.75,.3,.4,-.2,-1.2],'thunder':[.35,-2.1,-.4,.8,-.5,-5.0],'stars':[-.1,-1.2,-1.5,.2,-.1,-4.0]}
s=s[:start]+'  pose='+repr(poses).replace("'",'"')+'.get(style,[0.0,0.0,0.0,0.0,0.0,0.0]).duplicate()'+s[end:]
path.write_text(s,encoding='utf-8')
print('Weapon poses/audio and 10 separate ultimate compositions wired.')
