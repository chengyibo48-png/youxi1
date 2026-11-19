extends Node
# Original procedural ambience; isolated seeded noise never touches gameplay RNG.
var ambience: AudioStreamPlayer
var tension: AudioStreamPlayer
var streams: Dictionary={}
var active_biome: String=""
var duck: float=0
func _ready() -> void:
 preload("res://scripts/audio_mix.gd").configure()
 ambience=AudioStreamPlayer.new();tension=AudioStreamPlayer.new()
 ambience.bus="JourneyAmbience";tension.bus="JourneyMusic"
 add_child(ambience);add_child(tension)
 tension.stream=make_stream("boss");tension.volume_db=-80;tension.play()
func make_stream(theme: String) -> AudioStreamWAV:
 if streams.has(theme):return streams[theme]
 var path: String="res://assets/audio/ambience_"+theme+".res"
 if ResourceLoader.exists(path):
  streams[theme]=load(path)
  return streams[theme]
 # Unknown themes use a shipped fallback; synthesis is an offline production step.
 if ResourceLoader.exists("res://assets/audio/ambience_forest.res"):
  return load("res://assets/audio/ambience_forest.res")
 return null
func generate_stream(theme: String) -> AudioStreamWAV:
 var random=RandomNumberGenerator.new();random.seed=theme.hash()
 var samples: int=22050*8;var bytes=PackedByteArray();bytes.resize(samples*2)
 var filtered: float=0
 for i in samples:
  var t: float=i/22050.0
  filtered=lerpf(filtered,random.randf_range(-1,1),.035 if theme in ["river","forest","wild"] else .008)
  var envelope: float=.6+.3*sin(TAU*t/8)
  var value: float=filtered*envelope*.14
  if theme in ["river","snow"]:value+=sin(t*TAU*315+sin(t*TAU*.5)*3)*.005
  if theme in ["temple","city"]:value+=sin(t*TAU*440)*exp(-fmod(t,4)*3)*.025
  if theme in ["cave","grave","night"]:value+=sin(t*TAU*55)*.014
  if theme=="ember":value+=random.randf_range(-1,1)*pow(maxf(0,sin(t*TAU*3)),28)*.026
  if theme=="boss":value=sin(t*TAU*(62+35*exp(-fmod(t,.5)*22)))*exp(-fmod(t,.5)*18)*.12
  # Fade seam without changing timing or restarting battle clocks.
  value*=minf(1,minf(t,8-t)/.035)
  bytes.encode_s16(i*2,int(clampf(value,-1,1)*32767))
 var stream=AudioStreamWAV.new();stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=22050;stream.data=bytes
 stream.loop_mode=AudioStreamWAV.LOOP_FORWARD;stream.loop_end=samples;streams[theme]=stream;return stream
func update_mix(dt: float,biome: String,phase: int,enabled: bool,volume: float) -> void:
 if not is_instance_valid(ambience):return
 duck=maxf(0,duck-dt)
 if biome!=active_biome:
  active_biome=biome;ambience.stream=make_stream(biome)
  if ambience.stream!=null:ambience.play()
 var level: float=linear_to_db(maxf(.001,volume))
 var target: float=-20+level-(6 if duck>0 else 0) if enabled else -80
 ambience.volume_db=lerpf(ambience.volume_db,target,1-exp(-dt*6))
 tension.volume_db=lerpf(tension.volume_db,(-24+phase*2+level-(9 if duck>0 else 0)) if enabled and phase>0 else -80,1-exp(-dt*4))
