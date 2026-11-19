"""Actual current pool (143 entries); static trace records are not playtest verdicts."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
items=json.loads((ROOT/'data/talents.json').read_text(encoding='utf-8'))
scripts=[(p,p.read_text(encoding='utf-8')) for p in (ROOT/'scripts').glob('*.gd') if p.stem not in ['content','talent_selection','icon_catalog','build_modifier']]
records=[]
for item in items:
    t=item.copy()
    source=(ROOT/f'data/talents/{t["id"]}.tres').read_text(encoding='utf-8')
    for key in ['amount','max_level']:
        match=re.search(r'^'+key+r' = ([\d.\-]+)',source,re.M)
        if match:t[key]=float(match[1]) if key=='amount' else int(match[1])
    match=re.search(r'^description = (".*")$',source,re.M)
    if match:t['description']=json.loads(match[1])
    for key in ['tags','requires','requires_any','source_tags_any','blocked_by']:
        match=re.search(r'^'+key+r' = Array\[String\]\((.*)\)$',source,re.M)
        if match:t[key]=json.loads(match[1])
    locations=[]
    for path,text in scripts:
        for number,line in enumerate(text.splitlines(),1):
            if '"'+t['effect']+'"' in line or '"'+t['id']+'"' in line:
                locations.append(f'{path.relative_to(ROOT).as_posix()}:{number}')
    tradeoff=t['description'] if any(x in t['description'] for x in ['降低','消耗','不能','延长','减少','放弃','失去']) else '无额外惩罚；占用修行点，仍受适用条件和触发上限约束'
    records.append(dict(id=t['id'],name=t['name'],category=t['category'],hero=t.get('hero',''),effect=t['effect'],
        applicable_tags=t.get('tags',[]),prerequisites=t.get('requires',[]),alternatives=t.get('requires_any',[]),source_tags=t.get('source_tags_any',[]),blocked_by=t.get('blocked_by',[]),resource=f'data/talents/{t["id"]}.tres',change=t['description'],
        tradeoff=tradeoff,parameter_levels=[t['amount']*n for n in range(1,t['max_level']+1)],
        parameter_note='效果参数档位；实际收益还受执行逻辑、冷却与上限约束',
        execution_locations=locations,status='已映射执行引用，实机组合与真人体验分别验收' if locations else '缺执行引用，需返修'))
output={'count':len(records),'new_talents_added':0,'scope':'Static resource and execution trace audit; does not certify every gameplay combination','talents':records}
(ROOT/'data/talent_audit.json').write_text(json.dumps(output,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
lines=['# 现有修行逐项核对','',f'实际资源共{len(records)}项，本轮未增加修行。参数档位不是额外天赋数量。静态引用存在不等于效果和体验已通过。','', '| ID | 名称 | 改变／实际描述 | 参数档位 | 执行引用数 |','|---|---|---|---|---|']
for r in records:lines.append(f'| {r["id"]} | {r["name"]} | {r["change"]} | {r["parameter_levels"]} | {len(r["execution_locations"])} |')
(ROOT/'TALENT_AUDIT.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print(f'Audited {len(records)} resources; {sum(not r["execution_locations"] for r in records)} missing static execution references.')
