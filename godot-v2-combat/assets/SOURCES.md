# 素材来源
- 字体：Noto Sans SC，Google Fonts；SIL Open Font License，见 FONT-LICENSE.txt。
- 场景原画：本项目经 ImageGen 辅助生成，选定文件复制到本工程后使用。
- 角色原画图集：ImageGen辅助原创；兵器与动作由运行时组合。当前使用完整角色图集，尚不是分层骨骼或全量逐帧动作。
- 图标与技能特效：本项目原创程序化矢量。
- 音效：运行时合成，无第三方采样。
不包含商业游戏拆包素材。

- enemies.png：本项目通过 OpenAI ImageGen 生成的八种敌人概念图集；尚非26名首领的独立动画素材。

- forest.png、river.png：OpenAI ImageGen 原创环境图，作为黑风山与通天河主题样板；连同庭院共三张背景。未完成八套环境分层。
- 当前角色动作采用代码驱动的起手、挥动和回正，尚非完整手绘逐帧动画。

- props-ink.png：内置imagegen辅助生成的透明水墨树石与古柱图集，已检查RGBA透明通道；参考本项目forest.png。提示与接入说明见PROP_PROMPT.md。

- ui/item-icons.png：本项目原创程序化32×32像素图集，Pillow绘制，不使用第三方图片。214个ID映射采用35种机制轮廓；源代码tools/generate_pixel_icons.py，映射ui/item-icons.json。

- bosses-premium.png：OpenAI ImageGen原创四种妖物原画，2026-10-09生成并经内置工具调整分隔。红孩儿、牛魔王、青牛精、白骨精及一种随机唤妖术士外观已接入；不是26套独立动作素材。实际分格使用main.gd中的boss_source，避免相邻兵器串入。
- environment-atlas.png：OpenAI ImageGen原创四场景，白骨古寺、火焰山、盘丝洞、雷音庭院；运行时切为四个AtlasTexture。加上既有庭院、山林与河岸，共七套背景原画；装饰不充当隐形障碍，碰撞由显式树石古柱决定。
- audio/journey-theme.wav：本项目原创五声音阶短曲和合成弦音，无第三方旋律或采样；可由tools/compose_audio.py重生成。
- audio其余WAV：原创多谐波、噪声和包络合成；独立16声道原生播放器池，不在每帧执行高成本逐采样合成。背景音乐与战斗声音可分别关闭，总音量可调。
