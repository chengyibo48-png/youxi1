extends RefCounted
# Each six-stop region has two encounters where an optional supply route cannot bypass combat.
const COMBAT_ROOMS=["combat","elite","trial","secret"]
static func choices(step: int,pool: Array,rng: RandomNumberGenerator) -> Array:
 if step>=6:return ["boss"]
 if step==1:return ["combat","shrine"]
 if step in [3,5]:
  var risks: Array=["elite","trial","secret"]
  var selected: String=risks[rng.randi_range(0,risks.size()-1)]
  risks.erase(selected)
  return ["combat",selected,risks[rng.randi_range(0,risks.size()-1)]]
 var remaining: Array=pool.filter(func(k):return k not in ["boss","training"])
 var result: Array=[]
 while result.size()<3 and not remaining.is_empty():
  var index: int=rng.randi_range(0,remaining.size()-1)
  result.append(remaining[index]);remaining.remove_at(index)
 return result
