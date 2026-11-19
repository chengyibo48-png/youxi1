extends RefCounted
# Versioned first tuning pass; not a claim of human balance acceptance.
const PROFILE: String="pilgrimage_v1"
static func activate(c) -> void:
 c.player.balance_profile=PROFILE
 c.player.max_hp=floor(c.hero.hp*.94)
 c.player.hp=minf(c.player.hp,c.player.max_hp)
static func enabled(c) -> bool:return c.player.get("balance_profile","")==PROFILE
static func population(chapter: int,region: int,room: String) -> int:
 if room=="boss":return 0
 var count: int=24+mini(24,maxi(0,region)*4+maxi(0,chapter)/3)
 return count+(8 if room=="secret" else 4 if room in ["elite","trial"] else 0)
static func active_limit(region: int) -> int:return 12+mini(6,maxi(0,region)*2)
static func interval(chapter: int,region: int) -> float:return maxf(.62,.9-maxi(0,chapter)*.004-maxi(0,region)*.04)
static func vitality(kind: String,tier: int) -> float:
 return (1.38 if kind=="boss" else 1.28 if kind=="elite" else 1.18)*(1+minf(.18,maxi(0,tier)*.005))
static func enemy_damage(tier: int) -> float:return 1.12+minf(.23,maxi(0,tier)*.007)
static func damage_multiplier(c,owner: int) -> float:
 for enemy in c.enemies:
  if int(enemy.uid)==owner:return float(enemy.get("damage_scale",1))
 return 1.0
