extends RefCounted
# Commit completed combat segments once; current combat remains a live view.
var segments: Dictionary={}
var history_complete: bool=true
func reset() -> void:
 segments={};history_complete=true
func counters(c) -> Dictionary:
 return {"kills":int(c.deaths),"damage":float(c.dealt),"sources":c.damage_sources.duplicate(true)}
func commit(key: String,c) -> void:
 if not segments.has(key):segments[key]=counters(c)
func summary(key: String,c) -> Dictionary:
 var result: Dictionary={"kills":0,"damage":0.0,"sources":{},"complete":history_complete}
 var records: Array=segments.values().duplicate()
 if not segments.has(key):records.append(counters(c))
 for record in records:
  result.kills+=int(record.kills);result.damage+=float(record.damage)
  for source in record.sources:result.sources[source]=float(result.sources.get(source,0))+float(record.sources[source])
 return result
func snapshot() -> Dictionary:return {"version":1,"segments":segments.duplicate(true),"complete":history_complete}
static func valid(data) -> bool:
 if not data is Dictionary or data.get("version",0)!=1 or not data.get("segments") is Dictionary or not data.get("complete") is bool:return false
 for record in data.segments.values():
  if not record is Dictionary or not record.get("sources") is Dictionary:return false
  for key in ["kills","damage"]:
   if not (record.get(key) is int or record.get(key) is float) or not is_finite(float(record[key])) or record[key]<0:return false
  if not record.sources.values().all(func(v):return (v is int or v is float) and v>=0 and is_finite(float(v))):return false
 return true
func restore(data: Dictionary,missing_history: bool=false) -> void:
 reset();history_complete=not missing_history
 if data.is_empty():return
 if not valid(data):history_complete=false;return
 history_complete=bool(data.get("complete",false))
 for key in data.get("segments",{}):
  var record=data.segments[key]
  if not record is Dictionary or not record.get("sources") is Dictionary:continue
  if not (record.get("kills") is int or record.get("kills") is float) or not (record.get("damage") is int or record.get("damage") is float):continue
  if record.kills<0 or record.damage<0:continue
  if not record.sources.values().all(func(v):return (v is int or v is float) and v>=0 and is_finite(float(v))):continue
  segments[str(key)]=record.duplicate(true)
