extends Resource
class_name JourneyActionDefinition

@export var stable_id: String = ""
@export var windup: float = 0.1
@export var active: float = 0.08
@export var recovery: float = 0.18
@export var reach: float = 100.0
@export var width: float = 35.0
@export var geometry_kind: String = "arc"
@export var cancel_at: float = 0.18
@export var clip: String = ""
@export var sound: String = "slash"

func duration() -> float:
 return windup + active + recovery

func phase(elapsed: float) -> String:
 return "windup" if elapsed < windup else "active" if elapsed < windup + active else "recovery"
