from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'scripts/combat.gd'
source=path.read_text(encoding='utf-8')
for obsolete,next_function in [('legacy_attack','attack'),('legacy_skill','legacy_ultimate'),('legacy_ultimate','relic_reason')]:
 start=source.find('func '+obsolete+'(')
 end=source.find('func '+next_function+'(',start)
 if start>=0 and end>start:source=source[:start]+source[end:]
path.write_text(source,encoding='utf-8')
old=root/'tests/run.gd'
if not old.read_text(encoding='utf-8').startswith('extends "res://tests/role_combat.gd"'):
 (root/'tests/legacy_reference.gd').write_text(old.read_text(encoding='utf-8'),encoding='utf-8')
 old.write_text('extends "res://tests/role_combat.gd"\n',encoding='utf-8')
(root/'README.md').write_text('# 五角色战斗重做 · 本地工作版本\n\n双击 Start-Demo.cmd 打开本地演示。详细说明见 [README_ROLE_REBUILD.md](README_ROLE_REBUILD.md)。本目录独立于原版 godot-v2，不是发布包。\n\n默认自动检查：`godot --headless --path . --script res://tests/run.gd`。`tests/legacy_reference.gd` 为旧动作系统测试参考，不作为新版通过记录。\n',encoding='utf-8')
print('Removed obsolete instant attack implementations; new default test entry configured.')
