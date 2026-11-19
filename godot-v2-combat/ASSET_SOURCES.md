# 本轮素材来源

最新补充：五张 walk-*-v2.png、hero-facing-v2.png、五张 boss-body-v3-*.png、chapter-landmarks-v3.png 均由内置 image_gen 原创生成、透明源图保留。实际提示词见 assets/painterly/PAINTED_PRODUCTION_PROMPTS.md。首领基础躯干与四肢现已替换为 26 个专属区域；下文共用素材说明属于历史版本记录。四朝向步态为 AI 辅助帧图与 IK 混合动画，不宣称人工专业动画或 37 章已全部精修。当前进度见 PAINTED_PRODUCTION_REPORT.md。

- `assets/characters/role-rig-atlas.png`：本轮AI辅助生成的原创五角色分层零件；猴、僧、猪、沙僧、白龙剑客各自独立头、躯干、手臂、腿、衣摆和兵器。生成要求为国风手绘、透明背景、统一比例、禁止文字与标识。实际图集经目视检查后在代码中按不等宽分隔线取区域。
- `assets/ui/role-abilities.png`：本轮AI辅助生成的原创5×8能力图标，包含30神通、10绝技。按角色和技能主题绑定稳定ID。属于手绘图标，不宣称是人工像素逐点制作。
- 本轮64段角色与交互WAV：`tools/compose_role_audio.py`生成的原创数学波形与噪声，无外部录音或采样。
- 继承素材来源与限制：`assets/manifest.json`及原工程记录。没有下载、复制《暖雪》的角色、地图、音频、图标或游戏代码。

AI辅助开发与素材生成已如实标注。代码中的动作姿态、图集切分与特效组合不代表真人美术终验。正式发布前仍需对继承素材逐项确认授权及署名要求，本轮没有发布。

## 2026-10-10 新增与替换

assets/painterly中的weapons、relics、effects、rooms、enemy-rig、hero-rig、terrain七张PNG均由内置图像生成辅助制作，未使用商业游戏参考输入。设计摘要见 assets/painterly/PROMPTS.md。regions.json仅记录取图边界，不修改原图像素。

当前角色使用hero-rig，旧role-rig-atlas原图保留。敌人与部分首领复用八类零件，不宣称已完成26套首领模型。weapon_effects、abilities_visual、enemy_effects的轨迹、碎屑与危险形态由原创代码生成。

## 后续首领与章节素材

`chapter-props-v2.png`、`boss-heads-v2.png`、`boss-parts-v2.png`、`terrain-v2.png`为内置图像生成的原创图集；`boss-heads-v3.png`为在本轮原创头部图集上返修百眼魔君的版本。源图均保留，提示见 `assets/painterly/ITERATION_PROMPTS.md`。没有商业游戏素材输入。

首领运行时改用独立资源定义关节结构及新增头部、躯干、附肢，基础四肢仍有共用素材。结构场景不意味着26套完整人工逐帧美术已完成。动画库是关键帧骨骼表现，与手绘逐帧图集明确区分。

`assets/painterly/boss-lion-head.png`为后续原创透明单头素材，用于九灵元圣的九个活动头部；替代整张多头图的硬裁切。由内置图像生成制作，提示与本轮其他素材一并记录。

## 攻击姿态与剩余章节地标

本轮新增五张 `action-角色-v3.png` 与四张 `chapter-landmarks-v4-编号.png`，由内置 image_gen 原创生成，没有商业游戏素材输入。保留原始 PNG，仅分析透明边界生成 Godot 图集资源和脚底定位数据。实际提示见 `assets/painterly/REMAINING_PRODUCTION_PROMPTS.md`。

本轮覆盖120张下身攻击姿态和其余29章地标，当前37章都有剧情地标与布局。上半身仍为骨架/分层素材，不意味着完整专业手绘逐帧动画或37套完整背景已完成。首领专属身体材料已在前一轮补齐；完整方向和招式帧仍需制作。

## 三阶段程序表现补充

