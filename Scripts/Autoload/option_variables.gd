extends Node

#PLAYER VISION
signal vision_type_changed(new_vision_type: VisionType)
signal ray_cast_num_changed(new_value: int)
signal num_edge_precision_iterations_changed(new_value: int)

enum VisionType{
	BASIC,
	ADVANCED
}
var vision_type: VisionType = VisionType.BASIC:
	set(value):
		print(value)
		vision_type_changed.emit(value)
var ray_count: int = 50:
	set(value):
		print(value)
		ray_cast_num_changed.emit(value)
var edge_precision_iterations: int = 1:
	set(value):
		print(value)
		num_edge_precision_iterations_changed.emit(value)
		

func check_is_advanced_vision_type() -> bool:
	return vision_type == VisionType.ADVANCED
	
### GENERAL
signal show_fps_changed(value: bool)

var show_fps: bool = false:
	set(value):
		print(value)
		show_fps_changed.emit(value)
var fps_limit: float = 0:
	set(value):
		print(value)
		Engine.max_fps = value

## EFFECTS
var is_blast_effect_enabled: bool = true
