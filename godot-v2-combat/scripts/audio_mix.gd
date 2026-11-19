extends RefCounted
# Independent routing; waveform production and human mixing approval are separate.
const BUSES=["JourneyMusic","JourneyAmbience","JourneyFX","JourneyWarnings"]
static func configure() -> void:
 for label in BUSES:
  if AudioServer.get_bus_index(label)>=0:continue
  AudioServer.add_bus();var index: int=AudioServer.bus_count-1
  AudioServer.set_bus_name(index,label);AudioServer.set_bus_send(index,"Master")
static func duck_db(active: bool) -> float:return -6.0 if active else 0.0
