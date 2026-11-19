# 障碍素材生成记录
工具：内置 imagegen；AI辅助生成，人工检查透明通道、分区、比例并接入游戏。
输入：forest.png作为水墨手绘风格参考，不修改参考图。
输出：props-ink.png，2048×768 RGBA，保留透明通道。
生成提示词：
Create a NEW production game prop sprite atlas, not a scene. Use the Chinese ink-wash hand-painted mountain forest artwork only as STYLE reference. Three isolated environment props in ONE horizontal atlas: LEFT a compact mossy jagged grey boulder cluster; MIDDLE a short windswept Chinese pine growing out of a rocky base; RIGHT a weathered ancient Chinese stone pillar with carved lotus cap. Elevated three-quarter top-down action RPG camera, consistent perspective. Low saturation jade, charcoal, ochre, parchment highlights. Rich textured painterly detail and fine ink edges matching the forest reference, no flat cartoon shapes. Genuinely transparent alpha background, no text, no floor, no borders or labels. Fully separated props, no overlapping cells.

实际集成：使用经目视检查的三个矩形区域；按地面位置排序；遮挡玩家时淡化。碰撞仍使用同一份障碍位置与半径，不以透明画面代替碰撞检查。
