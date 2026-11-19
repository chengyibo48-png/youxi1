"""Append local asset provenance without external paths or personal information."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
path=ROOT/'assets/manifest.json'
data=json.loads(path.read_text(encoding='utf-8'))
data['remaining_polish_iteration']={
 'generator':'Built-in image_gen; original transparent PNGs; no commercial reference images',
 'files':[f'painterly/action-{role}-v3.png' for role in ['wukong','tangseng','bajie','shaseng','bailongma']]+[f'painterly/chapter-landmarks-v4-{i}.png' for i in range(4)],
 'prompt_record':'assets/painterly/REMAINING_PRODUCTION_PROMPTS.md',
 'runtime':'120 lower-body attack stance frames; 37 story landmark compositions; shared combat-clock boss phase, hurt and death poses',
 'limitations':'AI-assisted lower-body frame sheets and skeletal upper body, not complete professional human-drawn animation. Whole chapter art, full boss directional/action frames and human playtests remain unfinished.',
 'commercial_reference_inputs':[]}
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
source=ROOT/'ASSET_SOURCES.md'
text=source.read_text(encoding='utf-8')
heading='## 攻击姿态与剩余章节地标'
if heading not in text:
 text+='\n'+heading+'\n\n本轮新增五张 `action-角色-v3.png` 与四张 `chapter-landmarks-v4-编号.png`，由内置 image_gen 原创生成，没有商业游戏素材输入。保留原始 PNG，仅分析透明边界生成 Godot 图集资源和脚底定位数据。实际提示见 `assets/painterly/REMAINING_PRODUCTION_PROMPTS.md`。\n\n本轮覆盖120张下身攻击姿态和其余29章地标，当前37章都有剧情地标与布局。上半身仍为骨架/分层素材，不意味着完整专业手绘逐帧动画或37套完整背景已完成。首领专属身体材料已在前一轮补齐；完整方向和招式帧仍需制作。\n'
 source.write_text(text,encoding='utf-8')
