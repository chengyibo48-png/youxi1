extends RefCounted
const PATH := "user://journey-role-v3.json"
var last_error := ""
var base_path: String = PATH
var recovery_note: String=""
func write(payload: Dictionary, location: String = "") -> bool:
 last_error = ""
 if not valid_payload(payload):last_error="当前存档数据校验失败，原存档与备份保留。";return false
 if location == "": location = base_path
 var file := FileAccess.open(location+".tmp",FileAccess.WRITE)
 if file == null:
  last_error="无法写入存档临时文件（错误 %d）；原存档保留。"%FileAccess.get_open_error();return false
 file.store_string(JSON.stringify({"version":2,"payload":payload}))
 file.flush()
 var write_error: Error=file.get_error()
 file.close()
 if write_error!=OK:
  last_error="存档写入失败（错误 %d）；原存档保留。"%write_error;return false
 # A corrupt main file must never replace the last known-good recovery copy.
 if FileAccess.file_exists(location) and valid_file(location):
  if DirAccess.copy_absolute(location,location+".bak.tmp") != OK or not valid_file(location+".bak.tmp") or DirAccess.rename_absolute(location+".bak.tmp",location+".bak")!=OK:
   last_error="存档备份失败；原存档保留，本次进度尚未保存。";return false
 if DirAccess.rename_absolute(location+".tmp",location) == OK: return true
 last_error="存档替换失败；原存档与备份保留，本次进度尚未保存。"
 return false
func valid_file(location: String) -> bool:
 var parser:=JSON.new()
 if parser.parse(FileAccess.get_file_as_string(location))!=OK:return false
 var raw=parser.data
 return raw is Dictionary and raw.get("version",0)==2 and raw.get("payload") is Dictionary and valid_payload(raw.payload)
func read(location: String = "") -> Dictionary:
 if location == "": location = base_path
 last_error = ""
 recovery_note=""
 for suffix in ["", ".bak"]:
  if not FileAccess.file_exists(location+suffix): continue
  var parser := JSON.new()
  if parser.parse(FileAccess.get_file_as_string(location+suffix)) != OK: continue
  var raw = parser.data
  if raw is Dictionary and raw.get("version",0) == 2 and raw.get("payload") is Dictionary:
   if valid_payload(raw.payload):
    if suffix==".bak":recovery_note="主存档损坏，已读取最近有效备份；最后一次保存后的进度可能未恢复。"
    var run: Dictionary=raw.payload.get("run",{})
    if not run.is_empty() and run.get("combat",{}).get("combat_version",0)<4:
     if DirAccess.copy_absolute(location+suffix,location+".pre-weapon-backup.json")!=OK:
      last_error="旧战斗备份失败，已保留原存档，请重新选择章节。";return {}
     return {"meta":raw.payload.get("meta",{}),"settings":raw.payload.get("settings",{}),"run":{},"migration_note":"兵器动作系统已更新：永久进度保留，旧战斗已备份，请重新开始本章。"}
    return raw.payload
 if location==PATH and not FileAccess.file_exists(location):
  var legacy=JSON.parse_string(FileAccess.get_file_as_string("user://journey-v2.json")) if FileAccess.file_exists("user://journey-v2.json") else null
  if legacy is Dictionary and legacy.get("payload") is Dictionary and valid_payload(legacy.payload):
   if DirAccess.copy_absolute("user://journey-v2.json","user://journey-v2.pre-role-backup.json")==OK:
    return {"meta":legacy.payload.get("meta",{}),"settings":legacy.payload.get("settings",{}),"run":{},"migration_note":"永久进度已导入；旧战斗现场已备份，请重新开始本章。"}
 last_error = "存档不存在或损坏，已保留原文件。"
 return {}

