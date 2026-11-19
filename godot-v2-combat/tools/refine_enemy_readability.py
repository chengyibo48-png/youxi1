from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'scripts/main.gd';s=p.read_text(encoding='utf-8')
s=s.replace('func draw_danger() -> void:','func legacy_draw_danger() -> void:',1)
start=s.index(' if e.telegraph>0:',s.index('func draw_enemy'));end=s.index(' if e.get("affix",',start)
s=s[:start]+s[end:]
s+='''\nfunc draw_danger() -> void:
 var art=preload("res://scripts/enemy_effects.gd")
 for hazard in fight.hazards:art.hazard(self,hazard,fight.time,not settings.effects)
 for enemy in fight.enemies:
  if not enemy.dead:art.actor(self,enemy,fight.time)
''';p.write_text(s,encoding='utf-8')
p=root/'scripts/enemy_rig.gd';s=p.read_text(encoding='utf-8');s=s.replace(' var lean: float=',' var action: String=e.get("action",e.get("attack",""))\n if not e.has("profile"):action=e.get("attack","")\n var skin_tint: Color=Color(1.2,1.15,1.05) if e.get("flash",0)>0 else Color.WHITE\n var lean: float=',1)
start=s.index('static func draw');s=s[:start]+s[start:].replace(',Color.WHITE)',',skin_tint)')
s=s.replace('  var elbow: Vector2=shoulder+', '  if action in ["slam","leap"]:arm+=mirror*(-preparation*1.5+attack*1.0)\n  elif action in ["shot","spread","volley","fan","wave"]:arm+=mirror*(-preparation*.9 if side==1 else -preparation*.25)\n  elif action in ["laser","fire","ice","poison","web","summon","ward"]:arm+=mirror*(-preparation*1.15 if side==1 else -preparation*.55)\n  var elbow: Vector2=shoulder+',1)
p.write_text(s,encoding='utf-8')
print('Attack names removed from world effects; native action and material cues enabled.')
