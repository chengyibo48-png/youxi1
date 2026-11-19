"""Per-chapter authored lighting notes; these are not 37 completed background paintings."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
LOOKS=[
 ('fff0d9','283527',.055,'岭口暮光'),('f3eedb','364239',.045,'两界山斜照'),
 ('e6f1ef','284145',.055,'鹰愁涧水光'),('e3eacb','213324',.085,'火后林荫'),
 ('f8edda','35422a',.035,'高老庄春暮'),('fff0cf','665133',.04,'黄沙散射'),
 ('dfe9e4','293f43',.065,'流沙冷光'),('f6f0d8','334b39',.04,'观院叶影'),
 ('d9e2e6','27333e',.095,'白虎岭阴霾'),('e1e2f2','25273e',.09,'宝象国夜色'),
 ('e8ddce','3c3028',.085,'莲花洞岩光'),('f2e9d8','394038',.035,'乌鸡古城'),
 ('ffe0c5','542f26',.05,'火云余烬'),('e2f2e9','314640',.05,'黑水幽光'),
 ('f3eadd','3f3b30',.04,'车迟祭坛'),('dceff4','27464d',.07,'通天河寒意'),
 ('e5e1d5','343b35',.085,'金兜岩壁'),('e5eacb','3f4530',.06,'子母河草影'),
 ('e9ddeb','3c2e45',.085,'毒敌山月色'),('ffe5c9','593929',.045,'火焰热光'),
 ('e7f0d4','354a3c',.045,'碧波潭反照'),('e4e7d4','34422c',.07,'荆棘岭密荫'),
 ('f4e3bb','4d4229',.06,'小雷音金光'),('ede8d7','3e4336',.035,'七绝岭石路'),
 ('f1e8d1','45442e',.05,'麒麟山余照'),('e6e1db','3f3b40',.08,'盘丝林暗影'),
 ('e8edd7','344637',.05,'黄花观药圃'),('eadbc7','503a2c',.07,'狮驼岭尘光'),
 ('f1e7d5','404238',.035,'比丘街巷'),('e2dded','332b40',.09,'无底洞幽辉'),
 ('f8eddf','3f3d34',.03,'灭法国街光'),('dfdee7','302c3c',.09,'隐雾山冷雾'),
 ('f0eadc','3d4437',.045,'凤仙旱土'),('e9efd9','364c37',.04,'玉华山秋荫'),
 ('dee9eb','2f444b',.07,'玄英洞冰光'),('f1eaf2','453b53',.045,'天竺月华'),
 ('f6eedc','45472f',.025,'西行归途晨光')]
chapters=json.loads((ROOT/'data/chapters.json').read_text(encoding='utf-8-sig'))
compositions=json.loads((ROOT/'data/chapter_compositions.json').read_text(encoding='utf-8-sig'))
floor_biomes={int(p['chapter']):p.get('floor_biome') for p in compositions}
assert len(chapters)==len(LOOKS)==37
data=[{'chapter':i,'place':c['place'],'biome':c['biome'],'biomes':list(dict.fromkeys([c['biome'],floor_biomes.get(i) or c['biome']])),'grade':LOOKS[i][0],
       'edge':LOOKS[i][1],'edge_alpha':LOOKS[i][2],'note':LOOKS[i][3],
       'background_hand_painting':'pending'} for i,c in enumerate(chapters)]
(ROOT/'data/chapter_lighting_v11.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')
print('Authored lighting configurations: 37; completed human background paintings: 0')
