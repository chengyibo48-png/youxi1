from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
path=root/'assets/manifest.json';manifest=json.loads(path.read_text(encoding='utf-8'))
manifest['painterly_2026_10_10']={
 'source':'Original built-in AI-assisted generation; no commercial game reference images',
 'files':[f'painterly/{name}.png' for name in ['weapons','relics','effects','rooms','enemy-rig','hero-rig','terrain']],
 'region_metadata':'painterly/regions.json','design_brief':'painterly/PROMPTS.md',
 'runtime':'Cached AtlasTexture regions, layered 2D bone constraints; original PNGs unchanged',
 'effects':'Original material particles and independent convex trajectory strips driven by actual actions',
 'limitations':'2D illustrations, not 3D models. Eight monster rigs reused by bosses. Human art and playtest acceptance pending.'}
path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