func valid_payload(payload: Dictionary) -> bool:
 if not finite_tree(payload):return false
 for key in ["meta","settings","run"]:
  if payload.has(key) and not payload[key] is Dictionary:return false
 var meta: Dictionary=payload.get("meta",{})
 for key in ["unlocked","completed","settled","imports","weapon_unlocks","talent_unlocks"]:
  if meta.has(key) and not meta[key] is Array:return false
 if meta.has("merit") and not (meta.merit is float or meta.merit is int):return false
 var settings: Dictionary=payload.get("settings",{})
 for key in ["keys","pad_keys","mouse_keys"]:
  if settings.has(key) and not settings[key] is Dictionary:return false
 var run: Dictionary=payload.get("run",{})
 if run.is_empty():return true
 if run.has("run_statistics") and not preload("res://scripts/run_statistics.gd").valid(run.run_statistics):return false
 for key in ["hero","mode","state","room_id","run_id","rng"]:
  if not run.get(key) is String:return false
 for key in ["weapons","skills","relics","route","offers","banned","visited","bought","options"]:
  if not run.get(key) is Array:return false
 if not run.get("combat") is Dictionary:return false
 var combat: Dictionary=run.combat
 if not vectors_valid(combat):return false
 if not combat.get("player") is Dictionary or not combat.get("owned") is Dictionary:return false
 var p: Dictionary=combat.player
 for key in ["hp","max_hp","shield","resource","coins","xp","level"]:
  if not p.get(key) is float and not p.get(key) is int:return false
  if p[key]<0 or p[key]>1000000000:return false
 if p.max_hp<=0 or p.hp>p.max_hp or p.resource>100 or p.level<1:return false
 if not p.get("pos") is Dictionary or not p.pos.has("__v"):return false
 if not combat.get("skill_cd",[]) is Array or combat.skill_cd.size()!=2:return false
 for value in combat.skill_cd:
  if not (value is int or value is float) or value<0:return false
 for key in ["skill_left","attack_left","attack_duration","gait"]:
  if p.has(key) and not (p[key] is int or p[key] is float):return false
 for key in ["velocity","facing","attack_direction","lunge"]:
  if p.has(key) and (not p[key] is Dictionary or not p[key].has("__v")):return false
 if p.get("skill_left",0)>0:
  if not p.get("skill_direction") is Dictionary or not p.skill_direction.has("__v"):return false
  if not p.get("skill_hits") is Array or not (p.get("skill_speed") is float or p.get("skill_speed") is int) or not (p.get("skill_damage") is float or p.get("skill_damage") is int):return false
 if p.has("action"):
  if not p.action is Dictionary:return false
  var action: Dictionary=p.action
  if not action.is_empty():
   for key in ["elapsed","windup","active","duration","cancel_at","reach","width","damage"]:
    if not action.get(key) is float and not action.get(key) is int:return false
    if action[key]<0:return false
   if action.duration<=0 or action.duration>20 or action.elapsed>action.duration or action.active<=0:return false
   if action.get("kind","") not in ["attack","skill","ultimate"] or not action.get("hits") is Array:return false
   if not action.get("direction") is Dictionary or not action.direction.has("__v"):return false
 for key in ["seals","delayed","hit_history"]:
  if p.has(key) and not p[key] is Array:return false
 if p.get("delayed",[]).size()>32 or p.get("seals",[]).size()>6:return false
 for key in ["enemies","bullets","fields","summons"]:
  if not combat.get(key) is Array:return false
 for enemy in combat.enemies:
  if not enemy is Dictionary:return false
  for key in ["pos","hp","kind","uid","slow","root","stagger","dot","target"]:
   if not enemy.has(key):return false
  for key in ["hp","uid","slow","root","stagger","dot"]:
   if not (enemy[key] is int or enemy[key] is float):return false
  for key in ["pos","target"]:
   if not enemy[key] is Dictionary or not enemy[key].has("__v"):return false
 for shot in combat.bullets:
  if not shot is Dictionary:return false
  for key in ["pos","dir","life","damage","hit","return","age"]:
   if not shot.has(key):return false
  for key in ["life","damage","age"]:
   if not (shot[key] is int or shot[key] is float):return false
  for key in ["pos","dir"]:
   if not shot[key] is Dictionary or not shot[key].has("__v"):return false
  if not shot.hit is Array:return false
 for field in combat.fields:
  if not field is Dictionary or not field.get("pos") is Dictionary or not field.pos.has("__v"):return false
  for key in ["radius","damage","life","tick"]:
   if not (field.get(key) is int or field.get(key) is float):return false
 return true

func vectors_valid(value) -> bool:
 if value is Dictionary:
  if value.has("__v"):
   var coordinates=value["__v"]
   if not coordinates is Array or coordinates.size()!=2:return false
   for number in coordinates:
    if not (number is float or number is int):return false
  if value.has("__c") and not value["__c"] is String:return false
  for child in value.values():
   if not vectors_valid(child):return false
 elif value is Array:
  for child in value:
   if not vectors_valid(child):return false
 return true

func finite_tree(value, depth: int=0) -> bool:
 if depth>32:return false
 if value is float:return is_finite(value)
 if value is Array:
  if value.size()>20000:return false
  for item in value:
   if not finite_tree(item,depth+1):return false
 elif value is Dictionary:
  for item in value.values():
   if not finite_tree(item,depth+1):return false
 return true
