import ast,runpy
from pathlib import Path
root=Path(__file__).resolve().parents[1]
audio=runpy.run_path(str(root/'tools/compose_role_audio.py'))
kits=ast.literal_eval((root/'scripts/weapon_arts.gd').read_text(encoding='utf-8').split('const KITS=',1)[1].split('\n\nstatic',1)[0])
for index,(weapon,kit) in enumerate(kits.items()):
 frequency=110+index*23
 for kind,multiplier in [('swing',1.0),('heavy',.58)]:
  audio['write'](weapon+'_'+kind,frequency*multiplier,.14+float(kit[2][0])*(1.5 if kind=='heavy' else .6),1.3+index*.07,.09 if kit[1] in ['rake','furrow','meteor','ice_hammer'] else .025)
print('60 original weapon swing/heavy cues generated.')
