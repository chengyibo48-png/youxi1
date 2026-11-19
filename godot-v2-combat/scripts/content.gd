extends RefCounted
const ROOT := "res://data/"
var tables: Dictionary = {}
var indexed: Dictionary = {}
var unlocked_talents: Array=[]
func _init() -> void:
 for table in ["heroes","weapons","skills","ultimates","talents","relics","chapters","events","trials","bosses"]:
  tables[table] = JSON.parse_string(FileAccess.get_file_as_string(ROOT+table+".json"))
 for table in tables:
  indexed[table]={}
  for entry in tables[table]:indexed[table][str(entry.get("id",""))]=entry
 for talent in tables.talents:
  var resource: Resource = load(ROOT+"talents/"+talent.id+".tres")
  if resource != null:
   talent.amount = resource.amount
   talent.description = resource.description
   talent.max_level = resource.max_level
   for field in ["tags","requires","requires_any","source_tags_any","blocked_by","exclusive","needs_shield"]:talent[field]=resource.get(field)
func find(table: String, id: String) -> Dictionary:
 return indexed.get(table,{}).get(id,{})
func for_hero(table: String, hero: String) -> Array:
 return tables[table].filter(func(x): return x.get("hero","") == hero)
func talent_allowed(t: Dictionary, hero: String, tags: Array, owned: Dictionary, banned: Array) -> bool:
 if t.id=="return" and "native_return" in tags:return false
 if not unlocked_talents.is_empty() and t.id not in unlocked_talents:return false
 if t.id in banned or int(owned.get(t.id,0)) >= int(t.max_level): return false
 if t.hero != "" and t.hero != hero: return false
 for requirement in t.get("requires",[]):
  if not owned.has(requirement):return false
 var alternatives: Array=t.get("requires_any",[])
 if not alternatives.is_empty() and not alternatives.any(func(id):return owned.has(id)):return false
 var source_tags: Array=t.get("source_tags_any",[])
 if not source_tags.is_empty() and not source_tags.any(func(tag):return tag in tags):return false
 if t.get("needs_shield",false) and "shield_source" not in tags and not ["shield","heavy_shield","goldbody","reward_shield"].any(func(id):return owned.has(id)):return false
 for blocked in t.get("blocked_by",[]):
  if owned.has(blocked):return false
 if t.category == "core":
  var count := 0
  for item in tables.talents:
   if item.category == "core" and owned.has(item.id): count += 1
  if count >= 2: return false
 for tag in t.tags:
  if tag not in tags: return false
 if t.exclusive != "":
  for item in tables.talents:
   if item.id != t.id and item.exclusive == t.exclusive and owned.has(item.id): return false
 return true
func choices(hero: String, tags: Array, owned: Dictionary, banned: Array, rng: RandomNumberGenerator) -> Array:
 var candidates: Array = tables.talents.filter(func(t): return talent_allowed(t,hero,tags,owned,banned))
 return preload("res://scripts/talent_selection.gd").choices(candidates,owned,rng)
