extends SceneTree
func _initialize() -> void:
 var db=preload("res://scripts/content.gd").new()
 var sound=preload("res://scripts/soundscape.gd").new()
 var themes: Array=["boss","forest"]
 for chapter in db.tables.chapters:
  var theme: String=chapter.get("biome","forest")
  if theme not in themes:themes.append(theme)
 DirAccess.make_dir_recursive_absolute("res://assets/audio")
 var failed: int=0
 for theme in themes:
  var status: Error=ResourceSaver.save(sound.generate_stream(theme),"res://assets/audio/ambience_"+theme+".res")
  if status!=OK:failed+=1;push_error("Audio generation failed: "+theme)
 sound.free()
 print("Offline original ambience: ",themes.size()," themes; failures: ",failed)
 quit(1 if failed>0 else 0)
