"""Specialized behavior uses the same eligibility result as the HUD and reward cards."""
from pathlib import Path
import re
root=Path(__file__).resolve().parents[1]
for name in ['role_combat.gd','role_traits.gd','combat.gd']:
 path=root/'scripts'/name;source=path.read_text(encoding='utf-8')
 source=re.sub(r'c\.owned\.has\("((?:wukong|tangseng|bajie|shaseng|bailongma)_t\d)"\)',r'c.owns("\1")',source)
 source=re.sub(r'(?<!\.)owned\.has\("((?:wukong|tangseng|bajie|shaseng|bailongma)_t\d)"\)',r'owns("\1")',source)
 if name=='role_combat.gd':
  source=source.replace('e.marks>0 and e.pos.distance_to(pos)<400)', 'e.marks>0 and e.pos.distance_to(pos)<400 and c.geometry.visible(pos,e.pos))')
 path.write_text(source,encoding='utf-8')
path=root/'scripts/main.gd';source=path.read_text(encoding='utf-8')
source=source.replace('var old: Dictionary=raw.get("meta",{})','var old=raw.get("meta",{})')
source=source.replace(' elif not fight.player.get("action",{}).is_empty():action+=', ' if charging and hero_id in ["wukong","bajie","bailongma"] and fight.player.resource>=20:action+=" · 释放后%d"%maxf(0,fight.player.resource-20)\n elif not fight.player.get("action",{}).is_empty():action+=')
path.write_text(source,encoding='utf-8')
print('Role conditions unified with actual eligibility; mark targeting respects obstacles.')
