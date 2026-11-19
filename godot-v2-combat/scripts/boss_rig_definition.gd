extends Resource
class_name BossRigDefinition
@export var stable_id: String
@export var title: String
@export var atlas_index: int
@export var body_row: int
@export var shoulder_width: float=28
@export var torso_height: float=48
@export var thigh_length: float=25
@export var shin_length: float=25
@export var arm_length: float=25
@export var head_size: Vector2=Vector2(60,56)
@export var arm_pairs: int=1
@export var tail_segments: int=0
@export var wing_pairs: int=0
@export var head_count: int=1
@export var crouch: float=0
@export var weapon_id: String="bajie_w0"
@export var stance: String="brute"
# Stable topology IDs are also used to generate editable Skeleton2D scenes.
func bone_names() -> Array[String]:
 var result: Array[String]=["root","pelvis","spine","neck","head"]
 for side in ["left","right"]:
  result.append(side+"_thigh");result.append(side+"_shin")
  for pair in arm_pairs:result.append(side+"_arm_"+str(pair));result.append(side+"_forearm_"+str(pair))
  for pair in wing_pairs:result.append(side+"_wing_"+str(pair));result.append(side+"_wing_tip_"+str(pair))
 for segment in tail_segments:result.append("tail_"+str(segment))
 for index in range(1,head_count):result.append("neck_"+str(index));result.append("head_"+str(index))
 result.append("weapon_socket")
 return result
