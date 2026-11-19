import json,re
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'data/talents.json';talents=json.loads(path.read_text(encoding='utf-8'))
for item in talents:
 if item['id']=='heavy_line':item['description']='扩大专属重击轨迹或法印爆破范围35%；起手延长0.06秒'
path.write_text(json.dumps(talents,ensure_ascii=False,indent=2),encoding='utf-8')
path=root/'data/talents/heavy_line.tres';source=path.read_text(encoding='utf-8');source=re.sub(r'^description = .*$', 'description = "扩大专属重击轨迹或法印爆破范围35%；起手延长0.06秒"',source,flags=re.M);path.write_text(source,encoding='utf-8')
