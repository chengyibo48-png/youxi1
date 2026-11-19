from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
s=(root/'tools/integrate_painterly_art.py').read_text(encoding='utf-8')
exec(s[s.index("p=root/'scripts/reward_room.gd'"):])
