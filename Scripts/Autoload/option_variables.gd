extends Node

#### VIDEO SETTINGS
#PLAYER VISION
signal vision_type_changed(new_vision_type: VisionType)
signal ray_cast_num_changed(new_value: int)
signal num_edge_precision_iterations_changed(new_value: int)

enum VisionType{
	BASIC,
	ADVANCED
}
var vision_type: VisionType = VisionType.ADVANCED:
	set(value):
		vision_type = value
		option_values["Video"]["vision_type"] = value
		vision_type_changed.emit(value)
var ray_count: int = 10:
	set(value):
		ray_count = value
		option_values["Video"]["ray_count"] = value
		ray_cast_num_changed.emit(value)
var edge_precision_iterations: int = 1:
	set(value):
		edge_precision_iterations = value
		option_values["Video"]["edge_precision_iterations"] = value
		num_edge_precision_iterations_changed.emit(value)
		
func check_is_advanced_vision_type() -> bool:
	return vision_type == VisionType.ADVANCED
	
### GENERAL
signal show_fps_changed(value: bool)

var show_fps: bool = false:
	set(value):
		show_fps = value
		option_values["Video"]["show_fps"] = value
		show_fps_changed.emit(value)
var fps_limit: float = 0:
	set(value):
		fps_limit = value
		option_values["Video"]["fps_limit"] = value
		Engine.max_fps = value

## EFFECTS
var is_blast_effect_enabled: bool = true:
	set(value):
		is_blast_effect_enabled = value
		option_values["Video"]["blast_effect_enabled"] = value

############### AUDIO SETTINGS
var option_values: Dictionary = {
	"Audio": {
			"Master": 100.0,
			"Background_Music": 100.0,
			"Effects": 100.0,
			"HUD_Effects": 100.0
			},
	"Video": {
			"quality": "NORMAL",
			"show_fps": false,
			"fps_limit": 999,
			"vision_type": vision_type,
			"ray_count": ray_count,
			"edge_precision_iterations": edge_precision_iterations,
			"blast_effect_enabled": is_blast_effect_enabled
			}
}

func set_values():
	_set_audio_values()
	_set_video_values()

func _set_audio_values():
	for audio_bus: String in option_values["Audio"].keys():
		var bus_value: float = option_values["Audio"][audio_bus]
		var linear_value: float = bus_value / 100.0
		var db_value: float = linear_to_db(linear_value)
		var bus_index = AudioServer.get_bus_index(audio_bus)
		AudioServer.set_bus_volume_db(bus_index, db_value)
		AudioServer.set_bus_mute(bus_index, linear_value == 0)

func _set_video_values():
	var video_values: Dictionary = option_values["Video"]
	if video_values["quality"] == "NORMAL":
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	else:
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	
	show_fps = video_values["show_fps"]
	fps_limit = video_values["fps_limit"]
	vision_type = video_values["vision_type"] as VisionType
	ray_count = video_values["ray_count"]
	edge_precision_iterations = video_values["edge_precision_iterations"]
	is_blast_effect_enabled = video_values["blast_effect_enabled"]
