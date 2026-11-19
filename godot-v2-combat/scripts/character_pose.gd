extends RefCounted
# Canvas draw commands retain RIDs; keep the submitted mesh resources alive.
var submitted_meshes: Array[ArrayMesh]=[]
# Continuous textured skin: independent feet, robe, shoulders and casting reach.
func vertices(player: Dictionary, clock: float) -> PackedVector2Array:
 var points:=PackedVector2Array()
 var speed: float=clampf(player.get("velocity",Vector2.ZERO).length()/230.0,0,1)
 var gait: float=player.get("gait",0)
 var left: float=sin(gait)*speed
 var right: float=sin(gait+PI)*speed
 var action: String=player.get("pose_clip", "attack")
 var progress: float=1-player.get("attack_left",0)/maxf(.01,player.get("attack_duration",.2))
 var strike: float=sin(clampf(progress,0,1)*PI) if player.get("attack_left",0)>0 else 0
 var facing: float=-1.0 if player.get("facing",Vector2.RIGHT).x<-.1 else 1.0
 for row in 10:
  var y: float=row/9.0
  for column in 7:
   var x: float=column/6.0
   var side: float=lerpf(left,right,x)
   var leg: float=smoothstep(.66,.90,y)
   var robe: float=sin(y*PI)*sin(gait-1.1)*speed
   var arm: float=sin(y*PI)*pow(absf(x-.5)*2,2)
   var reach: float=strike*(14 if action in ["beam","fan","breath","pursue"] else 7)
   var kneel: float=strike*7 if action in ["slam","quake","quakes","giant"] else 0
   var lift: float=-strike*9 if action in ["heal","sanctuary","chant","summon","avatars"] else 0
   points.append(Vector2((x-.5)*72*facing+side*5*leg+robe*2+arm*reach*facing, -91+y*120-side*6*leg-absf(left)*1.6*(1-leg)+kneel*(1-leg)+lift*arm+sin(clock*2)*.35*(1-leg)))
 return points
func draw(canvas: CanvasItem, texture: Texture2D, index: int, player: Dictionary, tint: Color, clock: float) -> void:
 var uv:=PackedVector2Array();var indices:=PackedInt32Array()
 for row in 10:
  for col in 7:uv.append(Vector2((index+col/6.0)/5.0,row/9.0))
 for row in 9:
  for col in 6:
   var i: int=row*7+col
   indices.append_array(PackedInt32Array([i,i+7,i+1,i+1,i+7,i+8]))
 var array: Array=[];array.resize(Mesh.ARRAY_MAX)
 array[Mesh.ARRAY_VERTEX]=vertices(player,clock);array[Mesh.ARRAY_TEX_UV]=uv;array[Mesh.ARRAY_INDEX]=indices
 var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,array)
 submitted_meshes.append(mesh)
 if submitted_meshes.size()>128:submitted_meshes.pop_front()
 canvas.draw_mesh(mesh,texture,Transform2D.IDENTITY,tint)
