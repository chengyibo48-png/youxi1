extends Resource
class_name JourneyCharacterCombatKit

@export var hero_id: String = ""
@export var resource_rule: String = ""
@export var vocabulary: String = ""
@export var acceleration_time: float = 0.09
@export var braking_time: float = 0.08
@export var dash_speed: float = 850.0
@export var dash_duration: float = 0.23

const PROFILES = {
 "wukong": ["连击积棍势 · 重击耗20 · 精准闪避获得追击", "棍痕", 0.065, 0.055, 1050.0, 0.20],
 "tangseng": ["落印积禅意 · 重击引爆 · 站定恢复", "经印", 0.10, 0.075, 730.0, 0.26],
 "bajie": ["受击/格挡积战意 · 重击耗20 · 勾耙聚怪", "土浪", 0.12, 0.10, 740.0, 0.25],
 "shaseng": ["攻击布印 · 重击定向引爆 · 月刃搬印", "沙刃", 0.085, 0.07, 880.0, 0.22],
 "bailongma": ["移动积潮势 · 穿身追击 · 重击耗20", "水剑", 0.055, 0.05, 1150.0, 0.18]
}

static func for_hero(id: String) -> JourneyCharacterCombatKit:
 var kit := JourneyCharacterCombatKit.new()
 var p: Array = PROFILES.get(id, PROFILES.wukong)
 kit.hero_id=id;kit.resource_rule=p[0];kit.vocabulary=p[1]
 kit.acceleration_time=p[2];kit.braking_time=p[3];kit.dash_speed=p[4];kit.dash_duration=p[5]
 return kit
static func acceleration_for(id: String) -> float:
 return float(PROFILES.get(id,PROFILES.wukong)[2])
static func resource_rule_for(id: String) -> String:
 return str(PROFILES.get(id,PROFILES.wukong)[0])

func action(combo: int, heavy: bool) -> Resource:
 var definition = preload("res://scripts/action_definition.gd").new()
 var phase: Array = {
  "wukong": [[.09,.11,.12],[.07,.10,.14],[.13,.13,.19],[.26,.18,.28]],
  "tangseng": [[.12,.07,.18],[.15,.08,.20],[.18,.08,.22],[.25,.10,.25]],
  "bajie": [[.18,.16,.22],[.21,.19,.25],[.27,.18,.32],[.37,.22,.35]],
  "shaseng": [[.10,.12,.17],[.13,.14,.19],[.16,.17,.21],[.24,.16,.27]],
  "bailongma": [[.055,.085,.12],[.065,.095,.13],[.10,.12,.16],[.19,.15,.23]]
 }[hero_id][3 if heavy else combo-1]
 definition.stable_id=hero_id+("_heavy" if heavy else "_attack_"+str(combo))
 definition.windup=phase[0];definition.active=phase[1];definition.recovery=phase[2]
 definition.cancel_at=definition.windup+definition.active
 definition.clip=definition.stable_id;definition.sound={"wukong":"slash","tangseng":"field","bajie":"heavy","shaseng":"return","bailongma":"bolt"}[hero_id]
 definition.geometry_kind="seal" if hero_id=="tangseng" else "thrust" if (hero_id=="shaseng" and combo==1) or (hero_id=="bailongma" and combo!=2) else "arc"
 definition.reach={"wukong":135.0,"tangseng":260.0,"bajie":115.0,"shaseng":155.0,"bailongma":130.0}[hero_id]
 definition.width=34.0 if hero_id=="bajie" else 18.0 if hero_id=="bailongma" else 25.0
 if heavy:definition.reach*=1.65;definition.width*=1.3
 return definition
