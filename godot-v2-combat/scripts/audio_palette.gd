extends RefCounted
var voices: Array=[]
var rng:=RandomNumberGenerator.new()
var sample_rate=22050.0
func trigger(kind: String, mode: String="slash") -> void:
 if voices.size()>=16:return
 var frequency: float={"swing":170,"heavy":95,"impact":110,"hit":420,"crit":760,"hurt":72,"dash":310,"skill":560,"ultimate":84,"break":145,"pickup":900,"warning":250}.get(kind,220)
 if kind=="swing":frequency={"slash":170,"bolt":720,"field":300,"orbit":450,"return":530}.get(mode,170)
 var duration: float=.32 if kind in ["ultimate","break","warning"] else .14 if kind in ["heavy","impact","skill"] else .07
 voices.append({"kind":kind,"frequency":frequency*rng.randf_range(.96,1.04),"age":0.0,"duration":duration,"phase":0.0})
func sample() -> float:
 var mixed: float=0
 for v in voices:
  v.age+=1/sample_rate
  var x: float=v.age/v.duration
  var envelope: float=sin(minf(1,x)*PI)*pow(1-x,2) if x<1 else 0
  v.phase+=TAU*v.frequency*(1-.4*x)/sample_rate
  var tone: float=sin(v.phase)+.3*sin(v.phase*2.7)
  if v.kind in ["swing","dash","heavy","impact","hurt"]:tone=tone*.4+rng.randf_range(-1,1)*.55
  mixed+=tone*envelope*.065
 voices=voices.filter(func(v):return v.age<v.duration)
 return tanh(mixed)
