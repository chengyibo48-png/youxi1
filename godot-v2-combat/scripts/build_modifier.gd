extends Resource
class_name JourneyBuildModifier

@export var stable_id: String = ""
@export var hero_id: String = ""
@export var changes: String = ""
@export var tradeoff: String = ""

const BUILDS = {
 "wukong": [["长棍破阵",["heavy_line","echo","combo_charge"],"重击延长并留下延迟棍影","需要预判，重击起手更长"],["分身接力",["wukong_t1","cast_echo","wukong_t0"],"分身复现自己的上一招","分身输出不能再生成分身"],["闪避追击",["dash_trail","dash_attack","crit"],"精准闪避强化追击并留下棍痕","需要接近危险并把握时机"]],
 "tangseng": [["印阵爆发",["field_size","pulse","echo"],"落印相连，重击集中引爆","引爆会消耗布置的法印"],["念珠牵引",["fan","chain","pierce"],"念珠扩大覆盖并牵引连印目标","单发输出降低"],["护阵反击",["shield","shield_burst","heavy_shield"],"净土护阵，结印反制","需要守住阵地"]],
 "bajie": [["勾拽聚怪",["wide","reach","heavy_ring"],"横扫拖回敌人，重击勾摔","长起手需要安全窗口"],["格挡反震",["shield","shield_burst","goldbody"],"格挡积战意，反击造成破势","放弃暴击，重视反击时机"],["战意狂攻",["haste","low_power","combo_charge"],"战意强化第三击与重击","需要持续交战并控制生命"]],
 "shaseng": [["集印爆破",["sand","sand_damage","heavy_line","echo"],"月刃搬运印记，定向引爆","只有布印后的爆发最强"],["流沙禁区",["field_size","field_time","pulse"],"流沙领域移动并形成束缚线","输出依赖区域位置"],["移形伏击",["dash_trail","dash_attack","crit"],"沙影换位后突刺并布印","失误会失去伏击窗口"]],
 "bailongma": [["疾剑追击",["haste","dash_attack","reach"],"穿身剑积潮势，追击标记目标","停顿会损失潮势"],["御剑回收",["converge","fan","split"],"御剑回收强化下一次突刺，收束弹道便于管理回程","需要管理飞剑往返时间"],["化龙爆发",["heavy_line","combo_charge","heavy_ring"],"积潮势后释放龙形贯穿","消耗潮势，不能持续爆发"]]
}

static func description(hero: String, id: String) -> String:
 if id=="echo":return {"wukong":"重击位置留下墨影，0.35秒后追加落棍","tangseng":"引爆法印后留下短暂余印","bajie":"重砸留下延迟地裂","shaseng":"引爆后追加沙刃","bailongma":"贯穿留下延迟浪痕"}.get(hero, "延迟追加攻击")
 if id=="return":return "月刃飞回并搬运目标印记" if hero=="shaseng" else "飞剑往返，召回后强化突刺" if hero=="bailongma" else "念珠飞回，往返各命中一次"
 if id=="heavy_line":return "法印引爆范围扩大35%；起手延长0.06秒" if hero=="tangseng" else "延长角色专属重击轨迹35%；起手延长0.06秒"
 return ""
