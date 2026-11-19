extends RefCounted
const GROUPS=[
 ["return","fan","split","chain","pierce","combo_return","d_combo_recall","t_recall_print"],
 ["burn","steam","fireburst","burn_power"],["frost","iceburst","frost_break"],
 ["echo","combo_charge","heavy_line","third_crescent","combo_ink","w_echo_staff","w_combo_vault"],
 ["shield","goldbody","shield_burst","heavy_shield","combo_aegis","b_shield_spend","b_combo_guard"],
 ["field_size","field_time","pulse","sand","sand_damage","s_combo_transfer","s_combo_refund","t_combo_lotus"],
 ["dash_trail","dash_attack","crit","haste","combo_stride","d_tide_precision"]]
static func linked(t: Dictionary,owned: Dictionary) -> bool:
 if owned.has(t.id):return true
 for group in GROUPS:
  if t.id in group and group.any(func(id):return owned.has(id)):return true
 return t.get("requires",[]).any(func(id):return owned.has(id)) or t.get("requires_any",[]).any(func(id):return owned.has(id))
static func pick(pool: Array,rng: RandomNumberGenerator) -> Dictionary:
 var total: float=0;var weights: Array=[]
 for t in pool:
  total+=.55 if t.category=="core" else 1.35 if t.category in ["shape","element","hero"] else 1.0
  weights.append(total)
 var roll: float=rng.randf()*total;var index: int=0
 while index<weights.size()-1 and roll>weights[index]:index+=1
 return pool[index]
static func choices(candidates: Array,owned: Dictionary,rng: RandomNumberGenerator) -> Array:
 var remaining: Array=candidates.duplicate();var result: Array=[]
 for intent in ["link","strengthen","explore"]:
  if remaining.is_empty():break
  var pool: Array=[]
  if intent=="link":pool=remaining.filter(func(t):return linked(t,owned))
  elif intent=="strengthen":pool=remaining.filter(func(t):return t.category in ["trigger","support","element"] or owned.has(t.id))
  else:pool=remaining.filter(func(t):return not linked(t,owned) and not owned.has(t.id) and t.category in ["shape","element","hero","core"])
  if pool.is_empty():pool=remaining
  var chosen: Dictionary=pick(pool,rng);result.append(chosen.id);remaining.erase(chosen)
 return result
static func intent(t: Dictionary,owned: Dictionary) -> String:
 if linked(t,owned):return "当前构筑联动"
 if t.category in ["shape","hero","core"]:return "探索新打法"
 return "有效强化"
