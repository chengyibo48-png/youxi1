extends Resource
class_name JourneyTalent
@export var id: StringName
@export var title: String
@export_multiline var description: String
@export var category: StringName
@export var effect: StringName
@export var amount: float = 0
@export var max_level: int = 1
@export var tags: Array[String] = []

@export var requires: Array[String] = []
@export var requires_any: Array[String] = []
@export var source_tags_any: Array[String] = []
@export var blocked_by: Array[String] = []
@export var exclusive: String = ""
@export var needs_shield: bool = false