`combat_presentation.gd`复用既有原创法阵材质；章节周边碎屑、阴影、反光由Godot原生绘制，不新增外部位图素材。`soundscape.gd`以独立固定种子生成PCM环境层及首领节奏层，属于原创程序合成音频，不是现场录音或专业编曲。没有输入商业游戏素材，本轮不把AI辅助帧图与骨架动画标为完整专业手绘。

## 本轮功能道具与预生成音频

`spirit-props-v5.png` 与透明背景编辑版 `spirit-props-v5-alpha.png` 为内置 image_gen 原创辅助素材，无商业游戏参考输入。八格道具含葫芦、莲灯、土地神龛、商柜、锻造炉、经台、竹亭和石狮关门，详情见 `assets/painterly/FINAL_PRODUCTION_PROMPTS.md`。这是二维图集，不是完整三维模型或专业动画。

`assets/audio/ambience_*.res` 由 `tools/generate_ambience.gd` 离线执行原有原创 PCM 合成器生成。运行时直接加载，避免主线程首次生成卡顿；不代表专业音频制作或混音验收已完成。

## 2026-10-10 完整地面与全身样板

`forest-floor-v6.png`、`temple-floor-v6.png`、`river-floor-v6.png`为imagegen原创AI辅助完整地面底画，已接入对应战斗/奖励房；立体地标及碰撞继续独立。不是37章完整人工精修。

`wukong-fullbody-walk-v6-draft.png`和`wukong-fullbody-walk-v6-alpha.png`为悟空四朝向全身样板，仅参考本项目已有原创角色材料；存在重复步态与帧边界问题，未接入正式战斗，不标专业手绘或人工通过。制作提示与返修记录见`assets/painterly/ART_V6_PROMPTS.md`。

## 2026-10-10 继续制作v7

`ember-floor-v7.png`为原创AI辅助火焰山冷却岩地，已接入。`wukong-walk-keys-v7-draft.png`为原创悟空四张完整关键姿态返修稿，仍未进入正式角色。提示和来源见`assets/painterly/ART_V7_PROMPTS.md`；实际接入与检查见`ART_AND_FLUIDITY_V7.md`。五角色闪避修改为程序分层姿态，不宣称专业逐帧完成。

## 2026-10-10 继续制作v8

`desert-floor-v8.png`、`snow-floor-v8.png`、`city-floor-v8.png`、`cave-floor-v8.png`为内置 imagegen 原创AI辅助完整底画，已接入战斗及同地点奖励房。来源与提示见 `assets/painterly/ART_V8_PROMPTS.md`。景物阴影使用Godot原生渐变；井台只修改图集区域，不改原图。这些补充不代表37章独立人工背景及专业逐帧已完成。

## 2026-10-10 v9 全身招式与专属底画

唐僧念诵12张全身方向姿态、红孩儿吐火4张全身侧向姿态，以及双叉岭、火云洞、通天河三张专属底画已接入，均为内置imagegen原创AI辅助。悟空八帧稿仍为返修素材，未接入。来源与提示见 `assets/painterly/ART_V9_PROMPTS.md`；实际限制和检查见 `ART_PRODUCTION_V9.md`。没有把AI输出或自动检查认定为专业人工手绘完成。
# 五角色全身候选 v10

`assets/painterly/*-fullbody-walk-v10-draft.png` 为内置 image_gen 生成的原创西游 AI辅助候选，形象参考本项目 hero-facing-v2.png。原图及提示词见 ART_V10_PROMPTS.md。五张均因步态连续性和帧边界问题标记返修，未接入实战，不属于专业人工手绘完成资产。检查记录见 FULLBODY_FIVE_ROLE_V10.md。

## v11 接入（2026-10-11，覆盖上面的 v10 历史运行状态）

用户同意暂按现有材料接入。五张 v10 候选现用于行走，由透明连通轮廓及缓存 GPU 网格排除邻格碎片，原图不改；攻击保留原骨架。重复步态等制作缺陷仍待返修，专业制作状态不变。新 chapter-03/05/07-floor-v11.png 为原创 AI 辅助底画，提示见 assets/painterly/ART_V11_PROMPTS.md。26 首领 / 95 招式为原创骨架关键帧编排，不是全套人工逐帧素材。37 章光照为 Godot 原生渐变与色调。接入及测试范围见 ART_INTEGRATION_V11.md。

