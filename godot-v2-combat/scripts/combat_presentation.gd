extends RefCounted
# The preview and actual arena share field geometry, weapon style and material rendering.
static func field(canvas: CanvasItem,f: Dictionary,time: float,reduced: bool=false) -> void:
 var style: String={"fire":"flame","water":"wave_sword","wave":"wave_sword","waterwall":"wave_sword","sanctuary":"lotus_lantern","lotus":"lotus_lantern","ink":"stamp","rake_wall":"rake"}.get(f.kind,"sand_seal")
 var weapon_id: String=f.get("weapon_id","")
 if preload("res://scripts/weapon_arts.gd").KITS.has(weapon_id):style=preload("res://scripts/weapon_arts.gd").KITS[weapon_id][1]
 var visual: Dictionary={"weapon_style":style,"weapon_id":weapon_id,"pos":f.pos,"dir":Vector2.RIGHT,"radius":f.radius,"life":.65+.1*sin(time*2),"max":1.0}
 preload("res://scripts/weapon_effects.gd").effect(canvas,visual,reduced)
