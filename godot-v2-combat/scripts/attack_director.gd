extends RefCounted
const CAPACITY: int=3
static func weight(e: Dictionary,hazards: Array,bullets: Array=[]) -> int:
 return state_weight(e,hazards.any(func(h):return int(h.get("owner",-1))==int(e.uid) and h.get("life",0)>0 and h.get("damage",0)>0) or bullets.any(func(b):return not b.get("friendly",true) and int(b.get("owner",-1))==int(e.uid) and b.get("life",0)>0 and b.get("damage",0)>0))
static func state_weight(e: Dictionary,live_threat: bool) -> int:
 if e.get("dead",false):return 0
 if e.kind=="boss":
  if e.get("warning",0)>0 or e.get("charging",0)>0 or live_threat:return 2
  return 0
 return 1 if e.get("telegraph",0)>0 or e.get("rush_time",0)>0 or e.get("volley_left",0)>0 or live_threat else 0
static func can_begin(c,e: Dictionary) -> bool:
 # Index ownership once per request rather than scan every projectile for each enemy.
 # Fresh indexing observes attacks begun earlier in this same combat tick.
 var owners: Dictionary={}
 for hazard in c.hazards:
  if hazard.get("life",0)>0 and hazard.get("damage",0)>0:owners[int(hazard.get("owner",-1))]=true
 for shot in c.bullets:
  if not shot.get("friendly",true) and shot.get("life",0)>0 and shot.get("damage",0)>0:owners[int(shot.get("owner",-1))]=true
 var used: int=0
 for other in c.enemies:
  if other.uid!=e.uid:used+=state_weight(other,owners.has(int(other.uid)))
 return used+(2 if e.kind=="boss" else 1)<=CAPACITY
