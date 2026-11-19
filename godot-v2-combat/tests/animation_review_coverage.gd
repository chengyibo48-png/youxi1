extends "res://tools/animation_review.gd"
var tested: int=0
var review_cases: Array=[]
var coverage_started: bool=false
var failures: Array[String]=[]
func _process(dt: float) -> bool:
 if not ready:return false
 if not coverage_started:
  coverage_started=true
  for hero_index in scene.db.tables.heroes.size():
   var hero: String=scene.db.tables.heroes[hero_index].id
   var count: int=6+scene.db.for_hero("skills",hero).size()+scene.db.for_hero("ultimates",hero).size()
   for weapon in 6:
    for direction in 4:
     for action in count:review_cases.append([hero_index,weapon,direction,action])
 if tested>=review_cases.size():
  var file=FileAccess.open("res://tests/animation-review-coverage.json",FileAccess.WRITE)
  file.store_string(JSON.stringify({"cases":tested,"failures":failures,"human_approved":0,"scope":"Playback startup/stepping across five heroes, thirty weapons, four views and all move selectors; not per-frame visual acceptance."},"  "));file.close()
  print("ANIMATION_REVIEW_COVERAGE cases=%d failures=%d"%[tested,failures.size()]);quit(1 if not failures.is_empty() else 0);return false
 var test: Array=review_cases[tested]
 hero_picker.select(test[0]);populate();weapon_picker.select(test[1]);direction_picker.select(test[2]);action_picker.select(test[3]);restart()
 var clip: String=actions[action_picker.selected]
 if clip not in ["walk","dash"] and scene.fight.player.action.is_empty():failures.append(str(test)+" did not start "+clip)
 for frame in 15:advance(1.0/60)
 if not is_finite(scene.fight.dealt):failures.append(str(test)+" invalid damage")
 tested+=1
 return false
